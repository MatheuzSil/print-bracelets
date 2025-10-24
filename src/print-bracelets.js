const fs = require('fs');
const amqp = require('amqplib');
const net = require('net');

const totemId = "1be6a224-83b7-4072-92c0-11b347b20f16";
const printerIp = "192.168.123.40";
const printerPort = 9100;
const rabbitUrl = "amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv";
const machineId = "totem";

if (!totemId) {
  console.error("Erro: TOTEM_ID não definido");
  process.exit(1);
}

if (!printerIp) {
  console.error("Erro: PRINTER_IP não definido");
  process.exit(1);
}

(async () => {
  try {
    const queueName = `print_bracelets_${totemId}`;
    console.log(`Nome da fila: ${queueName}`);

    const connection = await amqp.connect(rabbitUrl);
    const channel = await connection.createChannel();

    await channel.assertQueue(queueName, { durable: true });
    console.log(`Aguardando mensagens na fila: ${queueName}`);

    channel.consume(queueName, (msg) => {
      if (msg !== null) {
        const payload = JSON.parse(msg.content.toString());
        const children = payload.children.map(child => {
          return {
            Id: child.id,
            name: child.name,
            birthDate: child.birthDate,
            class: child.class,
          };
        });
        const parent = payload.parentName;
        const formatedParentName =  parent.slice(0, 17) + '...';
        console.log("PAYLOAD", payload);
        console.log("children parent:", formatedParentName);
        console.log("mensagem recebida", payload);
        console.log(`Imprimindo ${children.length} pulseira(s)`);

        // Array para armazenar os IDs aleatórios das crianças
        let childsId = [];

        // Função para imprimir uma pulseira por vez (sequencial)
        function printNext(index) {
          if (index >= children.length) {
            console.log('Todas as pulseiras das crianças foram impressas');
            console.log('IDs das crianças:', childsId);
            
            // Aqui você pode usar o childsId para imprimir a pulseira do pai
            // Por exemplo:
            // printParentBracelet(childsId);
            let tspl = fs.readFileSync('layout_parent.tspl', 'utf8');

            // Concatena os IDs das crianças em uma única string
            const childsIdString = childsId.join(', ');

            // Substitui os placeholders pelos valores variáveis
            tspl = tspl
              .replace('{PARENT_NAME}', parentName)
              .replace('{CHILDS_ID}', childsIdString);

            // Configura a conexão com a impressora
            const client = new net.Socket();
            client.connect(9100, process.env.PRINTER_IP, () => {
              console.log('Conectado à impressora para imprimir pulseira do pai');
              client.write(tspl);
              client.end();
            });

            client.on('error', (err) => {
              console.error('Erro na conexão para imprimir pulseira do pai:', err);
            });

            client.on('close', () => {
              console.log('Conexão fechada após imprimir pulseira do pai');
            });
            
            channel.ack(msg);
            return;
          }

          // Imprime a pulseira da criança atual
          const child = children[index];
          console.log(`Imprimindo pulseira ${index + 1} para: ${child.name}`);
          
          // Lê o arquivo de layout
          let tspl = fs.readFileSync('layout.tspl', 'utf8');
          const Id = Math.floor(10000 + Math.random() * 90000).toString().slice(0, 3);
          
          // Adiciona o ID da criança ao array
          childsId.push(Id);
          
          // Substitui os placeholders pelos valores variáveis
          tspl = tspl
            .replace('{ID}', Id)
            .replace('{NOME}', child.name)
            .replace('{CLASSE}', child.class)
            .replace('{DATA}', child.birthDate)
            .replace('{RESPONSAVEL}', formatedParentName)
            .replace('{QRCODE_DATA}', `https://flechakids.space/child/${child.Id}`);

          // Conecta à impressora
          const client = new net.Socket();
          client.connect(printerPort, printerIp, () => {
            console.log(`Conectado à impressora para ${child.name}`);
            client.write(tspl, 'utf8', () => {
              console.log(`Comando enviado para ${child.name}`);
              client.end();
            });
          });

          client.on('error', (err) => {
            console.error(`Erro na conexão para ${child.name}:`, err);
            // Mesmo com erro, continua para a próxima
            setTimeout(() => printNext(index + 1), 1000);
          });

          client.on('close', () => {
            console.log(`Conexão fechada para ${child.name}`);
            // Aguarda 10 segundos antes da próxima impressão
            setTimeout(() => printNext(index + 1), 8000);
          });
        }

        // Inicia a impressão sequencial
        printNext(0);
      }
    }, { noAck: false });
  }
  catch (error) {
    console.error('Erro ao conectar ou consumir mensagens:', error);
  }
})();


