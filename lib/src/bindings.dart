import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

String _archSuffix() {
  final ver = Platform.version.toLowerCase();

  if (ver.contains('arm64') || ver.contains('aarch64')) {
    return '_arm64';
  }
  if (ver.contains('x86_64') || ver.contains('amd64')) {
    return '';
  }
  throw UnsupportedError('Unsupported architecture: $ver');
}

DynamicLibrary _openLib() {
  const base = 'native';
  final arch = _archSuffix();

  if (Platform.isMacOS) {
    final path = '$base/macos/libserialport${arch.isEmpty ? '' : arch}.dylib';
    return DynamicLibrary.open(path);
  }
  if (Platform.isLinux) {
    final path = '$base/linux/libserialport${arch.isEmpty ? '' : arch}.so';
    return DynamicLibrary.open(path);
  }
  if (Platform.isWindows) {
    // Windows will just have x86_64 for now
    return DynamicLibrary.open('$base/windows/libserialport-0.dll');
  }
  throw UnsupportedError('Unsupported platform');
}

final _lib = _openLib();

// ---------- Port Enumeration ----------
typedef _sp_list_ports_c = Int32 Function(Pointer<Pointer<Pointer<Void>>>);
typedef _sp_list_ports_dart = int Function(Pointer<Pointer<Pointer<Void>>>);
final spListPorts = _lib
    .lookupFunction<_sp_list_ports_c, _sp_list_ports_dart>('sp_list_ports');

typedef _sp_get_port_name_c = Pointer<Utf8> Function(Pointer<Void>);
typedef _sp_get_port_name_dart = Pointer<Utf8> Function(Pointer<Void>);
final spGetPortName = _lib
    .lookupFunction<_sp_get_port_name_c, _sp_get_port_name_dart>('sp_get_port_name');

typedef _sp_get_port_description_c = Pointer<Utf8> Function(Pointer<Void>);
typedef _sp_get_port_description_dart = Pointer<Utf8> Function(Pointer<Void>);
final spGetPortDescription = _lib
    .lookupFunction<_sp_get_port_description_c, _sp_get_port_description_dart>('sp_get_port_description');

typedef _sp_get_port_transport_c = Int32 Function(Pointer<Void>);
typedef _sp_get_port_transport_dart = int Function(Pointer<Void>);
final spGetPortTransport = _lib
    .lookupFunction<_sp_get_port_transport_c, _sp_get_port_transport_dart>('sp_get_port_transport');

typedef _sp_get_port_usb_vid_pid_c = Int32 Function(
    Pointer<Void>, Pointer<Uint16>, Pointer<Uint16>);
typedef _sp_get_port_usb_vid_pid_dart = int Function(
    Pointer<Void>, Pointer<Uint16>, Pointer<Uint16>);
final spGetPortUsbVidPid = _lib
    .lookupFunction<_sp_get_port_usb_vid_pid_c, _sp_get_port_usb_vid_pid_dart>('sp_get_port_usb_vid_pid');

typedef _sp_get_port_usb_bus_address_c = Int32 Function(
    Pointer<Void>, Pointer<Uint8>, Pointer<Uint8>);
typedef _sp_get_port_usb_bus_address_dart = int Function(
    Pointer<Void>, Pointer<Uint8>, Pointer<Uint8>);
final spGetPortUsbBusAddress = _lib
    .lookupFunction<_sp_get_port_usb_bus_address_c, _sp_get_port_usb_bus_address_dart>('sp_get_port_usb_bus_address');

typedef _sp_get_port_by_name_c = Int32 Function(
    Pointer<Utf8>, Pointer<Pointer<Void>>);
typedef _sp_get_port_by_name_dart = int Function(
    Pointer<Utf8>, Pointer<Pointer<Void>>);
final spGetPortByName = _lib
    .lookupFunction<_sp_get_port_by_name_c, _sp_get_port_by_name_dart>('sp_get_port_by_name');

// ---------- Port Management ----------
typedef _sp_open_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_open_dart = int Function(Pointer<Void>, int);
final spOpen =
    _lib.lookupFunction<_sp_open_c, _sp_open_dart>('sp_open');

typedef _sp_close_c = Int32 Function(Pointer<Void>);
typedef _sp_close_dart = int Function(Pointer<Void>);
final spClose =
    _lib.lookupFunction<_sp_close_c, _sp_close_dart>('sp_close');

typedef _sp_free_port_c = Void Function(Pointer<Void>);
typedef _sp_free_port_dart = void Function(Pointer<Void>);
final spFreePort =
    _lib.lookupFunction<_sp_free_port_c, _sp_free_port_dart>('sp_free_port');

typedef _sp_free_port_list_c = Void Function(Pointer<Pointer<Void>>);
typedef _sp_free_port_list_dart = void Function(Pointer<Pointer<Void>>);
final spFreePortList = _lib
    .lookupFunction<_sp_free_port_list_c, _sp_free_port_list_dart>('sp_free_port_list');

// ---------- Configuration ----------
typedef _sp_set_baudrate_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_set_baudrate_dart = int Function(Pointer<Void>, int);
final spSetBaudrate =
    _lib.lookupFunction<_sp_set_baudrate_c, _sp_set_baudrate_dart>('sp_set_baudrate');

typedef _sp_get_baudrate_c = Int32 Function(Pointer<Void>);
typedef _sp_get_baudrate_dart = int Function(Pointer<Void>);
final spGetBaudrate =
    _lib.lookupFunction<_sp_get_baudrate_c, _sp_get_baudrate_dart>('sp_get_baudrate');

typedef _sp_set_bits_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_set_bits_dart = int Function(Pointer<Void>, int);
final spSetBits =
    _lib.lookupFunction<_sp_set_bits_c, _sp_set_bits_dart>('sp_set_bits');

typedef _sp_get_bits_c = Int32 Function(Pointer<Void>);
typedef _sp_get_bits_dart = int Function(Pointer<Void>);
final spGetBits =
    _lib.lookupFunction<_sp_get_bits_c, _sp_get_bits_dart>('sp_get_bits');

typedef _sp_set_parity_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_set_parity_dart = int Function(Pointer<Void>, int);
final spSetParity =
    _lib.lookupFunction<_sp_set_parity_c, _sp_set_parity_dart>('sp_set_parity');

typedef _sp_get_parity_c = Int32 Function(Pointer<Void>);
typedef _sp_get_parity_dart = int Function(Pointer<Void>);
final spGetParity =
    _lib.lookupFunction<_sp_get_parity_c, _sp_get_parity_dart>('sp_get_parity');

typedef _sp_set_stopbits_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_set_stopbits_dart = int Function(Pointer<Void>, int);
final spSetStopbits =
    _lib.lookupFunction<_sp_set_stopbits_c, _sp_set_stopbits_dart>('sp_set_stopbits');

typedef _sp_get_stopbits_c = Int32 Function(Pointer<Void>);
typedef _sp_get_stopbits_dart = int Function(Pointer<Void>);
final spGetStopbits =
    _lib.lookupFunction<_sp_get_stopbits_c, _sp_get_stopbits_dart>('sp_get_stopbits');

typedef _sp_set_flowcontrol_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_set_flowcontrol_dart = int Function(Pointer<Void>, int);
final spSetFlowcontrol =
    _lib.lookupFunction<_sp_set_flowcontrol_c, _sp_set_flowcontrol_dart>('sp_set_flowcontrol');

typedef _sp_get_flowcontrol_c = Int32 Function(Pointer<Void>);
typedef _sp_get_flowcontrol_dart = int Function(Pointer<Void>);
final spGetFlowcontrol =
    _lib.lookupFunction<_sp_get_flowcontrol_c, _sp_get_flowcontrol_dart>('sp_get_flowcontrol');

// ---------- I/O ----------
typedef _sp_blocking_read_c = Int32 Function(Pointer<Void>, Pointer<Void>, Int32, Uint32);
typedef _sp_blocking_read_dart = int Function(Pointer<Void>, Pointer<Void>, int, int);
final spBlockingRead =
    _lib.lookupFunction<_sp_blocking_read_c, _sp_blocking_read_dart>('sp_blocking_read');

typedef _sp_blocking_write_c = Int32 Function(Pointer<Void>, Pointer<Void>, Int32, Uint32);
typedef _sp_blocking_write_dart = int Function(Pointer<Void>, Pointer<Void>, int, int);
final spBlockingWrite =
    _lib.lookupFunction<_sp_blocking_write_c, _sp_blocking_write_dart>('sp_blocking_write');

typedef _sp_input_waiting_c = Int32 Function(Pointer<Void>);
typedef _sp_input_waiting_dart = int Function(Pointer<Void>);
final spInputWaiting =
    _lib.lookupFunction<_sp_input_waiting_c, _sp_input_waiting_dart>('sp_input_waiting');

typedef _sp_output_waiting_c = Int32 Function(Pointer<Void>);
typedef _sp_output_waiting_dart = int Function(Pointer<Void>);
final spOutputWaiting =
    _lib.lookupFunction<_sp_output_waiting_c, _sp_output_waiting_dart>('sp_output_waiting');

typedef _sp_flush_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_flush_dart = int Function(Pointer<Void>, int);
final spFlush =
    _lib.lookupFunction<_sp_flush_c, _sp_flush_dart>('sp_flush');

typedef _sp_drain_c = Int32 Function(Pointer<Void>);
typedef _sp_drain_dart = int Function(Pointer<Void>);
final spDrain =
    _lib.lookupFunction<_sp_drain_c, _sp_drain_dart>('sp_drain');

// ---------- Signals ----------
typedef _sp_get_signals_c = Int32 Function(Pointer<Void>, Pointer<Uint32>);
typedef _sp_get_signals_dart = int Function(Pointer<Void>, Pointer<Uint32>);
final spGetSignals =
    _lib.lookupFunction<_sp_get_signals_c, _sp_get_signals_dart>('sp_get_signals');

typedef _sp_set_dtr_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_set_dtr_dart = int Function(Pointer<Void>, int);
final spSetDTR =
    _lib.lookupFunction<_sp_set_dtr_c, _sp_set_dtr_dart>('sp_set_dtr');

typedef _sp_set_rts_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_set_rts_dart = int Function(Pointer<Void>, int);
final spSetRTS =
    _lib.lookupFunction<_sp_set_rts_c, _sp_set_rts_dart>('sp_set_rts');

// ---------- Event Handling ----------
typedef _sp_wait_c = Int32 Function(Pointer<Void>, Int32);
typedef _sp_wait_dart = int Function(Pointer<Void>, int);
final spWait =
    _lib.lookupFunction<_sp_wait_c, _sp_wait_dart>('sp_wait');
