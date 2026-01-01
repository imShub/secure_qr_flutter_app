import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
// ignore: unused_import
import 'package:pointycastle/digests/sha256.dart';
// ignore: unused_import
import 'package:pointycastle/signers/rsa_signer.dart';

import 'constants.dart';

class RsaVerifier {
  static bool verify(Uint8List payload, Uint8List signature) {
    try {
      final publicKey = CryptoConstants.publicKey;
      final signer = Signer('SHA-256/RSA'); // PKCS#1 v1.5 padding with SHA-256

      signer.init(false, PublicKeyParameter(publicKey));

      final signatureObj = RSASignature(signature);

      return signer.verifySignature(payload, signatureObj);
    } catch (e) {
      print('Verification Error: $e');
      return false;
    }
  }
}
