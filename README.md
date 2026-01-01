# Secure QR Flutter - Offline Verification & Generation

A high-performance, secure offline QR code scanner and generator built with Flutter. This application implements the logic for decoding, mapping, and verifying **Secure Offline QR Codes** (compliant with UIDAI/Aadhaar specifications) using **RSA-2048** and **SHA-256** signatures.

The app features a premium **Glassmorphism UI** with smooth animations, offering a modern and secure user experience.

## ✨ Features

- **📷 Secure Scanning**: High-speed scanning using `mobile_scanner`.
- **🔐 Offline Verification**: verifys RSA-2048 digital signatures locally without internet access.
- **🛠️ Test Generator**: Built-in tool to generate signed Secure QR codes for testing purposes.
- **💎 Premium UI**: Dark theme, glassmorphism effects (blur/transparency), and interactive animations.
- **📄 Data Mapping**: Automatically maps decompressed `0xFF`-separated data blocks to a structured `SecurePersonModel`.
- **🛡️ Tamper Proof**: Immediately detects modified payloads and flags signatures as invalid.

## 📱 Screenshots

| Scanner | Result (Verified) | Generator |
|:---:|:---:|:---:|
| *(Add Scanner Screenshot)* | *(Add Result Screenshot)* | *(Add Generator Screenshot)* |

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: ^3.6.0
- **Dart SDK**: ^3.2.0
- **Java**: JDK 17 or 21 (Gradle 8.5 configured)
- **Android Device/Emulator**: Min SDK 21 (Android 5.0)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/imShub/secure_qr_flutter_app.git
    cd secure_qr_flutter
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```

## 🔐 Security Architecture

The verifying mechanism follows the **Secure QR Code** standard:

1.  **Transport**: Base64 encoded string.
2.  **Compression**: Gzip/Zip (Optional, currently handling Raw Bytes/Base64 directly in this implementation).
3.  **Structure**: Data is split into 255 (`0xFF`) distinct blocks (Name, DOB, Gender, etc.).
4.  **Signing**:
    - The signature is generated over the **Paylod** (all data blocks excluding the signature itself).
    - Algorithm: `SHA-256` with `RSA-2048`.
5.  **Verification**:
    - The verification logic uses the **Public Key** embedded in the app (`lib/crypto/constants.dart`).
    - Crypto Library: `pointycastle`.

### 🔑 Key Management

The app comes with a **Test Key Pair** for development.

To generate a new RSA-2048 key pair:

1.  Run the included script:
    ```bash
    dart tool/key_generator.dart
    ```
2.  This will automatically update `lib/crypto/constants.dart` with new Public (for app) and Private (for generator) keys.

> **Note**: In a production environment, the App should ONLY contain the UIDAI Public Key. The Private Key should strictly remain on the signing server.

## 📂 Project Structure

```
lib/
├── app/                  # App entry point & routing
├── crypto/               # RSA verification & Key constants
│   ├── rsa_verifier.dart
│   └── constants.dart
├── decoder/              # Base64, Block Splitting & Mapping logic
├── generator/            # Logic & UI for creating Test QRs
├── models/               # Data models (SecurePersonModel)
├── scanner/              # Camera handling & Scanner UI
├── ui/                   # Design System (Theme, GlassCard)
└── main.dart
```

## 📦 Key Dependencies

- [mobile_scanner](https://pub.dev/packages/mobile_scanner): Camera & QR detection.
- [pointycastle](https://pub.dev/packages/pointycastle): Cryptographic primitives (RSA, SHA-256).
- [qr_flutter](https://pub.dev/packages/qr_flutter): Rendering QR codes.
- [google_fonts](https://pub.dev/packages/google_fonts): Typography (Outfit font).

## ⚠️ Compliance

This implementation is based on the **Secure QR Code Specifications**, focusing on:
- Correct block separation (`0xFF`).
- Byte-level signature verification.
- Handling distinct data types (Text vs JPEG Photo).

## 👨‍💻 Author

**Shubham Madhav Waghmare**

Developed with ❤️ and Dart.

<a href="https://www.buymeacoffee.com/imshub" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## 🤝 Contributing

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request
