import 'dart:io';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:clib_serialport_dart/clib_serialport_dart.dart';

void printPorts() {
  final ports = listSerialPorts();
  if (ports.isEmpty) {
    print('No serial ports found.');
    return;
  }

  for (var i = 0; i < ports.length; i++) {
    final p = ports[i];
    print('[$i] ${p.name} — ${p.description}');
  }
}

Future<int> loopbackTest(String name, {int baudRate = 9600}) async {
  final port = SerialPort(name);
  if (!port.open()) {
    print('Failed to open $name');
    return 2;
  }

  final ok = port.configure(SerialPortConfig(baudRate: baudRate));
  if (!ok) {
    print('Failed to configure $name');
    port.close();
    return 3;
  }

  final toSend = utf8.encode('HELLO');
  final written = port.write(toSend);
  print('Wrote $written bytes');

  final read = port.read(toSend.length, timeoutMs: 1000);
  print('Read: ${read.isEmpty ? '<timeout>' : read}');

  port.close();
  return 0;
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'list',
      abbr: 'l',
      help: 'List available serial ports',
      negatable: false,
    )
    ..addOption('open', abbr: 'o', help: 'Open port by name (path)')
    ..addOption('index', abbr: 'i', help: 'Open port by index from list')
    ..addFlag(
      'loopback',
      abbr: 'b',
      help: 'Run a simple loopback test with first port',
      negatable: false,
    )
    ..addOption(
      'baud',
      abbr: 'B',
      defaultsTo: '9600',
      help: 'Baud rate for open/loopback',
    )
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);

  final result = parser.parse(args);
  if (result['help'] as bool) {
    print('Usage: dart run bin/main.dart [options]\n');
    print(parser.usage);
    return;
  }

  // If caller provided an environment override, use it.
  final override = Platform.environment['CLIB_SERIALPORT_LIB'];
  if (override != null && override.isNotEmpty) {
    print('Using CLIB_SERIALPORT_LIB override: $override');
    setLibraryPath(override);
  }

  if (result['list'] as bool) {
    printPorts();
    return;
  }

  if (result['loopback'] as bool) {
    final ports = listSerialPorts();
    if (ports.isEmpty) {
      print('No ports available to run loopback.');
      return;
    }

    final idx = int.tryParse(result['index'] as String? ?? '') ?? 0;
    final baud = int.tryParse(result['baud'] as String) ?? 9600;
    final name = ports[idx].name;
    print('Running loopback on $name @ $baud');
    await loopbackTest(name, baudRate: baud);
    return;
  }

  if (result['open'] != null) {
    final name = result['open'] as String;
    final baud = int.tryParse(result['baud'] as String) ?? 9600;
    print('Opening $name @ $baud');

    final port = SerialPort(name);
    if (!port.open()) {
      print('Failed to open $name');
      return;
    }

    final ok = port.configure(SerialPortConfig(baudRate: baud));
    if (!ok) {
      print('Failed to configure $name');
      port.close();
      return;
    }

    stdout.writeln('Enter text to send. Blank line to exit.');
    while (true) {
      stdout.write('> ');
      final line = stdin.readLineSync(encoding: utf8);
      if (line == null || line.isEmpty) break;
      final data = utf8.encode(line + '\n');
      final wrote = port.write(data);
      print('Wrote $wrote bytes');

      final read = port.read(64, timeoutMs: 500);
      if (read.isNotEmpty) print('Read: $read');
    }

    port.close();
    return;
  }

  // Default: interactive menu
  print('clib_serialport_dart console example');
  print(
    'Run with --list to enumerate ports or --loopback to run a loopback test',
  );
  print('');
  printPorts();
}
