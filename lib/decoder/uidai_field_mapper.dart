import 'dart:convert';
import 'dart:typed_data';

import 'package:secure_qr_flutter/models/secure_person_model.dart';

class UidaiFieldMapper {
  /// Maps blocks to SecurePersonModel.
  /// [blocks] - list of blocks split by 0xFF.
  static SecurePersonModel map(List<Uint8List> blocks) {
    if (blocks.length < 18) {
      // Not enough fields for a valid Secure QR (min 18 blocks if signature is 18th)
      // But wait, if photo is split, we have MORE blocks.
      // Only error if we have LESS than expected fixed fields.
      // Indicies 0-15 are fixed. 16 is fixed?
      // [17] is Photo. [18] Signature.
      // So minimum 19 blocks? (0 to 18)
    }

    // Parse Text Fields
    String getString(int index) {
      if (index >= blocks.length) return '';
      try {
        return utf8.decode(blocks[index]);
      } catch (e) {
        return '';
      }
    }

    // Reconstruct Photo
    // Fields 0-16 are text? Playbook says [17] is JPEG.
    // So 0..16 are guaranteed text/reserved.
    // Signature is LAST block.

    int signatureIndex = blocks.length - 1;
    Uint8List signature = blocks[signatureIndex];

    // Photo is blocks 17 to (signatureIndex - 1) joined by 0xFF
    List<int> photoData = [];
    if (blocks.length > 17) {
      for (int i = 17; i < signatureIndex; i++) {
        photoData.addAll(blocks[i]);
        if (i < signatureIndex - 1) {
          photoData.add(0xFF); // Re-add separator
        }
      }
    }

    return SecurePersonModel(
      version: getString(0),
      referenceId: getString(1),
      name: getString(2),
      dob: getString(3),
      gender: getString(4),
      // Reserved [5]
      city: getString(6),
      addressLine1: getString(7),
      addressLine2: getString(8),
      addressLine3: getString(9),
      pin: getString(10),
      state: getString(12),
      // [14] City Repeat?
      district: getString(15), // Area/Sub-district
      photoBytes: Uint8List.fromList(photoData),
      signatureBytes: signature,
    );
  }
}
