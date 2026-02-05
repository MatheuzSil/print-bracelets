const { spawn } = require('child_process');
const path = require('path');

// Define o título da janela
process.title = 'Sistema de Impressão de Pulseiras - Menu Principal';

// Inicia o setup.js diretamente
const setupPath = path.join(__dirname, 'src', 'setup.js');
const child = spawn('node', [setupPath], {
  stdio: 'inherit'
});

child.on('error', (error) => {
  console.error('Erro ao iniciar o sistema:', error);
  process.exit(1);
});

child.on('close', (code) => {
  process.exit(code);
});

// Captura Ctrl+C para encerrar graciosamente
process.on('SIGINT', () => {
  console.log('\nEncerrando sistema...');
  child.kill('SIGINT');
  setTimeout(() => {
    process.exit(0);
  }, 1000);
});