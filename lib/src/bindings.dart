import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';
import 'dart:ffi' as ffi;

DynamicLibrary _openLib() {
  // Allow overriding library path/name via environment. Helpful for tests
  // or when Flutter bundles the native lib in a custom location.
  const envVar = 'CLIB_SERIALPORT_LIB';
  final override = Platform.environment[envVar];
  if (override != null && override.isNotEmpty) {
    try {
      return DynamicLibrary.open(override);
    } catch (e) {
      // ignore and fallthrough to other lookup strategies
    }
  }

  const base = 'native';
  final abi = ffi.Abi.current();

  // Candidate paths in order of preference. Keep ABI-specific names so the
  // repository can ship multiple binaries under `native/`.
  final candidates = <String>[];

  switch (abi) {
    case ffi.Abi.macosArm64:
    case ffi.Abi.macosX64:
      candidates.addAll([
        '$base/macos/libserialport.dylib',
        'native/macos/libserialport.dylib',
      ]);
      break;
    case ffi.Abi.linuxArm64:
      candidates.addAll([
        '$base/linux/libserialport_arm64.so',
        'native/linux/libserialport_arm64.so',
      ]);
      break;
    case ffi.Abi.linuxX64:
      candidates.addAll([
        '$base/linux/libserialport.so',
        'native/linux/libserialport.so',
      ]);
      break;
    case ffi.Abi.windowsX64:
      candidates.addAll([
        '$base/windows/libserialport-0.dll',
        'native/windows/libserialport-0.dll',
      ]);
      break;
    default:
      // For unsupported ABIs (mobile), we still attempt to fall back to
      // DynamicLibrary.process which often works on Flutter engine-built
      // libraries where the native code is already loaded into the process.
      candidates.addAll([]);
      break;
  }

  for (final path in candidates) {
    try {
      return DynamicLibrary.open(path);
    } catch (_) {
      // try next candidate
    }
  }

  // If running in Flutter AOT the plugin may already be loaded into the
  // process. DynamicLibrary.process works there. Try it as a last resort.
  try {
    return DynamicLibrary.process();
  } catch (e) {
    throw UnsupportedError(
      'Could not open native library for ABI: $abi on ${Platform.operatingSystem}.\nTried: ${candidates.join(', ')}.\nSet environment variable $envVar to force a path.\nOriginal error: $e',
    );
  }
}

// Cached library instance. This remains null until the first access so callers
// can call [setLibraryPath] to override the location before any lookup occurs.
DynamicLibrary? _cachedLib;

/// Programmatically set the native library path. This is useful for Dart or
/// Flutter users who want to explicitly supply the library path at runtime
/// instead of using the environment variable.
void setLibraryPath(String path) {
  _cachedLib = DynamicLibrary.open(path);
}

DynamicLibrary _getLib() {
  if (_cachedLib != null) return _cachedLib!;
  _cachedLib = _openLib();
  return _cachedLib!;
}

// Expose a getter named `_lib` so existing lookup code below can remain
// unchanged (they reference `_lib.lookupFunction`).
DynamicLibrary get _lib => _getLib();

// ---------- Port Enumeration ----------
typedef _SpListPortsC = Int32 Function(Pointer<Pointer<Pointer<Void>>>);
typedef _SpListPortsDart = int Function(Pointer<Pointer<Pointer<Void>>>);
final spListPorts = _lib.lookupFunction<_SpListPortsC, _SpListPortsDart>(
  'sp_list_ports',
);

typedef _SpGetPortNameC = Pointer<Utf8> Function(Pointer<Void>);
typedef _SpGetPortNameDart = Pointer<Utf8> Function(Pointer<Void>);
final spGetPortName = _lib.lookupFunction<_SpGetPortNameC, _SpGetPortNameDart>(
  'sp_get_port_name',
);

typedef _SpGetPortDescriptionC = Pointer<Utf8> Function(Pointer<Void>);
typedef _SpGetPortDescriptionDart = Pointer<Utf8> Function(Pointer<Void>);
final spGetPortDescription = _lib
    .lookupFunction<_SpGetPortDescriptionC, _SpGetPortDescriptionDart>(
      'sp_get_port_description',
    );

typedef _SpGetPortTransportC = Int32 Function(Pointer<Void>);
typedef _SpGetPortTransportDart = int Function(Pointer<Void>);
final spGetPortTransport = _lib
    .lookupFunction<_SpGetPortTransportC, _SpGetPortTransportDart>(
      'sp_get_port_transport',
    );

typedef _SpGetPortUsbVidPidC =
    Int32 Function(Pointer<Void>, Pointer<Uint16>, Pointer<Uint16>);
typedef _SpGetPortUsbVidPidDart =
    int Function(Pointer<Void>, Pointer<Uint16>, Pointer<Uint16>);
final spGetPortUsbVidPid = _lib
    .lookupFunction<_SpGetPortUsbVidPidC, _SpGetPortUsbVidPidDart>(
      'sp_get_port_usb_vid_pid',
    );

typedef _SpGetPortUsbBusAddressC =
    Int32 Function(Pointer<Void>, Pointer<Uint8>, Pointer<Uint8>);
typedef _SpGetPortUsbBusAddressDart =
    int Function(Pointer<Void>, Pointer<Uint8>, Pointer<Uint8>);
final spGetPortUsbBusAddress = _lib
    .lookupFunction<_SpGetPortUsbBusAddressC, _SpGetPortUsbBusAddressDart>(
      'sp_get_port_usb_bus_address',
    );

typedef _SpGetPortByNameC =
    Int32 Function(Pointer<Utf8>, Pointer<Pointer<Void>>);
typedef _SpGetPortByNameDart =
    int Function(Pointer<Utf8>, Pointer<Pointer<Void>>);
final spGetPortByName = _lib
    .lookupFunction<_SpGetPortByNameC, _SpGetPortByNameDart>(
      'sp_get_port_by_name',
    );

// ---------- Port Management ----------
typedef _SpOpenC = Int32 Function(Pointer<Void>, Int32);
typedef _SpOpenDart = int Function(Pointer<Void>, int);
final spOpen = _lib.lookupFunction<_SpOpenC, _SpOpenDart>('sp_open');

typedef _SpCloseC = Int32 Function(Pointer<Void>);
typedef _SpCloseDart = int Function(Pointer<Void>);
final spClose = _lib.lookupFunction<_SpCloseC, _SpCloseDart>('sp_close');

typedef _SpFreePortC = Void Function(Pointer<Void>);
typedef _SpFreePortDart = void Function(Pointer<Void>);
final spFreePort = _lib.lookupFunction<_SpFreePortC, _SpFreePortDart>(
  'sp_free_port',
);

typedef _SpFreePortListC = Void Function(Pointer<Pointer<Void>>);
typedef _SpFreePortListDart = void Function(Pointer<Pointer<Void>>);
final spFreePortList = _lib
    .lookupFunction<_SpFreePortListC, _SpFreePortListDart>('sp_free_port_list');

// ---------- Configuration ----------
typedef _SpSetBaudrateC = Int32 Function(Pointer<Void>, Int32);
typedef _SpSetBaudrateDart = int Function(Pointer<Void>, int);
final spSetBaudrate = _lib.lookupFunction<_SpSetBaudrateC, _SpSetBaudrateDart>(
  'sp_set_baudrate',
);

typedef _SpGetBaudrateC = Int32 Function(Pointer<Void>);
typedef _SpGetBaudrateDart = int Function(Pointer<Void>);
final spGetBaudrate = _lib.lookupFunction<_SpGetBaudrateC, _SpGetBaudrateDart>(
  'sp_get_baudrate',
);

typedef _SpSetBitsC = Int32 Function(Pointer<Void>, Int32);
typedef _SpSetBitsDart = int Function(Pointer<Void>, int);
final spSetBits = _lib.lookupFunction<_SpSetBitsC, _SpSetBitsDart>(
  'sp_set_bits',
);

typedef _SpGetBitsC = Int32 Function(Pointer<Void>);
typedef _SpGetBitsDart = int Function(Pointer<Void>);
final spGetBits = _lib.lookupFunction<_SpGetBitsC, _SpGetBitsDart>(
  'sp_get_bits',
);

typedef _SpSetParityC = Int32 Function(Pointer<Void>, Int32);
typedef _SpSetParityDart = int Function(Pointer<Void>, int);
final spSetParity = _lib.lookupFunction<_SpSetParityC, _SpSetParityDart>(
  'sp_set_parity',
);

typedef _SpGetParityC = Int32 Function(Pointer<Void>);
typedef _SpGetParityDart = int Function(Pointer<Void>);
final spGetParity = _lib.lookupFunction<_SpGetParityC, _SpGetParityDart>(
  'sp_get_parity',
);

typedef _SpSetStopbitsC = Int32 Function(Pointer<Void>, Int32);
typedef _SpSetStopbitsDart = int Function(Pointer<Void>, int);
final spSetStopbits = _lib.lookupFunction<_SpSetStopbitsC, _SpSetStopbitsDart>(
  'sp_set_stopbits',
);

typedef _SpGetStopbitsC = Int32 Function(Pointer<Void>);
typedef _SpGetStopbitsDart = int Function(Pointer<Void>);
final spGetStopbits = _lib.lookupFunction<_SpGetStopbitsC, _SpGetStopbitsDart>(
  'sp_get_stopbits',
);

typedef _SpSetFlowcontrolC = Int32 Function(Pointer<Void>, Int32);
typedef _SpSetFlowcontrolDart = int Function(Pointer<Void>, int);
final spSetFlowcontrol = _lib
    .lookupFunction<_SpSetFlowcontrolC, _SpSetFlowcontrolDart>(
      'sp_set_flowcontrol',
    );

typedef _SpGetFlowcontrolC = Int32 Function(Pointer<Void>);
typedef _SpGetFlowcontrolDart = int Function(Pointer<Void>);
final spGetFlowcontrol = _lib
    .lookupFunction<_SpGetFlowcontrolC, _SpGetFlowcontrolDart>(
      'sp_get_flowcontrol',
    );

// ---------- I/O ----------
typedef _SpBlockingReadC =
    Int32 Function(Pointer<Void>, Pointer<Void>, Int32, Uint32);
typedef _SpBlockingReadDart =
    int Function(Pointer<Void>, Pointer<Void>, int, int);
final spBlockingRead = _lib
    .lookupFunction<_SpBlockingReadC, _SpBlockingReadDart>('sp_blocking_read');

typedef _SpBlockingWriteC =
    Int32 Function(Pointer<Void>, Pointer<Void>, Int32, Uint32);
typedef _SpBlockingWriteDart =
    int Function(Pointer<Void>, Pointer<Void>, int, int);
final spBlockingWrite = _lib
    .lookupFunction<_SpBlockingWriteC, _SpBlockingWriteDart>(
      'sp_blocking_write',
    );

typedef _SpInputWaitingC = Int32 Function(Pointer<Void>);
typedef _SpInputWaitingDart = int Function(Pointer<Void>);
final spInputWaiting = _lib
    .lookupFunction<_SpInputWaitingC, _SpInputWaitingDart>('sp_input_waiting');

typedef _SpOutputWaitingC = Int32 Function(Pointer<Void>);
typedef _SpOutputWaitingDart = int Function(Pointer<Void>);
final spOutputWaiting = _lib
    .lookupFunction<_SpOutputWaitingC, _SpOutputWaitingDart>(
      'sp_output_waiting',
    );

typedef _SpFlushC = Int32 Function(Pointer<Void>, Int32);
typedef _SpFlushDart = int Function(Pointer<Void>, int);
final spFlush = _lib.lookupFunction<_SpFlushC, _SpFlushDart>('sp_flush');

typedef _SpDrainC = Int32 Function(Pointer<Void>);
typedef _SpDrainDart = int Function(Pointer<Void>);
final spDrain = _lib.lookupFunction<_SpDrainC, _SpDrainDart>('sp_drain');

// ---------- Signals ----------
typedef _SpGetSignalsC = Int32 Function(Pointer<Void>, Pointer<Uint32>);
typedef _SpGetSignalsDart = int Function(Pointer<Void>, Pointer<Uint32>);
final spGetSignals = _lib.lookupFunction<_SpGetSignalsC, _SpGetSignalsDart>(
  'sp_get_signals',
);

typedef _SpSetDtrC = Int32 Function(Pointer<Void>, Int32);
typedef _SpSetDtrDart = int Function(Pointer<Void>, int);
final spSetDTR = _lib.lookupFunction<_SpSetDtrC, _SpSetDtrDart>('sp_set_dtr');

typedef _SpSetRtsC = Int32 Function(Pointer<Void>, Int32);
typedef _SpSetRtsDart = int Function(Pointer<Void>, int);
final spSetRTS = _lib.lookupFunction<_SpSetRtsC, _SpSetRtsDart>('sp_set_rts');

// ---------- Event Handling ----------
typedef _SpWaitC = Int32 Function(Pointer<Void>, Int32);
typedef _SpWaitDart = int Function(Pointer<Void>, int);
final spWait = _lib.lookupFunction<_SpWaitC, _SpWaitDart>('sp_wait');
