import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:secure_qr_flutter/crypto/rsa_verifier.dart';
import 'package:secure_qr_flutter/decoder/base64_decoder.dart';
import 'package:secure_qr_flutter/decoder/block_splitter.dart';
import 'package:secure_qr_flutter/decoder/uidai_field_mapper.dart';
import 'package:secure_qr_flutter/generator/secure_qr_generator.dart';
import 'package:secure_qr_flutter/models/secure_person_model.dart';

void main() {
  test('Full Flow: Generate -> Decode -> Verify', () {
    // 1. Setup Data
    final person = SecurePersonModel(
      version: "V1",
      referenceId: "REF123",
      name: "Test User",
      dob: "01-01-1990",
      gender: "M",
      city: "Test City",
      addressLine1: "Addr1",
      pin: "123456",
      state: "Test State",
    );
    final photoBytes = Uint8List.fromList([0x10, 0x20, 0x30]); // Dummy photo

    // 2. Generate
    print("Generating QR...");
    final qrBase64 = SecureQrGenerator.generate(person, photoBytes);
    print("Generated Base64 length: ${qrBase64.length}");

    // 3. Decode
    print("Decoding...");
    final rawBytes = Base64DecoderHelper.decode(qrBase64);
    final blocks = BlockSplitter.split(rawBytes);
    print("Split into ${blocks.length} blocks");

    // 4. Map
    final decodedPerson = UidaiFieldMapper.map(blocks);
    print("Decoded Name: ${decodedPerson.name}");

    expect(decodedPerson.name, equals("Test User"));
    expect(decodedPerson.pin, equals("123456"));

    // 5. Verify Signature
    print("Verifying Signature...");
    // Re-extract payload
    final signature = decodedPerson.signatureBytes!;
    // Payload is rawBytes minus (signature + 0xFF)
    // We assume 1 byte separator.
    final payloadLen = rawBytes.length - signature.length - 1;
    final payload = rawBytes.sublist(0, payloadLen);

    final isValid = RsaVerifier.verify(payload, signature);
    print("Is Valid: $isValid");

    expect(isValid, isTrue);
  });

  test('Tampered Data Fails Verification', () {
    final person = SecurePersonModel(name: "Original");
    final photo = Uint8List(1);
    final qrBase64 = SecureQrGenerator.generate(person, photo);

    var rawBytes = Base64DecoderHelper.decode(qrBase64);

    // Tamper with the payload (change a byte in the name field)
    // Name is early in the stream.
    rawBytes[10] = rawBytes[10] ^ 0xFF; // Flip bits

    final blocks = BlockSplitter.split(rawBytes);
    final decodedPerson = UidaiFieldMapper.map(blocks);

    final signature = decodedPerson.signatureBytes!;
    final payloadLen = rawBytes.length - signature.length - 1;
    final payload = rawBytes.sublist(0, payloadLen);

    final isValid = RsaVerifier.verify(payload, signature);
    print("Tampered Valid: $isValid");

    expect(isValid, isFalse);
  });
}
