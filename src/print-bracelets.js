const fs = require('fs');
const amqp = require('amqplib');
const net = require('net');
const { time, error } = require('console');
const { type } = require('os');

// Função para remover acentos e caracteres especiais
function removeAccentsAndSpecialChars(text) {
  if (!text) return '';
  
  return text
    // Remove acentos
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    // Remove caracteres especiais, mantém apenas letras, números e espaços
    .replace(/[^\w\s]/g, '')
    // Remove espaços duplos
    .replace(/\s+/g, ' ')
    // Remove espaços no início e fim
    .trim();
}

// Obtém configurações das variáveis de ambiente (setadas pelo setup.js)
const totemId = process.env.TOTEM_ID || "1be6a224-83b7-4072-92c0-11b347b20f16";
const printerIp = process.env.PRINTER_IP || "192.168.123.40";
const printerPort = process.env.PRINTER_PORT || 9100;
const rabbitUrl = process.env.RABBIT_URL || "amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv";
const machineId = process.env.MACHINE_ID || "totem";
const totemName = process.env.TOTEM_NAME || "Totem Principal";

// Define o título da janela do terminal
if (process.argv[2]) {
  process.title = `Totem: ${process.argv[2]}`;
} else {
  process.title = `Totem: ${totemName}`;
}

// Log das configurações carregadas
console.log('=======================================================');
console.log(`           ${totemName.toUpperCase()}`);
console.log('=======================================================');
console.log(`Totem ID: ${totemId}`);
console.log(`Printer IP: ${printerIp}`);
console.log(`Printer Port: ${printerPort}`);
console.log(`Machine ID: ${machineId}`);
console.log('=======================================================\n');

if (!totemId) {
  console.error("❌ Erro: TOTEM_ID não definido");
  process.exit(1);
}

if (!printerIp) {
  console.error("❌ Erro: PRINTER_IP não definido");
  process.exit(1);
}

// Função para log com timestamp e nome do totem
function log(message, type = 'INFO') {
  const timestamp = new Date().toLocaleString();
  const prefix = type === 'ERROR' ? '❌' : type === 'SUCCESS' ? '✅' : 'ℹ️';
  console.log(`[${timestamp}] ${prefix} [${totemName}] ${message}`);
}

(async () => {
  try {
    const queueName = `print_bracelets_${totemId}`;
    log(`Nome da fila: ${queueName}`);
    log('Conectando ao RabbitMQ...');

    const connection = await amqp.connect(rabbitUrl);
    const channel = await connection.createChannel();

    await channel.assertQueue(queueName, { durable: true });
    log(`Aguardando mensagens na fila: ${queueName}`, 'SUCCESS');

    channel.consume(queueName, (msg) => {
      if (msg !== null) {
        const payload = JSON.parse(msg.content.toString());
        const children = payload.children.map(child => {
          return {
            Id: child.id,
            name: removeAccentsAndSpecialChars(child.name),
            birthDate: child.birthDate,
            class: removeAccentsAndSpecialChars(child.class),
          };
        });
        const parent = removeAccentsAndSpecialChars(payload.parentName);
        const formatedParentName = parent.length > 20 ? parent.slice(0, 17) + '...' : parent;
        
        log(`Nova mensagem recebida para ${children.length} criança(s)`);
        log(`Responsável: ${formatedParentName}`);
        log(`Iniciando impressão de ${children.length} pulseira(s)...`);

        // Array para armazenar os IDs aleatórios das crianças
        let childsId = [];

        // Função para imprimir uma pulseira por vez (sequencial)
        function printNext(index) {
          if (index >= children.length) {
            log('Todas as pulseiras das crianças foram impressas', 'SUCCESS');
            log(`IDs das crianças: ${childsId.join(', ')}`);
            
            log('Iniciando impressão da pulseira do responsável...');
            let tspl = fs.readFileSync('layoutparent.tspl', 'utf8');

            // Concatena os IDs das crianças em uma única string
            const childsIdString = childsId.join(',');

            // Substitui os placeholders pelos valores variáveis
            tspl = tspl
              .replace('{PARENT_NAME}', formatedParentName)
              .replace('{CHILDS_ID}', childsIdString)
              .replace('{DATE}', new Date().toLocaleDateString())
              .replace('{QRCODE_DATA}', `https://flechakids.space/child/${children.id}`);
              

            // Configura a conexão com a impressora
            const client = new net.Socket();
            client.connect(printerPort, printerIp, () => {
              log('Conectado à impressora para pulseira do responsável');
              client.write(tspl);
              client.end();
            });

            client.on('error', (err) => {
              log(`Erro na conexão para pulseira do responsável: ${err.message}`, 'ERROR');
            });

            client.on('close', () => {
              log('Pulseira do responsável impressa com sucesso!', 'SUCCESS');
              log('='.repeat(50));
            });
            
            channel.ack(msg);
            return;
          }

          // Imprime a pulseira da criança atual
          const child = children[index];
          log(`Imprimindo pulseira ${index + 1}/${children.length} para: ${child.name}`);
          
          // Lê o arquivo de layout
          let tspl = fs.readFileSync('layout.tspl', 'utf8');
          const Id = Math.floor(10000 + Math.random() * 90000).toString().slice(0, 3);
          const ageByDateOfBirth = new Date().getFullYear() - new Date(child.birthDate).getFullYear();
          let childClass;
          switch (ageByDateOfBirth) {
            case 1: 
              childClass = 'Berçário';
              break;
            case 2: 
            case 3:
              childClass = 'Maternal';
              break;
            case 4: 
            case 5:
              childClass = 'Jardim 1';
              break;
            case 6: 
            case 7:
              childClass = 'Jardim 2';
              break;
            case 8: 
            case 9:
              childClass = 'Juniores 1';
              break;
            case 10: 
            case 11:
              childClass = 'Juniores 2';
              break;
            default: 
              childClass = '';
              break;
          }
          // Adiciona o ID da criança ao array
          childsId.push(Id);
          
          // Substitui os placeholders pelos valores variáveis
          tspl = tspl
            .replace('{ID}', Id)
            .replace('{NOME}', child.name)
            .replace('{CLASSE}', childClass)
            .replace('{DATA}', child.birthDate)
            .replace('{RESPONSAVEL}', formatedParentName)
            .replace('{QRCODE_DATA}', `https://flechakids.space/child/${child.Id}`);

          // Conecta à impressora
          const client = new net.Socket();
          client.connect(printerPort, printerIp, () => {
            log(`Conectado à impressora para ${child.name}`);
            client.write(tspl, 'utf8', () => {
              log(`Dados enviados para impressão: ${child.name}`);
              client.end();
            });
          });

          client.on('error', (err) => {
            log(`Erro na conexão para ${child.name}: ${err.message}`, 'ERROR');
            // Mesmo com erro, continua para a próxima
            setTimeout(() => printNext(index + 1), 1000);
          });

          client.on('close', () => {
            log(`Pulseira de ${child.name} enviada com sucesso!`, 'SUCCESS');
            // Aguarda 6 segundos antes da próxima impressão
            setTimeout(() => {
              printNext(index + 1);
            }, 6000);
          });
        }

        // Inicia a impressão sequencial
        printNext(0);
      }
    }, { noAck: false });
  }
  catch (error) {
    log(`Erro ao conectar ou consumir mensagens: ${error.message}`, 'ERROR');
  }
})();


