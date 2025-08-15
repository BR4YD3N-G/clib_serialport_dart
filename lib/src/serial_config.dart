import 'enums.dart';

/// Configuration for opening a serial port.
class SerialPortConfig {
  final int baudRate;
  final int dataBits;
  final SPParity parity;
  final int stopBits;
  final SPFlowControl flowControl;

  const SerialPortConfig({
    this.baudRate = 9600,
    this.dataBits = 8,
    this.parity = SPParity.none,
    this.stopBits = 1,
    this.flowControl = SPFlowControl.none,
  });
}
