# Example: Flutter desktop binding test

This example shows a simple Flutter test that invokes `listSerialPorts()` from
`clib_serialport_dart` and ensures the native bindings can be loaded on desktop.

How to run (macOS / Linux / Windows desktop):

1. Ensure you have Flutter installed and the desktop target enabled.
2. From this package root, run flutter's test runner targeting the example file.

Set the native library path if needed:

```bash
# macOS
export CLIB_SERIALPORT_LIB=$(pwd)/native/macos/libserialport.dylib

# Linux (x64)
export CLIB_SERIALPORT_LIB=$(pwd)/native/linux/libserialport.so

# Linux (arm64)
export CLIB_SERIALPORT_LIB=$(pwd)/native/linux/libserialport_arm64.so

# Windows (PowerShell)
# $env:CLIB_SERIALPORT_LIB = "$(pwd)\native\windows\libserialport-0.dll"

# Run the flutter test (example assumes flutter is on PATH)
flutter test example/flutter_binding_test.dart
```

Notes:
- This example is intended for desktop Flutter. Mobile platforms require
  platform-specific native builds and usually a plugin package structure to
  include the native library in the app bundle.

Bundling helper
----------------
There's a small helper that copies the native binaries from this package into a Flutter project so the app build
can include them. Example usages (run from this package root):

Copy into a Flutter project's platform folders:

```bash
dart tool/bundle_native.dart --flutter-project /path/to/your/flutter/project
```

Or copy into a specific destination directory:

```bash
dart tool/bundle_native.dart --dest /path/to/target/dir
```

After copying, you may still need to add a platform-specific build/install step in the Flutter project to include
the native library in the final app bundle (see platform notes above).
