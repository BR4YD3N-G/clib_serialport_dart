## 1.1.0 - 2025-11-13

- Keep package as a pure Dart package (no Flutter plugin metadata).
- Improve dynamic library loader: environment override (`CLIB_SERIALPORT_LIB`),
	programmatic override via `setLibraryPath()`, and more robust candidate
	paths for packaged `native/` binaries with fallback to `DynamicLibrary.process()`.
- Add `tool/bundle_native.dart` helper and document how Flutter desktop apps
	can include the native libraries (manual bundling guidance).
- Add a comprehensive console example at `example/console_app` demonstrating
	listing ports, opening/configuring, write/read, and a loopback test.
- Update documentation and examples to clarify Dart-only packaging and
	how to bundle native libs for Flutter consumers.
- Lint/style: rename FFI typedefs to follow private UpperCamelCase names
	and fix minor analyzer issues.
- Tests and CI: updated tests and verified `dart analyze` / `dart test` locally.

## 1.0.0

- Initial version.
