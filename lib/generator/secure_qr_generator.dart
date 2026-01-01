import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
// ignore: unused_import
import 'package:pointycastle/digests/sha256.dart';
// ignore: unused_import
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:secure_qr_flutter/crypto/constants.dart';
import 'package:secure_qr_flutter/models/secure_person_model.dart';

class SecureQrGenerator {
  static String generate(SecurePersonModel person, Uint8List photoBytes) {
    // 1. Prepare Fields (0 to 16)
    List<Uint8List> blocks = List.generate(17, (index) => Uint8List(0));

    void setBlock(int index, String value) {
      if (index < 17) {
        blocks[index] = utf8.encode(value);
      }
    }

    setBlock(0, person.version);
    setBlock(1, person.referenceId);
    setBlock(2, person.name);
    setBlock(3, person.dob);
    setBlock(4, person.gender);
    setBlock(5, ""); // Reserved
    setBlock(6, person.city);
    setBlock(7, person.addressLine1);
    setBlock(8, person.addressLine2);
    setBlock(9, person.addressLine3);
    setBlock(10, person.pin);
    // 11 is implicit empty
    setBlock(12, person.state);
    // 13 is implicit empty
    setBlock(14, person.city); // Repeat
    setBlock(15, person.district);
    // 16 is implicit empty (or reserved)

    // 2. Join Fields with 0xFF
    BytesBuilder payloadBuilder = BytesBuilder();
    for (int i = 0; i < blocks.length; i++) {
      payloadBuilder.add(blocks[i]);
      payloadBuilder.addByte(0xFF);
    }

    // 3. Append Photo (Block 17)
    // Note: The loop above added 0xFF after the last text block (16).
    // So we are ready to append Photo.
    payloadBuilder.add(photoBytes);

    // This is the "Data to Sign".
    // Playbook: "Hash payload using SHA-256... Sign hash".
    // "Append signature".
    // AND "Extract payload bytes (before final 0xFF)".
    // So there must be a 0xFF after photo.

    Uint8List dataToSign = payloadBuilder.toBytes();

    // 4. Sign
    Uint8List signature = _sign(dataToSign);

    // 5. Final Assembly: Data + 0xFF + Signature
    BytesBuilder finalBuilder = BytesBuilder();
    finalBuilder.add(dataToSign);
    finalBuilder.addByte(0xFF);
    finalBuilder.add(signature);

    return base64Encode(finalBuilder.toBytes());
  }

  static Uint8List _sign(Uint8List data) {
    final privateKey = CryptoConstants.privateKey;
    final signer = Signer('SHA-256/RSA');
    signer.init(true, PrivateKeyParameter(privateKey));
    final sig = signer.generateSignature(data);
    return (sig as RSASignature).bytes;
  }
}
