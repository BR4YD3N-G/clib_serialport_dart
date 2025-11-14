import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bindings.dart';
import 'utils.dart';

class SerialPortInfo {
  final String name;
  final String description;
  final int transport;
  final int vendorId;
  final int productId;

  SerialPortInfo({
    required this.name,
    required this.description,
    required this.transport,
    required this.vendorId,
    required this.productId,
  });

  @override
  String toString() =>
      '$name (desc="$description", transport=$transport, vid=${vendorId.toRadixString(16)}, pid=${productId.toRadixString(16)})';
}

List<SerialPortInfo> listSerialPorts() {
  final listPtrPtr = calloc<Pointer<Pointer<Void>>>();
  try {
    final rc = spListPorts(listPtrPtr);
    if (rc != 0) {
      return const <SerialPortInfo>[];
    }

    final listPtr = listPtrPtr.value; // sp_port** (null-terminated)
    final out = <SerialPortInfo>[];

    var i = 0;
    while (true) {
      final portPtr = (listPtr + i).value; // ✅ new indexing API
      if (portPtr == nullptr) break;

      final name = ptrToString(spGetPortName(portPtr));
      final desc = ptrToString(spGetPortDescription(portPtr));
      final transport = spGetPortTransport(portPtr);

      // VID/PID may not exist for non-USB transports; guard the call.
      final vidPtr = calloc<Uint16>();
      final pidPtr = calloc<Uint16>();
      var vid = 0;
      var pid = 0;
      try {
        final usbRc = spGetPortUsbVidPid(portPtr, vidPtr, pidPtr);
        if (usbRc == 0) {
          vid = vidPtr.value;
          pid = pidPtr.value;
        }
      } finally {
        calloc.free(vidPtr);
        calloc.free(pidPtr);
      }

      out.add(
        SerialPortInfo(
          name: name,
          description: desc,
          transport: transport,
          vendorId: vid,
          productId: pid,
        ),
      );

      i++;
    }

    spFreePortList(listPtr);
    return out;
  } finally {
    calloc.free(listPtrPtr);
  }
}
