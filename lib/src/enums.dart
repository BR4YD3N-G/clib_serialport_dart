enum SPReturn {
  ok,
  invalidParameter,
  failure,
  memoryError,
}

enum SPMode {
  read(1),
  write(2),
  readWrite(3);
  final int value;
  const SPMode(this.value);
}

enum SPParity {
  none,
  odd,
  even,
  mark,
  space,
}

enum SPFlowControl {
  none,
  xonxoff,
  rtscts,
  dsrdtr,
}

enum SPBuffer {
  input(1),
  output(2),
  both(3);
  final int value;
  const SPBuffer(this.value);
}

enum SPEvent {
  rxReady(1),
  txReady(2),
  error(4),
  breakEvent(8),
  cts(16),
  dcd(32),
  dsr(64),
  ri(128);
  final int value;
  const SPEvent(this.value);
}
