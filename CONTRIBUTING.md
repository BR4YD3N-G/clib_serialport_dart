# Contributing Guide

Thanks for your interest in contributing to **clib_serialport_dart**!

## Table of Contents
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [FFI Binding Conventions](#ffi-binding-conventions)
- [Tests](#tests)
- [Adding New libserialport Symbols](#adding-new-libserialport-symbols)
- [Building/Refreshing Binaries via CI](#buildingrefreshing-binaries-via-ci)
- [Releasing](#releasing)
- [Commit Messages](#commit-messages)
- [Security Issues](#security-issues)
- [License](#license)

## Development Setup
- Dart SDK **>= 3.0.0 < 4.0.0**
- Clone the repo and fetch deps:
  ```bash
  git clone https://github.com/<you>/clib_serialport_dart.git
  cd clib_serialport_dart
  dart pub get
  ```
- Run analyzer/tests:
  ```bash
  dart analyze
  dart test
  ```

## Project Structure
```
lib/
  clib_serialport_dart.dart     # Public exports
  src/
    bindings.dart               # Low-level FFI (all symbols)
    enums.dart                  # Enums/constants mapping
    serial_port.dart            # High-level API
    serial_list.dart            # Port enumeration wrapper
    serial_config.dart          # Config object
    utils.dart                  # Pointer/string helpers

native/                          # Precompiled shared libraries + metadata
  macos/libserialport.dylib
  linux/libserialport.so
  linux/libserialport_arm64.so
  windows/libserialport-0.dll
  checksums.txt
  version.txt

.github/workflows/build-libserialport.yml  # CI to rebuild and commit /native
verify_binaries.dart                        # Check SHA-256 matches
third_party/libserialport/                  # LGPL/GPL license texts + NOTICE
```

## Coding Standards
- Run `dart format .` before committing.
- Keep public APIs documented with Dart doc comments (`///`).
- Prefer small, focused PRs with tests.

## FFI Binding Conventions
- Use explicit typedef names: `_sp_func_c` and `_sp_func_dart`.
- Always check return values; `0` is typically success for libserialport.
- Manage memory carefully:
  - Allocate with `calloc`, free everything you allocate.
  - Convert strings with `toNativeUtf8()` / `toDartString()`.
- Keep **symbol names** exactly matching upstream (e.g., `sp_blocking_read`).
- When adding bindings, update high-level wrappers only if cross-platform behavior is consistent.

## Tests
- Unit tests live in `test/`.
- If a test needs an actual device, skip gracefully when no ports exist.
- For CI, tests should not assume a device is present.

## Adding New libserialport Symbols
1. Add the FFI signatures + lookups in `lib/src/bindings.dart`.
2. If relevant, expose a safe wrapper in `serial_port.dart` or `serial_list.dart`.
3. Update/extend enums/constants if needed.
4. Add or update tests.
5. Run `dart analyze` and `dart test`.

## Building/Refreshing Binaries via CI
- Trigger the workflow: **Actions → Build libserialport binaries → Run workflow**.
- The matrix jobs build for macOS (universal), Linux (x86_64 + arm64), and Windows (x86_64).
- The `publish` job assembles `/native`, writes `version.txt`, computes `checksums.txt`, commits to `main`, and uploads an artifact.
- After it finishes, run:
  ```bash
  dart run verify_binaries.dart
  ```
  to confirm hashes.

## Releasing
1. Update `CHANGELOG.md`.
2. Bump `version:` in `pubspec.yaml` (semver).
3. Ensure `/native` is up to date (run CI if needed).
4. Tag the release:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push --tags
   ```
5. Publish to pub:
   ```bash
   dart pub publish --dry-run
   dart pub publish
   ```

## Commit Messages
Use **Conventional Commits**:
- `feat:` new user-facing features
- `fix:` bug fixes
- `docs:` documentation only
- `refactor:`, `perf:`, `test:`, `build:`, `ci:` etc.

Examples:
- `feat: add RTS/DTR helpers to SerialPort`
- `fix: correct buffer free in read path`
- `ci: add publish job checksum verification`

## Security Issues
Please **do not** open public issues for security-sensitive bugs.
Email the maintainer at **brayden@kryptoindustries.com**.

## License
- Dart code: **MIT** (see `LICENSE`).
- Bundled libserialport shared libs: **LGPL-3.0-or-later** (see `third_party/libserialport/`).
