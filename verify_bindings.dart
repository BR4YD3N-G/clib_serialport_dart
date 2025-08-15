import 'dart:io';
import 'package:crypto/crypto.dart';

Future<void> main() async {
  final checksumsFile = File('native/checksums.txt');
  if (!checksumsFile.existsSync()) {
    stderr.writeln('Error: native/checksums.txt not found.');
    exit(1);
  }

  final lines = checksumsFile.readAsLinesSync()
      .where((l) => l.trim().isNotEmpty && !l.startsWith('#'));

  bool allOk = true;

  for (final line in lines) {
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length != 2) {
      stderr.writeln('Invalid checksum line: $line');
      allOk = false;
      continue;
    }

    final expectedHash = parts[0];
    final filePath = 'native/${parts[1]}';
    final file = File(filePath);

    if (!file.existsSync()) {
      stderr.writeln('Missing file: $filePath');
      allOk = false;
      continue;
    }

    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes).toString();

    if (hash != expectedHash) {
      stderr.writeln('FAIL: $filePath');
      stderr.writeln('  Expected: $expectedHash');
      stderr.writeln('  Found:    $hash');
      allOk = false;
    } else {
      print('OK: $filePath');
    }
  }

  if (!allOk) {
    stderr.writeln('\nOne or more files failed verification.');
    exit(1);
  } else {
    print('\nAll binaries verified successfully.');
  }
}
