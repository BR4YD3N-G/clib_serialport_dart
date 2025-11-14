import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bindings.dart';
import 'enums.dart';
import 'serial_config.dart';
import 'utils.dart';

class SerialPort {
  final String name;
  Pointer<Void>? _port;

  SerialPort(this.name);

  bool open({SPMode mode = SPMode.readWrite}) {
    final portPtr = calloc<Pointer<Void>>();
    final namePtr = stringToPtr(name);
    final r = spGetPortByName(namePtr, portPtr);
    calloc.free(namePtr);

    if (r != 0) {
      calloc.free(portPtr);
      return false;
    }
    _port = portPtr.value;
    calloc.free(portPtr);

    return spOpen(_port!, mode.value) == 0;
  }

  bool configure(SerialPortConfig cfg) {
    return spSetBaudrate(_port!, cfg.baudRate) == 0 &&
        spSetBits(_port!, cfg.dataBits) == 0 &&
        spSetParity(_port!, cfg.parity.index) == 0 &&
        spSetStopbits(_port!, cfg.stopBits) == 0 &&
        spSetFlowcontrol(_port!, cfg.flowControl.index) == 0;
  }

  int write(List<int> data, {int timeoutMs = 1000}) {
    final buf = calloc<Uint8>(data.length);
    buf.asTypedList(data.length).setAll(0, data);
    final written = spBlockingWrite(
      _port!,
      buf.cast<Void>(),
      data.length,
      timeoutMs,
    );
    calloc.free(buf);
    return written;
  }

  List<int> read(int size, {int timeoutMs = 1000}) {
    final buf = calloc<Uint8>(size);
    final readBytes = spBlockingRead(_port!, buf.cast<Void>(), size, timeoutMs);
    final result = buf.asTypedList(readBytes > 0 ? readBytes : 0).toList();
    calloc.free(buf);
    return result;
  }

  int inputWaiting() => spInputWaiting(_port!);
  int outputWaiting() => spOutputWaiting(_port!);

  void flush(SPBuffer buffer) => spFlush(_port!, buffer.value);
  void drain() => spDrain(_port!);

  void setDTR(bool state) => spSetDTR(_port!, state ? 1 : 0);
  void setRTS(bool state) => spSetRTS(_port!, state ? 1 : 0);

  int getSignals() {
    final sig = calloc<Uint32>();
    spGetSignals(_port!, sig);
    final result = sig.value;
    calloc.free(sig);
    return result;
  }

  void close() {
    if (_port != null) {
      spClose(_port!);
      spFreePort(_port!);
      _port = null;
    }
  }
}
