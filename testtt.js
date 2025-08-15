const net = require('net');

const printerIP = '192.168.123.100'; // Substitua pelo IP da sua Gainscha
const printerPort = 9100;

const client = new net.Socket();

client.connect(printerPort, printerIP, () => {
  console.log('Conectado à impressora GS2208D');

  // Comandos ESC/POS para pulseira de 27mm x 270mm
  const cmd = Buffer.concat([
    // --- Configurações Iniciais ---
    Buffer.from('\x1B\x40'), // Reset printer
    Buffer.from('\x1B\x61\x01'), // Centralizar texto
    
    // --- Cabeçalho (Negrito, tamanho aumentado) ---
    Buffer.from('\x1B\x21\x30'), // Texto grande (double height + negrito)
    Buffer.from('HOSPITAL ABC\n'),
    Buffer.from('\x1B\x21\x00'), // Volta ao tamanho normal
    
    // --- Divisor ---
    Buffer.from('----------------\n'),
    
    // --- Dados do Paciente ---
    Buffer.from('\x1B\x21\x10'), // Negrito
    Buffer.from('PACIENTE:\n'),
    Buffer.from('\x1B\x21\x00'), // Normal
    Buffer.from('JOANA SILVA\n\n'),
    
    Buffer.from('\x1B\x21\x10'), // Negrito
    Buffer.from('ID: 12345\n'),
    Buffer.from('LEITO: 102A\n'),
    Buffer.from('TIPO SANG: A+\n'),
    Buffer.from('\x1B\x21\x00'), // Normal
    
    // --- Divisor e rodapé ---
    Buffer.from('----------------\n'),
    Buffer.from('NASC: 15/01/1980\n'),
    Buffer.from('ALERGIAS: NENHUMA\n'),
    
  ]);

  
});

client.on('error', (err) => {
  console.error('Erro:', err);
});