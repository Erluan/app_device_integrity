# App Device Integrity
[![pub package](https://img.shields.io/pub/v/app_device_integrity)](https://pub.dev/packages/app_device_integrity)
[![Licence](https://img.shields.io/github/license/Ileriayo/markdown-badges)](./LICENSE)
<a href="https://discord.gg/8GEp4dgM"><img src="https://img.shields.io/discord/765557403865186374.svg?logo=discord&color=blue" alt="Discord"></a>

<a align="center" href="https://www.buymeacoffee.com/erluan" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-yellow.png" alt="Buy Me A Coffee" height="50" width="183"></a>

<hr>
<hr>

This plugin simplifies app attestation by using Apple's App Attest and Google's Play Integrity to generate tokens for your server to verify device integrity. It ensures your app is being accessed by a reliable, non-compromised device.

## Features

- **iOS App Attest Integration**: Generate attestation tokens and assertions using Apple's App Attest framework
- **Android Play Integrity**: Support for Google Play Integrity API
- **Base64URL Challenge Support**: Automatically handles both plain text and Base64URL encoded challenges
- **Assertion Generation**: Validate previously attested devices with assertion API (iOS only)
- **Swift Package Manager Support**: Modern iOS dependency management (SPM compatible)

## Platform Support

| Platform | Attestation | Assertion | Min Version |
|----------|------------|-----------|-------------|
| iOS      | ✓          | ✓         | iOS 16.0+   |
| Android  | ✓          | -         | API 19+     |

## Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  app_device_integrity: ^1.2.0
```

## How to Use It

### Initial Setup

**iOS:**<br>
The challenge is a unique session identifier created by your server for App Attest. This can be either:
- Plain text string (will be converted to UTF-8 bytes and hashed)
- Base64URL encoded string (will be automatically detected and decoded)

The plugin automatically handles both formats. Your server sends the challenge to Apple to ensure the attestation token is cryptographically bound to it. This prevents replay attacks and ensures the token was generated for this specific session.

**Android:**<br>
You need to provide your GCP (Google Cloud Platform) Project ID to link your app with your development environment.

Before implementing in your project, follow these steps:
1. Visit [Google Play Integrity Setup](https://developer.android.com/google/play/integrity/setup?set-google-console#set-google-console)
2. Link your GCP Project to your app in Google Play Console
3. Find your Project ID next to your project name in the GCP Console
4. It's recommended to store the Project ID as an environment variable

## Implementation

### 1. Generate Initial Attestation Token

Use this when first attesting a device:

```dart
import 'package:app_device_integrity/app_device_integrity.dart';

final deviceIntegrity = AppDeviceIntegrity();

// iOS Example
Future<void> attestDeviceIOS() async {
  try {
    // Challenge from your server (can be plain text or Base64URL)
    final sessionId = '550e8400-e29b-41d4-a716-446655440000';
    
    final tokenJson = await deviceIntegrity.getAttestationServiceSupport(
      challengeString: sessionId,
    );
    
    // Parse the JSON response
    final token = jsonDecode(tokenJson!);
    final attestationString = token['attestationString'];
    final keyID = token['keyID'];
    
    // Send both to your server for verification
    await sendToServer(attestationString, keyID);
  } catch (e) {
    print('Attestation failed: $e');
  }
}

// Android Example  
Future<void> attestDeviceAndroid() async {
  try {
    final sessionId = '550e8400-e29b-41d4-a716-446655440000';
    const gcpProjectId = 123456789; // Your GCP Project ID
    
    final token = await deviceIntegrity.getAttestationServiceSupport(
      challengeString: sessionId,
      gcp: gcpProjectId,
    );
    
    // Send to your server for verification
    await sendToServer(token);
  } catch (e) {
    print('Attestation failed: $e');
  }
}
```

### 2. Generate Assertion for Previously Attested Device (iOS Only)

After initial attestation, use assertions to validate the device without re-attesting:

```dart
Future<void> generateAssertion() async {
  try {
    final deviceIntegrity = AppDeviceIntegrity();
    
    // Use the keyID from initial attestation
    final keyID = 'saved_key_id_from_initial_attestation';
    
    // Client data to sign (can be plain text or Base64URL)
    // Should be at least 16 bytes when hashed with SHA256
    final clientData = 'unique_session_data_${DateTime.now().millisecondsSinceEpoch}';
    
    final assertionString = await deviceIntegrity.generateAssertion(
      keyID: keyID,
      clientData: clientData,
    );
    
    // Send assertion to your server for verification
    await verifyAssertion(assertionString, clientData);
  } on PlatformException catch (e) {
    if (e.code == 'UNSUPPORTED_PLATFORM') {
      print('Assertions are only supported on iOS');
    } else {
      print('Assertion generation failed: ${e.message}');
    }
  }
}
```

### Platform-Specific Implementation

```dart
import 'dart:io';

Future<void> attestDevice() async {
  final deviceIntegrity = AppDeviceIntegrity();
  final sessionId = await getSessionIdFromServer();
  
  if (Platform.isAndroid) {
    const gcpProjectId = 123456789;
    final token = await deviceIntegrity.getAttestationServiceSupport(
      challengeString: sessionId,
      gcp: gcpProjectId,
    );
    return sendToServer(token);
  }
  
  if (Platform.isIOS) {
    final tokenJson = await deviceIntegrity.getAttestationServiceSupport(
      challengeString: sessionId,
    );
    final token = jsonDecode(tokenJson!);
    return sendToServer(token['attestationString'], token['keyID']);
  }
}
```

## Server-Side Verification

I provide an open-source server implementation for token verification:
[App Device Integrity Server](https://github.com/Erluan/app_device_integrity_server)

The server:
- Detects platform (iOS/Android) from the token
- Verifies tokens with Apple/Google services
- Provides risk assessment and device integrity information
- Helps make security decisions based on device trustworthiness

Feel free to fork, clone, and customize it according to your business requirements.

## API Reference

### `getAttestationServiceSupport`

Generates an attestation token for the device.

**Parameters:**
- `challengeString` (required): Session identifier from your server (plain text or Base64URL)
- `gcp` (Android only): Google Cloud Platform Project ID

**Returns:**
- iOS: JSON string with `attestationString` and `keyID`
- Android: Attestation token string

**Example:**
```dart
final token = await deviceIntegrity.getAttestationServiceSupport(
  challengeString: sessionId,
  gcp: 123456789, // Android only
);
```

### `generateAssertion` (iOS Only)

Generates an assertion for a previously attested device.

**Parameters:**
- `keyID` (required): Key identifier from initial attestation
- `clientData` (required): Unique data to sign (min 16 bytes when hashed)

**Returns:**
- Base64-encoded assertion string

**Example:**
```dart
final assertion = await deviceIntegrity.generateAssertion(
  keyID: savedKeyID,
  clientData: sessionData,
);
```

**Throws:**
- `PlatformException` with code `UNSUPPORTED_PLATFORM` on non-iOS platforms

## Error Handling

```dart
try {
  final token = await deviceIntegrity.getAttestationServiceSupport(
    challengeString: sessionId,
  );
} on PlatformException catch (e) {
  switch (e.code) {
    case '-3':
      print('Invalid arguments');
    case '-4':
      print('Device does not support attestation (simulator or old device)');
    case '-5':
      print('Attestation failed');
    default:
      print('Error: ${e.message}');
  }
}
```

## Additional Resources

**Apple App Attest:**<br>
https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity

**Google Play Integrity:**<br>
https://developer.android.com/google/play/integrity

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions:
- GitHub Issues: [Create an issue](https://github.com/Erluan/app_device_integrity/issues)
- Discord: [Join our server](https://discord.gg/8GEp4dgM)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
