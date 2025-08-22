const fs = require('fs');
const amqp = require('amqplib');
const net = require('net');

const totemId = process.env.TOTEM_ID;
const printerIp = process.env.PRINTER_IP;
const printerPort = process.env.PRINTER_PORT || 9100;
const rabbitUrl = process.env.RABBIT_URL;
const machineId = process.env.MACHINE_ID;

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

        console.log("mensagem recebida", payload);
        console.log(`Imprimindo ${children.length} pulseira(s)`);

        // Função para imprimir uma pulseira por vez (sequencial)
        function printNext(index) {
          if (index >= children.length) {
            console.log('Todas as pulseiras foram impressas');
            channel.ack(msg);
            return;
          }

          const child = children[index];
          console.log(`Imprimindo pulseira ${index + 1} para: ${child.name}`);
          
          // Lê o arquivo de layout
          let tspl = fs.readFileSync('layout.tspl', 'utf8');
          const Id = Math.floor(10000 + Math.random() * 90000).toString().slice(0, 3);

          // Substitui os placeholders pelos valores variáveis
          tspl = tspl
            .replace('{ID}', Id)
            .replace('{NOME}', child.name)
            .replace('{CLASSE}', child.class)
            .replace('{DATA}', child.birthDate)
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


