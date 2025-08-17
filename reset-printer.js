const net = require('net');

const printerIP = '192.168.123.100';
const printerPort = 9100;

const client = new net.Socket();

client.connect(printerPort, printerIP, () => {
  console.log('Conectado à impressora para reset');

  // Comandos para limpar buffer e resetar
  const resetCommands = `
KILL
CLS
HOME
INITIALPRINTER
`;

  client.write(resetCommands, 'utf8', () => {
    console.log('Comandos de reset enviados');
    client.end();
  });
});

client.on('error', (err) => {
  console.error('Erro na conexão:', err);
});

client.on('close', () => {
  console.log('Reset concluído');
});
