const fs = require('fs');
const amqp = require('amqplib');
const net = require('net');

const RABBIT_URL = "amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv";
const TOTEM_ID = '5deadc68-a674-4992-8276-0211c69cd39c'; 
const printerIP = '192.168.123.100';
const printerPort = 9100;

if (!TOTEM_ID) {
  console.error("Erro: TOTEM_ID não definido");
  process.exit(1);
}

(async () => {
  try {
    const queueName = `print_bracelets_${TOTEM_ID}`;
    console.log(`Nome da fila: ${queueName}`);

    const connection = await amqp.connect(RABBIT_URL);
    const channel = await connection.createChannel();

    await channel.assertQueue(queueName, { durable: true });
    console.log(`Aguardando mensagens na fila: ${queueName}`);

    channel.consume(queueName, (msg) => {
      if (msg !== null) {
        const payload = JSON.parse(msg.content.toString());
        const children = payload.children.map(child => {
          return {
            name: child.name,
            birthDate: child.birthDate,
            qrcodeUrl: child.qrcodeUrl
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

          // Substitui os placeholders pelos valores variáveis
          tspl = tspl
            .replace('{NOME}', child.name)
            .replace('{DATA}', child.birthDate)
            .replace('{QRCODE_DATA}', child.qrcodeUrl || 'https://example.com');

          // Conecta à impressora
          const client = new net.Socket();
          client.connect(printerPort, printerIP, () => {
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
            // Aguarda 2 segundos antes da próxima impressão
            setTimeout(() => printNext(index + 1), 2000);
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


