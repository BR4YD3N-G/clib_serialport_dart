import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart tool/bundle_native.dart --dest <path>');
    print('  or:   dart tool/bundle_native.dart --flutter-project <path>');
    exit(1);
  }

  String? dest;
  String? flutterProject;

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--dest' && i + 1 < args.length) dest = args[++i];
    if (a == '--flutter-project' && i + 1 < args.length)
      flutterProject = args[++i];
  }

  final root = Directory.current.path;
  final nativeDir = Directory(p.join(root, 'native'));
  if (!nativeDir.existsSync()) {
    stderr.writeln('native/ directory not found in $root');
    exit(2);
  }

  // Collect candidate files to copy based on platform
  final filesToCopy = <File>[];
  final mac = File(p.join(root, 'native', 'macos', 'libserialport.dylib'));
  if (mac.existsSync()) filesToCopy.add(mac);

  final linuxDir = Directory(p.join(root, 'native', 'linux'));
  if (linuxDir.existsSync()) {
    for (final f in linuxDir.listSync()) {
      if (f is File && p.extension(f.path) == '.so') filesToCopy.add(f);
    }
  }

  final win = File(p.join(root, 'native', 'windows', 'libserialport-0.dll'));
  if (win.existsSync()) filesToCopy.add(win);

  if (filesToCopy.isEmpty) {
    stderr.writeln('No native libraries found under native/.');
    exit(3);
  }

  void copyInto(String targetDir) {
    final destDir = Directory(targetDir);
    if (!destDir.existsSync()) destDir.createSync(recursive: true);
    for (final f in filesToCopy) {
      final destPath = p.join(destDir.path, p.basename(f.path));
      f.copySync(destPath);
      print('Copied ${f.path} -> $destPath');
    }
  }

  if (flutterProject != null) {
    // Suggested locations for desktop Flutter projects.
    final macosTarget = p.join(flutterProject, 'macos');
    final linuxTarget = p.join(flutterProject, 'linux');
    final windowsTarget = p.join(flutterProject, 'windows');

    if (Directory(macosTarget).existsSync()) {
      // Place mac dylib into macos/ (developers should add a Copy Files build
      // phase to include it in the app bundle) — we copy into macos/ for now.
      copyInto(macosTarget);
    }
    if (Directory(linuxTarget).existsSync()) {
      // Copy linux shared objects into linux/ (CMake can pick them up).
      copyInto(linuxTarget);
    }
    if (Directory(windowsTarget).existsSync()) {
      // Copy windows DLL into windows/ (the runner build will include it).
      copyInto(windowsTarget);
    }

    print('\nDone. You may need to add a platform-specific copy/install step:');
    print(
      '- macOS: add a Copy Files phase to include the dylib in the .app bundle.',
    );
    print(
      '- Linux: ensure your CMakeLists.txt installs or bundles the .so into the AppDir.',
    );
    print(
      '- Windows: ensure the DLL is copied into the runner exe output directory.',
    );

    exit(0);
  }

  if (dest != null) {
    copyInto(dest);
    print('\nDone. Copied native libs into $dest');
    exit(0);
  }

  stderr.writeln('No valid target specified. Use --dest or --flutter-project.');
  exit(1);
}
