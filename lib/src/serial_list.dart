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
}

List<SerialPortInfo> listSerialPorts() {
  final listPtr = calloc<Pointer<Pointer<Void>>>();
  final r = spListPorts(listPtr);
  if (r != 0) {
    calloc.free(listPtr);
    return [];
  }

  final result = <SerialPortInfo>[];
  var ports = listPtr.value;
  while (ports != nullptr) {
    final port = ports.value;

    final name = ptrToString(spGetPortName(port));
    final desc = ptrToString(spGetPortDescription(port));
    final transport = spGetPortTransport(port);

    final vidPtr = calloc<Uint16>();
    final pidPtr = calloc<Uint16>();
    spGetPortUsbVidPid(port, vidPtr, pidPtr);

    result.add(SerialPortInfo(
      name: name,
      description: desc,
      transport: transport,
      vendorId: vidPtr.value,
      productId: pidPtr.value,
    ));

    calloc.free(vidPtr);
    calloc.free(pidPtr);

    ports += sizeOf<Pointer<Void>>();
  }

  spFreePortList(listPtr.value);
  calloc.free(listPtr);
  return result;
}
