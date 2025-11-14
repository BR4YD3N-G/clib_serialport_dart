// Minimal desktop test for clib_serialport_dart bindings.
// This is a plain Dart test (runs with `dart test`) intended to be run on
// macOS/Linux/Windows desktop where the native binaries from `native/` are
// accessible. Set the CLIB_SERIALPORT_LIB env var if you need to point to a
// specific library path during development.
//
// For Flutter apps you can either:
//  - run this test with CLIB_SERIALPORT_LIB pointing at `native/<os>/…`, or
//  - run `dart tool/bundle_native.dart --flutter-project /path/to/flutter` to
//    copy the correct shared libraries into your Flutter project's platform
//    folders so they are included at build time.

import 'dart:io';

import 'package:test/test.dart';
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
