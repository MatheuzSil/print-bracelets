const net = require('net');

const printerIP = '192.168.123.100';
const printerPort = 9100;

function testDifferentFonts() {
  const client = new net.Socket();
  
  client.connect(printerPort, printerIP, () => {
    console.log('Testando diferentes fontes');
    
    const tspl = `
SIZE 270 mm, 300 mm
GAP 20 mm, 0
DIRECTION 0
CLS
TEXT 250,700,"3",90,1,1,"=========="
TEXT 250,760,"4",90,1,1,"F L E C H A"
TEXT 250,820,"3",90,1,1,"=========="

PRINT 1
`;
    
    client.write(tspl, () => {
      console.log('Fontes enviadas');
      client.end();
    });
  });
  
  client.on('error', (err) => {
    console.error('Erro:', err);
  });
  
  client.on('close', () => {
    console.log('Teste de fontes concluído');
  });
}

testDifferentFonts();
