
const readline = require('readline');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// ========================================
// CONFIGURAÇÕES FIXAS DO TOTEM
// ========================================
const TOTEM_CONFIG = {
  totemId: "1be6a224-83b7-4072-92c0-11b347b20f16",          // Altere aqui para cada totem
  printerIp: "192.168.123.40",   // Altere aqui para cada totem  
  machineId: "MACHINE_01"       // Altere aqui para cada totem
};
// ========================================

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
  console.log('=== Sistema de Impressão de Pulseiras ===\n');
  
  // Usa configurações fixas definidas no topo do arquivo
  const totemConfig = TOTEM_CONFIG;

  console.log('Configurações do Totem:');
  console.log(`Totem ID: ${totemConfig.totemId}`);
  console.log(`IP da Impressora: ${totemConfig.printerIp}`);
  console.log(`Machine ID: ${totemConfig.machineId}`);
  console.log('');

  try {
    const confirm = await askQuestion('Iniciar sistema com essas configurações? (s/n): ');

    if (confirm.toLowerCase() !== 's' && confirm.toLowerCase() !== 'sim') {
      console.log('Sistema não iniciado.');
      process.exit(0);
    }

    rl.close();
    startSystem(totemConfig);
    return;
  } catch (error) {
    console.error('Erro durante a configuração:', error);
    rl.close();
    process.exit(1);
  }

  // Código antigo comentado para referência

  // Caminho do arquivo de configuração (mapeado para pasta do PC)
  const configPath = path.join('/app/config', 'config.json');
  let config = {};

  // Verifica se a pasta de config existe e é acessível
  try {
    if (!fs.existsSync('/app/config')) {
      console.log('Pasta de configuração não encontrada. Criando...');
      fs.mkdirSync('/app/config', { recursive: true });
    }
  } catch (error) {
    console.log('Aviso: Não foi possível acessar a pasta de configuração.');
  }

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
    try {
      fs.writeFileSync(configPath, JSON.stringify(config, null, 2), 'utf8');
      console.log(`✓ Configuração salva em: ${configPath}`);
    } catch (error) {
      console.log(`⚠ Não foi possível salvar configuração: ${error.message}`);
      console.log('As configurações serão usadas apenas nesta sessão.');
    }

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
