const net = require('net');

const printerIP = '192.168.123.100';  // IP da sua impressora na rede
const printerPort = 9100;           // Porta padrão (9100)

const client = new net.Socket();

client.connect(printerPort, printerIP, () => {
  console.log('Conectado à impressora');

  // Comando TSPL com GAP correto de 20mm conforme você informou
  const tspl = `
SIZE 270 mm, 24 mm
GAP 20 mm, 0
DIRECTION 0
CLS
TEXT 80, 80, "3", 0, 1, 1, "PULSEIRA TESTE"
PRINT 1

`;

  client.write(tspl, 'utf8', () => {
    console.log('Comando enviado com BLACK MARK');
    client.end();  // Fecha a conexão depois de enviar
  });
});

client.on('error', (err) => {
  console.error('Erro na conexão:', err);
});

client.on('close', () => {
  console.log('Conexão fechada');
});
