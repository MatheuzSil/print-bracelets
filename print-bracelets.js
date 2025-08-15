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
        const child = payload.children[0]; // Corrigido!

        console.log("mensagem recebida", payload);
        console.log(`Imprimindo pulseira para: ${child.name}`);

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
          console.log('Conectado à impressora');
          client.write(tspl, 'utf8', () => {
            console.log('Comando enviado');
            client.end();
          });
        });

        client.on('error', (err) => {
          console.error('Erro na conexão:', err);
        });

        client.on('close', () => {
          console.log('Conexão fechada');
        });

        channel.ack(msg);
      }
    }, { noAck: false });
  }
  catch (error) {
    console.error('Erro ao conectar ou consumir mensagens:', error);
  }
})();


