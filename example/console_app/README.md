# clib_serialport_dart — Console example

This example is a small interactive console application that demonstrates
how to use `clib_serialport_dart` from a plain Dart app. It shows:

- Listing available serial ports
- Opening and configuring a port
- Writing and reading
- A simple loopback test (if you have a loopback or test device)

Running
-------

From the package root:

```bash
cd example/console_app
dart pub get

# Option A: point at the bundled native library (recommended for quick tests)
export CLIB_SERIALPORT_LIB=$(pwd)/../../native/linux/libserialport.so # adapt for your OS

dart run bin/main.dart --help
```

Or use `dart tool/bundle_native.dart --flutter-project` to copy libraries into
another project's platform folders (for Flutter builds). This example assumes
the native libs are reachable via `CLIB_SERIALPORT_LIB` or are on your system
library search path.
