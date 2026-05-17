import 'dart:async';
void main() async {
  try {
    await Future.delayed(Duration(seconds: 10)).timeout(Duration(seconds: 5));
  } catch (e) {
    print("Future timeout: $e");
  }

  try {
    final stream = StreamController<int>().stream;
    await stream.timeout(Duration(seconds: 5)).first;
  } catch (e) {
    print("Stream timeout: $e");
  }
}
