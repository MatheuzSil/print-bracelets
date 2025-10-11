
const readline = require('readline');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

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

  // Caminho do arquivo de configuração (mapeado para pasta do PC)
  const configPath = path.join('/app/config', 'config.json');
  let config = {};

  // Tenta carregar configuração existente
  if (fs.existsSync(configPath)) {
    try {
      config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      console.log('Configuração encontrada:');
      console.log(`Totem ID: ${config.totemId}`);
      console.log(`IP da Impressora: ${config.printerIp}`);
      console.log(`Machine ID: ${config.machineId}`);
      console.log('');
      const alterar = await askQuestion('Deseja alterar as configurações? (s/N): ');
      if (alterar.toLowerCase() !== 's' && alterar.toLowerCase() !== 'sim') {
        // Usa configuração existente
        startSystem(config);
        return;
      }
    } catch (e) {
      console.log('Configuração existente inválida, será necessário reconfigurar.');
    }
  }

  try {
    console.log('');
    const totemIdInput = await askQuestion(`Digite o Totem ID${config.totemId ? ` [${config.totemId}]` : ''}: `);
    const totemId = totemIdInput.trim() || config.totemId || '';
    
    const printerIpInput = await askQuestion(`Digite o IP da Impressora${config.printerIp ? ` [${config.printerIp}]` : ''}: `);
    const printerIp = printerIpInput.trim() || config.printerIp || '';
    
    const machineIdInput = await askQuestion(`Digite o Machine ID${config.machineId ? ` [${config.machineId}]` : ''}: `);
    const machineId = machineIdInput.trim() || config.machineId || '';

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

    // Salva configuração
    config = { totemId, printerIp, machineId };
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2), 'utf8');

    rl.close();

    startSystem(config);

  } catch (error) {
    console.error('Erro durante a configuração:', error);
    rl.close();
    process.exit(1);
  }
}

function startSystem(config) {
  // Valores padrão
  const rabbitUrl = "amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv";
  const printerPort = 9100;

  console.log('Iniciando sistema...\n');

  // Define as variáveis de ambiente
  process.env.TOTEM_ID = config.totemId;
  process.env.PRINTER_IP = config.printerIp;
  process.env.MACHINE_ID = config.machineId;
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
}

setup();
