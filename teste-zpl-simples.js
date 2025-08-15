const net = require('net');

const printerIP = '192.168.123.100';
const printerPort = 9100;

const client = new net.Socket();

client.connect(printerPort, printerIP, () => {
  console.log('Conectado à impressora');

  // ZPL super simples para teste
  const zpl = `^XA
^FO200,50^A0N,50,50^FDTESTE^FS
^XZ`;

  client.write(zpl, 'utf8', () => {
    console.log('ZPL simples enviado');
    client.end();
  });
});

client.on('error', (err) => {
  console.error('Erro na conexão:', err);
});

client.on('close', () => {
  console.log('Conexão fechada');
});
