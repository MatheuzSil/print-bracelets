

export const printParentBracelet = (parentName, childsId) => {
  const net = require('net');
  const fs = require('fs');

  // Lê o arquivo de layout para o pai
  let tspl = fs.readFileSync('layout_parent.tspl', 'utf8');

  // Concatena os IDs das crianças em uma única string
  const childsIdString = childsId.join(', ');

  // Substitui os placeholders pelos valores variáveis
  tspl = tspl
    .replace('{PARENT_NAME}', parentName)
    .replace('{CHILDS_ID}', childsIdString);

  // Configura a conexão com a impressora
  const client = new net.Socket();
  client.connect(9100, process.env.PRINTER_IP, () => {
    console.log('Conectado à impressora para imprimir pulseira do pai');
    client.write(tspl);
    client.end();
  });

  client.on('error', (err) => {
    console.error('Erro ao conectar à impressora para o pai:', err);
  });
};