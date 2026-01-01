import 'dart:typed_data';

class SecurePersonModel {
  final String version;
  final String referenceId;
  final String name;
  final String dob;
  final String gender;
  final String city;
  final String addressLine1;
  final String addressLine2;
  final String addressLine3;
  final String pin;
  final String state;
  final String district; // Mapping to 15 Area/Sub-district or City repeat?
  // Playbook says: [6] City, [14] City (repeat), [15] Area/Sub-district
  // We'll store what we find.
  final String subDistrict;
  final Uint8List? photoBytes;
  final Uint8List? signatureBytes;

  SecurePersonModel({
    this.version = '',
    this.referenceId = '',
    this.name = '',
    this.dob = '',
    this.gender = '',
    this.city = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.addressLine3 = '',
    this.pin = '',
    this.state = '',
    this.district = '',
    this.subDistrict = '',
    this.photoBytes,
    this.signatureBytes,
  });

  @override
  String toString() {
    return 'SecurePersonModel(name: $name, dob: $dob, gender: $gender, pin: $pin)';
  }
}
