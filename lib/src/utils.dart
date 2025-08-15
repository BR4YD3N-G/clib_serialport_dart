import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Convert a [Pointer<Utf8>] to Dart String safely.
String ptrToString(Pointer<Utf8> ptr) {
  if (ptr == nullptr) return '';
  return ptr.toDartString();
}

/// Allocate a C string from Dart string.
Pointer<Utf8> stringToPtr(String str) {
  return str.toNativeUtf8();
}
