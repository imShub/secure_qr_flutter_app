import 'dart:convert';
import 'dart:typed_data';

class Base64DecoderHelper {
  static Uint8List decode(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      throw FormatException('Invalid Base64 string');
    }
  }
}
