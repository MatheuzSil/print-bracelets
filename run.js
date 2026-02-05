const { spawn } = require('child_process');
const path = require('path');

// Define o título da janela
process.title = 'Sistema de Impressão de Pulseiras - Menu Principal';

console.clear();
console.log('=======================================================');
console.log('Sistema de Impressão de Pulseiras [GITHUB]');
console.log('=======================================================');
console.log('Carregando sistema...');
console.log('=======================================================\n');

// Inicia o setup.js
const setupPath = path.join(__dirname, 'src', 'setup.js');
const child = spawn('node', [setupPath], {
  stdio: 'inherit'
});

child.on('error', (error) => {
  console.error('Erro ao iniciar o sistema:', error);
  process.exit(1);
});

child.on('close', (code) => {
  console.log(`Sistema finalizado com código: ${code}`);
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