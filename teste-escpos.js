const SerialPort = require('serialport');
const Readline = require('@serialport/parser-readline');

const portName = 'COM1'; // Change to your printer's COM port on Windows

const port = new SerialPort(portName, {
  baudRate: 9600, // Gaincha GS2208D usually uses 9600 bps
});

const parser = port.pipe(new Readline({ delimiter: '\r\n' }));

port.on('open', () => {
  console.log('Serial port open');

  const tspl = `
SIZE 48 mm,25 mm
CLS
TEXT 10,10,"TSS24.BF2",0,1,1,"Hello, world!"
PRINT 1
END
`;

  port.write(tspl, (err) => {
    if (err) {
      return console.error('Error on write: ', err.message);
    }
    console.log('Message written');
  });
});

port.on('error', (err) => {
  console.error('Serial port error:', err.message);
});