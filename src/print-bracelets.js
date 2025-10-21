// npm i iconv-lite
const fs = require('fs');
const amqp = require('amqplib');
const net = require('net');
const iconv = require('iconv-lite');

const totemId = "1be6a224-83b7-4072-92c0-11b347b20f16";
const printerIp = "192.168.123.40";
const printerPort = 9100;
const rabbitUrl = "amqps://heqbymsv:...@jackal.rmq.cloudamqp.com/heqbymsv";

if (!totemId || !printerIp) {
  console.error("Erro: TOTEM_ID ou PRINTER_IP não definidos");
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
        const children = payload.children.map(child => ({
          Id: child.id,
          name: child.name,
          birthDate: child.birthDate,
          class: child.class,
        }));
        const parent = payload.parentName || '';
        const formatedParentName = parent.slice(0, 17) + (parent.length > 17 ? '...' : '');
        console.log("PAYLOAD", payload);
        console.log("responsável (trim):", formatedParentName);
        console.log(`Imprimindo ${children.length} pulseira(s)`);

        function printNext(index) {
          if (index >= children.length) {
            console.log('Todas as pulseiras foram impressas');
            channel.ack(msg);
            return;
          }

          const child = children[index];
          console.log(`Imprimindo pulseira ${index + 1} para: ${child.name}`);

          // Lê o arquivo de layout (assume que layout.tspl tem SET CODEPAGE 1252)
          let tspl = fs.readFileSync('layout.tspl', 'utf8');

          // Gera ID (exemplo)
          const Id = Math.floor(10000 + Math.random() * 90000).toString();

          // Substitui placeholders
          tspl = tspl
            .replace(/{ID}/g, Id)
            .replace(/{NOME}/g, child.name)
            .replace(/{CLASSE}/g, child.class)
            .replace(/{DATA}/g, child.birthDate)
            .replace(/{RESPONSAVEL}/g, parent)
            .replace(/{QRCODE_DATA}/g, `https://flechakids.space/child/${child.Id}`);

          // Converte para CP1252 (win1252)
          const buffer = iconv.encode(tspl, 'win1252');

          // Conecta à impressora e envia buffer
          const client = new net.Socket();
          client.setTimeout(15000); // opcional: timeout
          client.connect(printerPort, printerIp, () => {
            console.log(`Conectado à impressora para ${child.name}`);
            client.write(buffer, (err) => {
              if (err) {
                console.error(`Erro ao enviar dados para ${child.name}:`, err);
                client.destroy();
                // continua para próxima
                setTimeout(() => printNext(index + 1), 2000);
                return;
              }
              console.log(`Comando enviado para ${child.name}`);
              // esperar fechar automaticamente ou encerrar conexão
              client.end();
            });
          });

          client.on('error', (err) => {
            console.error(`Erro na conexão para ${child.name}:`, err);
            // Mesmo com erro, continua para a próxima
            setTimeout(() => printNext(index + 1), 2000);
          });

          client.on('close', (hadError) => {
            console.log(`Conexão fechada para ${child.name} (hadError=${hadError})`);
            // Aguarda alguns segundos antes da próxima impressão
            setTimeout(() => printNext(index + 1), 4000);
          });

          client.on('timeout', () => {
            console.error(`Timeout na impressora para ${child.name}`);
            client.destroy();
            setTimeout(() => printNext(index + 1), 2000);
          });
        }

        printNext(0);
      }
    }, { noAck: false });
  } catch (error) {
    console.error('Erro ao conectar ou consumir mensagens:', error);
  }
})();
