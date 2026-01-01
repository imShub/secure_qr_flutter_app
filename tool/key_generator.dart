import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';

void main() {
  final secureRandom = FortunaRandom();
  final random = Random.secure();
  final seeds = List<int>.generate(32, (_) => random.nextInt(255));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  final keyGen = RSAKeyGenerator();
  keyGen.init(ParametersWithRandom(
    RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
    secureRandom,
  ));

  final pair = keyGen.generateKeyPair();
  final public = pair.publicKey as RSAPublicKey;
  final private = pair.privateKey as RSAPrivateKey;

  final fileContent = '''
import 'package:pointycastle/asymmetric/api.dart';

class CryptoConstants {
  static final RSAPublicKey publicKey = RSAPublicKey(
    BigInt.parse('${public.modulus}'),
    BigInt.parse('${public.publicExponent}'),
  );

  static final RSAPrivateKey privateKey = RSAPrivateKey(
    BigInt.parse('${private.modulus}'),
    BigInt.parse('${private.privateExponent}'),
    BigInt.parse('${private.p}'),
    BigInt.parse('${private.q}'),
  );
}
''';

  File('lib/crypto/constants.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync(fileContent);

  print('Keys generated and saved to lib/crypto/constants.dart');
}
