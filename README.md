# clib_serialport_dart

Full Dart FFI bindings for **libserialport**, bundled with **precompiled shared libraries** for macOS, Linux (x86_64/arm64), and Windows. No system install required — works directly from Git.

- **Cross-platform:** macOS (universal), Linux x86_64 & ARM64, Windows x86_64  
- **Complete API:** Every public `libserialport` function is mapped in `src/bindings.dart`  
- **Idiomatic Dart wrapper:** `SerialPort`, `SerialPortConfig`, `listSerialPorts()`  
- **Zero setup:** Loads binaries from `native/` in the package  
- **Integrity:** SHA-256 checksums + optional `verify_binaries.dart` verifier  
- **Reproducible builds:** GitHub Actions workflow builds + commits `/native` automatically

---

## Table of Contents

- [Why](#why)
- [Status & Compatibility](#status--compatibility)
- [Install](#install)
- [Quick Start](#quick-start)
- [High-Level API](#high-level-api)
- [Low-Level API (FFI)](#low-level-api-ffi)
- [Precompiled Binaries](#precompiled-binaries)
- [Verify Checksums](#verify-checksums)
- [Updating Binaries (CI)](#updating-binaries-ci)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)

---

## Why

Serial I/O from Dart/Flutter without relying on platform-specific plugins or system package managers. This package:

- exposes **all** of `libserialport` via Dart FFI,
- adds a **clean, high-level Dart API**,
- bundles **shared** libraries so you don’t need to install anything on the system,
- includes CI to **rebuild and refresh** binaries whenever you want.

---

## Status & Compatibility

| Platform | Arch                          | Supported |
|---------:|-------------------------------|-----------|
| macOS    | Universal (arm64 + x86_64)    | ✅ |
| Linux    | x86_64                        | ✅ |
| Linux    | arm64                         | ✅ |
| Windows  | x86_64                        | ✅ |

> Mobile (Android/iOS): not officially supported by this repo out of the box. `libserialport` can be built for Android, but that’s out of scope here.

Dart SDK: `>=3.0.0 <4.0.0`

---

## Install

Add as a **Git dependency**:

```yaml
# pubspec.yaml (clib_serialport_dart)
dependencies:
  clib_serialport_dart:
    git:
      url: https://github.com/BR4YD3N-G/clib_serialport_dart.git
      ref: main
```

That’s it. The shared libraries are shipped in `native/` and loaded at runtime.

---

## Quick Start

```dart
import 'package:clib_serialport_dart/clib_serialport_dart.dart';

void main() {
  // Enumerate
  final ports = listSerialPorts();
  for (final p in ports) {
    print('${p.name} | ${p.description} | VID: ${p.vendorId.toRadixString(16)} '
          'PID: ${p.productId.toRadixString(16)}');
  }

  if (ports.isEmpty) {
    print('No serial ports found.');
    return;
  }

  // Open + configure
  final port = SerialPort(ports.first.name);
  if (!port.open()) {
    print('Failed to open ${ports.first.name}');
    return;
  }

  final ok = port.configure(const SerialPortConfig(
    baudRate: 115200,
    dataBits: 8,
    parity: SPParity.none,
    stopBits: 1,
    flowControl: SPFlowControl.none,
  ));

  if (!ok) {
    print('Failed to configure port.');
    port.close();
    return;
  }

  // Write
  final bytesWritten = port.write('Hello\n'.codeUnits, timeoutMs: 1000);
  print('Wrote $bytesWritten bytes');

  // Read (try to read 6 bytes)
  final data = port.read(6, timeoutMs: 1000);
  print('Read: $data');

  port.close();
}
```

---

## High-Level API

### `listSerialPorts() → List<SerialPortInfo>`
- Returns name, description, transport, USB VID/PID (if USB).

### `class SerialPort`
- `SerialPort(String name)`
- `bool open({SPMode mode = SPMode.readWrite})`
- `bool configure(SerialPortConfig cfg)`
- `int write(List<int> data, {int timeoutMs = 1000})`
- `List<int> read(int size, {int timeoutMs = 1000})`
- `int inputWaiting()`, `int outputWaiting()`
- `void flush(SPBuffer buffer)`, `void drain()`
- `void setDTR(bool state)`, `void setRTS(bool state)`
- `int getSignals()` (bitmask as per libserialport)
- `void close()`

### `class SerialPortConfig`
```dart
const SerialPortConfig({
  this.baudRate = 9600,
  this.dataBits = 8,
  this.parity = SPParity.none,
  this.stopBits = 1,
  this.flowControl = SPFlowControl.none,
});
```

### Enums
- `SPMode` (`read`, `write`, `readWrite`)
- `SPParity` (`none`, `odd`, `even`, `mark`, `space`)
- `SPFlowControl` (`none`, `xonxoff`, `rtscts`, `dsrdtr`)
- `SPBuffer` (`input`, `output`, `both`)

---

## Low-Level API (FFI)

All public `libserialport` functions are mapped in `lib/src/bindings.dart`. You can call them directly if you need advanced/edge functionality not surfaced in the high-level API (e.g., event waits, raw signal masks, etc.).

Examples of mapped symbols:

- Enumeration & lookup: `sp_list_ports`, `sp_get_port_name`, `sp_get_port_description`, …
- Open/close: `sp_get_port_by_name`, `sp_open`, `sp_close`, `sp_free_port`, `sp_free_port_list`
- Configuration: `sp_set_baudrate`, `sp_get_baudrate`, `sp_set_bits`, `sp_set_parity`, `sp_set_stopbits`, `sp_set_flowcontrol`, …
- I/O: `sp_blocking_read`, `sp_blocking_write`, `sp_flush`, `sp_drain`, `sp_input_waiting`, `sp_output_waiting`
- Signals & events: `sp_get_signals`, `sp_set_dtr`, `sp_set_rts`, `sp_wait` (where supported)

---

## Precompiled Binaries

Bundled under `native/`:

```
native/
├─ version.txt          # tag/commit/date/flags
├─ checksums.txt        # SHA-256 for each lib
├─ macos/libserialport.dylib
├─ linux/libserialport.so             # x86_64
├─ linux/libserialport_arm64.so       # ARM64
└─ windows/libserialport-0.dll        # x86_64
```

The loader in `bindings.dart` automatically picks the correct file:
- macOS: universal `.dylib`
- Linux: chooses `libserialport.so` or `libserialport_arm64.so` based on architecture
- Windows: `libserialport-0.dll`

> If you relocate the `native/` folder, update the path logic in `bindings.dart`.

---

## Verify Checksums

This repo includes `verify_binaries.dart` so anyone can verify the SHA-256 hashes without external tools:

```bash
dart run verify_binaries.dart
```

Expected output:
```
OK: native/macos/libserialport.dylib
OK: native/linux/libserialport.so
OK: native/linux/libserialport_arm64.so
OK: native/windows/libserialport-0.dll

All binaries verified successfully.
```

Alternatively on Linux:

```bash
cd native
sha256sum -c checksums.txt
```

---

## Updating Binaries (CI)

The repo ships a GitHub Actions workflow at:

```
.github/workflows/build-libserialport.yml
```

What it does:

1. Builds `libserialport` for:
   - macOS (universal arm64+x86_64)
   - Linux (x86_64 & ARM64)
   - Windows (x86_64)
2. Strips & optimizes binaries
3. Uploads per-platform artifacts
4. **Publish job** assembles `/native`, generates `version.txt` + `checksums.txt`
5. Commits `/native` back to `main` and uploads a `native_binaries` artifact

Run from the **Actions** tab → “Build libserialport binaries”.

---

## Troubleshooting

### macOS
- **Blocked by Gatekeeper**: You may need to approve the `.dylib` (System Settings → Privacy & Security) or run your app once from Terminal.
- **Permissions**: Accessing USB serial devices sometimes requires TCC permissions for terminal apps.

### Linux
- **Permissions**: Add your user to the `dialout` (or distro equivalent) group and re-login:
  ```bash
  sudo usermod -a -G dialout $USER
  ```
- **udev rules**: Depending on devices, you may need udev rules for non-root access.
- **Missing libudev headers in custom builds**: Ensure `libudev-dev` is installed when rebuilding.

### Windows
- **Driver**: For USB-to-serial bridges (CP210x/FTDI/CH34x), install vendor drivers if needed.
- **Antivirus false positives**: Since we ship a DLL, whitelisting may be needed in some environments.

### Common code errors
- **Timeouts**: `read()` returns empty list on timeout; increase `timeoutMs` or check `inputWaiting()`.
- **Port busy**: Another process may be holding the port. Close any terminals/IDE monitors.

---

## License

- **This package (Dart code):** MIT — see [`LICENSE`](./LICENSE)
- **Bundled `libserialport` shared libraries:** **LGPL-3.0-or-later**  
  - License texts in `third_party/libserialport/`:
    - `COPYING.LESSER` (LGPL v3)
    - `COPYING` (GPL v3)
    - `NOTICE` with source URL and build details
  - The shared libraries are dynamically linked at runtime to satisfy LGPL relinking requirements.
  - The exact upstream version/commit is recorded in `native/version.txt`.

---

## Contributing

PRs welcome! If you add or tweak FFI bindings:

1. Update `lib/src/bindings.dart` and keep typedefs accurate.
2. Add/adjust high-level wrappers only if they remain cross-platform and safe.
3. Run `dart analyze` and `dart test`.
4. If you need new binaries, run the **GitHub Actions** workflow to rebuild `/native`.
5. Update `native/version.txt` + `checksums.txt` via the publish job.

Publishing checklist:
- `LICENSE` present (MIT)
- `third_party/libserialport/` license texts included
- `pubspec.yaml` includes `repository` and/or `homepage`
- `dart pub publish --dry-run` passes

---

## Acknowledgments

- `libserialport` — part of the Sigrok project.
- Dart FFI team — for making native interop straightforward.
