// Minimal Flutter desktop test for clib_serialport_dart bindings.
// This is intended to be run on macOS/Linux/Windows desktop where the native
// binaries from `native/` are accessible. Set the CLIB_SERIALPORT_LIB env var
// if you need to point to a specific library path during development.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:clib_serialport_dart/clib_serialport_dart.dart';

void main() {
  test('listSerialPorts runs without throwing', () {
    final override = Platform.environment['CLIB_SERIALPORT_LIB'];
    if (override != null && override.isNotEmpty) {
      setLibraryPath(override);
    }

    final ports = listSerialPorts();
    // The test passes as long as the call doesn't throw and returns a list.
    print('Found ${ports.length} ports');
    expect(ports, isA<List<SerialPortInfo>>());
  });
}
