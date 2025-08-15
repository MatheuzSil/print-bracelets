const net = require('net');

const printerIP = '192.168.123.100';
const printerPort = 9100;

const client = new net.Socket();

client.connect(printerPort, printerIP, () => {
  console.log('Conectado à impressora');

  // Código ZPL ajustado para pulseira 270mm x 24mm
  const zpl = `^XA
^LL192
^LH0,0
^PW2160
^FO100,30^BY2,2,30^BCN,30,Y,N,N^FD1234567890^FS
^FO400,50^A0N,40,40^FDT E S T E^FS
^XZ`;

  client.write(zpl, 'utf8', () => {
    console.log('Código ZPL enviado');
    client.end();
  });
});

client.on('error', (err) => {
  console.error('Erro na conexão:', err);
});

client.on('close', () => {
  console.log('Conexão fechada');
});
