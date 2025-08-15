const net = require('net');

const printerIP = '192.168.123.100';
const printerPort = 9100;

const client = new net.Socket();

client.connect(printerPort, printerIP, () => {
  console.log('Conectado à impressora');

  // ZPL com configurações específicas para Gainscha pulseira
  const zpl = `^XA
^LH0,0
^LL192
^PW2160
^CI28
^FO100,40^A0N,30,30^FDTESTE ZPL^FS
^FO50,80^BY2,2,25^BCN,25,Y,N,N^FD123456^FS
^PQ1,0,1,Y
^XZ`;

  client.write(zpl, 'utf8', () => {
    console.log('ZPL configurado enviado');
    client.end();
  });
});

client.on('error', (err) => {
  console.error('Erro na conexão:', err);
});

client.on('close', () => {
  console.log('Conexão fechada');
});
