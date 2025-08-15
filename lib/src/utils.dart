import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:convert';

/// Read a null-terminated C string safely, allowing malformed sequences.
/// Works even if the underlying bytes are not valid UTF-8.
String ptrToString(Pointer<Utf8> p, {int maxBytes = 4096}) {
  if (p == nullptr) return '';
  final bytes = <int>[];
  final u8 = p.cast<Uint8>();

  var i = 0;
  while (i < maxBytes) {
    final b = (u8 + i).value;
    if (b == 0) break; // NUL terminator
    bytes.add(b);
    i++;
  }
  // Allow malformed to avoid FormatException on odd device strings/locales.
  return utf8.decode(bytes, allowMalformed: true);
}

/// Allocate a C string from Dart string.
Pointer<Utf8> stringToPtr(String str) {
  return str.toNativeUtf8();
}
