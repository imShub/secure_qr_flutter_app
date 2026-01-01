import 'dart:typed_data';

class BlockSplitter {
  /// Splits the byte stream by 0xFF separator.
  /// Returns a list of Uint8List blocks.
  static List<Uint8List> split(Uint8List bytes) {
    final List<Uint8List> blocks = [];
    final List<int> currentBlock = [];

    for (int b in bytes) {
      if (b == 0xFF) {
        blocks.add(Uint8List.fromList(currentBlock));
        currentBlock.clear();
      } else {
        currentBlock.add(b);
      }
    }
    // Add the final block if exists (usually the signature blocks or photo might end, but 0xFF is separator)
    // The spec says "separated by 0xFF". The last block (Verification Signature) might not have a trailing 0xFF.
    if (currentBlock.isNotEmpty) {
      blocks.add(Uint8List.fromList(currentBlock));
    }

    return blocks;
  }
}
