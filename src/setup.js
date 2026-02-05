
const readline = require('readline');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Array para armazenar os processos ativos dos totems
let activeProcesses = [];

// Caminho do arquivo de configuração dos totems
const totemsConfigPath = path.join(process.cwd(), 'totems.json');

function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}

function loadTotems() {
  try {
    if (fs.existsSync(totemsConfigPath)) {
      const data = fs.readFileSync(totemsConfigPath, 'utf8');
      return JSON.parse(data);
    }
  } catch (error) {
    console.log('Erro ao carregar configurações dos totems:', error.message);
  }
  return [];
}

function saveTotems(totems) {
  try {
    fs.writeFileSync(totemsConfigPath, JSON.stringify(totems, null, 2), 'utf8');
    console.log('✓ Configurações dos totems salvas.');
  } catch (error) {
    console.log('⚠ Não foi possível salvar configurações dos totems:', error.message);
  }
}

async function cadastrarTotem() {
  console.log('\n=== Cadastrar Novo Totem ===\n');
  
  try {
    const nome = await askQuestion('Digite o nome do totem: ');
    if (!nome.trim()) {
      console.log('Nome do totem é obrigatório!');
      return;
    }

    const totemId = await askQuestion('Digite o Totem ID: ');
    if (!totemId.trim()) {
      console.log('Totem ID é obrigatório!');
      return;
    }
    
    const printerIp = await askQuestion('Digite o IP da Impressora: ');
    if (!printerIp.trim()) {
      console.log('IP da impressora é obrigatório!');
      return;
    }
    
    const machineId = await askQuestion('Digite o Machine ID: ');
    if (!machineId.trim()) {
      console.log('Machine ID é obrigatório!');
      return;
    }

    // Valores padrão
    const rabbitUrl = "amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv";
    const printerPort = 9100;

    console.log('\n=== Configurações do Totem ===');
    console.log(`Nome: ${nome}`);
    console.log(`Totem ID: ${totemId}`);
    console.log(`IP da Impressora: ${printerIp}`);
    console.log(`Machine ID: ${machineId}`);
    console.log(`Rabbit URL: ${rabbitUrl}`);
    console.log(`Porta da Impressora: ${printerPort}`);
    console.log('================================\n');

    const confirm = await askQuestion('Confirma o cadastro deste totem? (s/n): ');

    if (confirm.toLowerCase() !== 's' && confirm.toLowerCase() !== 'sim') {
      console.log('Cadastro cancelado.');
      return;
    }

    // Carrega totems existentes
    const totems = loadTotems();
    
    // Verifica se já existe um totem com o mesmo nome ou ID
    const existingTotem = totems.find(t => t.nome.toLowerCase() === nome.toLowerCase() || t.totemId === totemId);
    if (existingTotem) {
      console.log('⚠ Já existe um totem com este nome ou ID!');
      return;
    }

    // Adiciona o novo totem
    const novoTotem = {
      id: Date.now(), // ID único baseado no timestamp
      nome: nome.trim(),
      totemId: totemId.trim(),
      printerIp: printerIp.trim(),
      machineId: machineId.trim(),
      rabbitUrl,
      printerPort,
      dataCriacao: new Date().toISOString()
    };

    totems.push(novoTotem);
    saveTotems(totems);
    console.log(`✓ Totem "${nome}" cadastrado com sucesso!`);

  } catch (error) {
    console.error('Erro durante o cadastro:', error);
  }
}

async function listarTotems() {
  const totems = loadTotems();
  
  if (totems.length === 0) {
    console.log('\nNenhum totem cadastrado.');
    return;
  }

  console.log('\n=== Totems Cadastrados ===\n');
  totems.forEach((totem, index) => {
    const status = activeProcesses.find(p => p.totemId === totem.id) ? '[ATIVO]' : '[INATIVO]';
    console.log(`[${index + 1}] ${status} ${totem.nome}`);
    console.log(`    Totem ID: ${totem.totemId}`);
    console.log(`    IP: ${totem.printerIp}`);
    console.log(`    Machine ID: ${totem.machineId}`);
    console.log(`    Criado em: ${new Date(totem.dataCriacao).toLocaleString()}`);
    console.log('');
  });
}

async function iniciarTotem() {
  const totems = loadTotems();
  
  if (totems.length === 0) {
    console.log('\nNenhum totem cadastrado. Cadastre um totem primeiro.');
    return;
  }

  console.log('\n=== Iniciar Totem ===\n');
  totems.forEach((totem, index) => {
    const status = activeProcesses.find(p => p.totemId === totem.id) ? '[ATIVO]' : '[INATIVO]';
    console.log(`[${index + 1}] ${status} ${totem.nome} (${totem.totemId})`);
  });

  const escolha = await askQuestion('\nDigite o número do totem para iniciar: ');
  const indice = parseInt(escolha) - 1;

  if (isNaN(indice) || indice < 0 || indice >= totems.length) {
    console.log('Opção inválida!');
    return;
  }

  const totem = totems[indice];
  
  // Verifica se o totem já está ativo
  const processoExistente = activeProcesses.find(p => p.totemId === totem.id);
  if (processoExistente) {
    console.log(`⚠ O totem "${totem.nome}" já está ativo!`);
    return;
  }

  startTotem(totem);
}

async function pararTotem() {
  if (activeProcesses.length === 0) {
    console.log('\nNenhum totem ativo no momento.');
    return;
  }

  console.log('\n=== Parar Totem ===\n');
  activeProcesses.forEach((processo, index) => {
    console.log(`[${index + 1}] ${processo.nome} (PID: ${processo.process.pid})`);
  });

  const escolha = await askQuestion('\nDigite o número do totem para parar: ');
  const indice = parseInt(escolha) - 1;

  if (isNaN(indice) || indice < 0 || indice >= activeProcesses.length) {
    console.log('Opção inválida!');
    return;
  }

  const processo = activeProcesses[indice];
  console.log(`Parando totem "${processo.nome}"...`);
  
  try {
    processo.process.kill();
    activeProcesses.splice(indice, 1);
    console.log(`✓ Totem "${processo.nome}" parado com sucesso!`);
  } catch (error) {
    console.log(`⚠ Erro ao parar totem: ${error.message}`);
  }
}

async function setup() {
  while (true) {
    console.clear();
    console.log('=======================================================');
    console.log('Sistema de Impressão de Pulseiras [GITHUB]');
    console.log('=======================================================');
    console.log('');
    console.log('[1] Cadastrar Totem');
    console.log('[2] Ver Totems Cadastrados');
    console.log('[3] Iniciar Totem');
    console.log('[4] Parar Totem');
    console.log('[5] Ver Logs em Tempo Real');
    console.log('[6] Reiniciar Sistema');
    console.log('[7] Atualizar do GitHub');
    console.log('[8] Desinstalar Sistema');
    console.log('[9] Sair');
    console.log('');
    console.log('=======================================================');

    const opcao = await askQuestion('Digite sua opção (1-9): ');

    switch(opcao) {
      case '1':
        await cadastrarTotem();
        await askQuestion('\nPressione Enter para continuar...');
        break;
      case '2':
        await listarTotems();
        await askQuestion('\nPressione Enter para continuar...');
        break;
      case '3':
        await iniciarTotem();
        await askQuestion('\nPressione Enter para continuar...');
        break;
      case '4':
        await pararTotem();
        await askQuestion('\nPressione Enter para continuar...');
        break;
      case '5':
        console.log('Funcionalidade de logs em desenvolvimento...');
        await askQuestion('\nPressione Enter para continuar...');
        break;
      case '6':
        console.log('Funcionalidade de reiniciar em desenvolvimento...');
        await askQuestion('\nPressione Enter para continuar...');
        break;
      case '7':
        console.log('Funcionalidade de atualização em desenvolvimento...');
        await askQuestion('\nPressione Enter para continuar...');
        break;
      case '8':
        console.log('Funcionalidade de desinstalação em desenvolvimento...');
        await askQuestion('\nPressione Enter para continuar...');
        break;
      case '9':
        console.log('Encerrando sistema...');
        // Para todos os processos ativos
        activeProcesses.forEach(processo => {
          try {
            processo.process.kill();
          } catch (error) {
            // Ignora erros ao parar processos
          }
        });
        rl.close();
        process.exit(0);
        break;
      default:
        console.log('Opção inválida! Tente novamente.');
        await askQuestion('\nPressione Enter para continuar...');
        break;
    }
  }
}

function startTotem(totem) {
  console.log(`Iniciando totem "${totem.nome}"...`);

  // Cria um novo processo para o totem em uma janela separada
  const child = spawn('cmd', ['/c', 'start', 'cmd', '/k', `node print-bracelets.js "${totem.nome}"`], {
    env: {
      ...process.env,
      TOTEM_ID: totem.totemId,
      PRINTER_IP: totem.printerIp,
      MACHINE_ID: totem.machineId,
      RABBIT_URL: totem.rabbitUrl,
      PRINTER_PORT: totem.printerPort,
      TOTEM_NAME: totem.nome
    },
    detached: true
  });

  // Adiciona o processo à lista de ativos
  const processoInfo = {
    totemId: totem.id,
    nome: totem.nome,
    process: child,
    startTime: new Date()
  };

  activeProcesses.push(processoInfo);

  child.on('close', (code) => {
    console.log(`Totem "${totem.nome}" finalizado com código: ${code}`);
    // Remove da lista de processos ativos
    const index = activeProcesses.findIndex(p => p.totemId === totem.id);
    if (index !== -1) {
      activeProcesses.splice(index, 1);
    }
  });

  child.on('error', (error) => {
    console.error(`Erro ao iniciar totem "${totem.nome}":`, error);
    // Remove da lista de processos ativos em caso de erro
    const index = activeProcesses.findIndex(p => p.totemId === totem.id);
    if (index !== -1) {
      activeProcesses.splice(index, 1);
    }
  });

  console.log(`✓ Totem "${totem.nome}" iniciado em nova janela!`);
  console.log(`  PID: ${child.pid}`);
  console.log(`  Totem ID: ${totem.totemId}`);
  console.log(`  IP da Impressora: ${totem.printerIp}`);
}

// Função de limpeza ao sair
process.on('SIGINT', () => {
  console.log('\nEncerrando sistema e parando todos os totems...');
  activeProcesses.forEach(processo => {
    try {
      processo.process.kill();
    } catch (error) {
      // Ignora erros ao parar processos
    }
  });
  rl.close();
  process.exit(0);
});

setup();
