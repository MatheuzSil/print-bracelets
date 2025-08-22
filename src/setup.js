const readline = require('readline');
const { spawn } = require('child_process');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}

async function setup() {
  console.log('=== Configuração do Sistema de Impressão ===\n');
  
  try {
    const totemId = await askQuestion('Digite o Totem ID: ');
    const printerIp = await askQuestion('Digite o IP da Impressora: ');
    const machineId = await askQuestion('Digite o Machine ID: ');
    
    // Valores padrão
    const rabbitUrl = "amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv";
    const printerPort = 9100;
    
    console.log('\n=== Configurações ===');
    console.log(`Totem ID: ${totemId}`);
    console.log(`IP da Impressora: ${printerIp}`);
    console.log(`Machine ID: ${machineId}`);
    console.log(`Rabbit URL: ${rabbitUrl}`);
    console.log(`Porta da Impressora: ${printerPort}`);
    console.log('========================\n');
    
    const confirm = await askQuestion('Confirma as configurações? (s/n): ');
    
    if (confirm.toLowerCase() !== 's' && confirm.toLowerCase() !== 'sim') {
      console.log('Configuração cancelada.');
      process.exit(0);
    }
    
    rl.close();
    
    console.log('Iniciando sistema...\n');
    
    // Define as variáveis de ambiente
    process.env.TOTEM_ID = totemId;
    process.env.PRINTER_IP = printerIp;
    process.env.MACHINE_ID = machineId;
    process.env.RABBIT_URL = rabbitUrl;
    process.env.PRINTER_PORT = printerPort;
    
    // Inicia o sistema principal
    const child = spawn('node', ['print-bracelets.js'], {
      stdio: 'inherit',
      env: { ...process.env }
    });
    
    child.on('close', (code) => {
      console.log(`Sistema finalizado com código: ${code}`);
    });
    
    child.on('error', (error) => {
      console.error('Erro ao iniciar o sistema:', error);
    });
    
  } catch (error) {
    console.error('Erro durante a configuração:', error);
    rl.close();
    process.exit(1);
  }
}

setup();
