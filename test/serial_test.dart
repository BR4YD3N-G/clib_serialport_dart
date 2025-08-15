import 'package:test/test.dart';
import 'package:clib_serialport_dart/clib_serialport_dart.dart';

void main() {
  test('List serial ports', () {
    final ports = listSerialPorts();
    print('Ports: ${ports.map((p) => p.name).toList()}');
    expect(ports, isA<List<SerialPortInfo>>());
  });

  test('Open, configure, write/read loopback', () {
    final ports = listSerialPorts();
    if (ports.isEmpty) {
      print('No serial ports found, skipping test.');
      return;
    }

    final port = SerialPort(ports.first.name);
    expect(port.open(), isTrue);

    expect(port.configure(SerialPortConfig(baudRate: 9600)), isTrue);

    final written = port.write([0x41, 0x42, 0x43]);
    expect(written, equals(3));

    final readData = port.read(3, timeoutMs: 500);
    print('Read data: $readData');

    port.close();
  });
}
