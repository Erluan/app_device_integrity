// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:app_device_integrity/app_device_integrity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getAttestationServiceSupport test', (WidgetTester tester) async {
    const plugin = AppDeviceIntegrity();
    final challengeString =
        'test_challenge_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final attestationToken = await plugin.getAttestationServiceSupport(
        challengeString: challengeString,
      );

      // If we get here without exception, attestation is supported
      // Verify the token is returned
      expect(attestationToken, isNotNull);
      expect(attestationToken, isA<String>());
      debugPrint('Attestation successful: $attestationToken');
    } on PlatformException catch (error) {
      // On iOS simulator and some devices, App Attest is not available
      // Error code -4 means "Failed to initialize AppDeviceIntegrity"
      if (error.code == '-4') {
        debugPrint(
            'App Attest not supported on this device/simulator (expected)');
        // This is expected on simulator, test passes
        expect(error.message, contains('Failed to initialize'));
      } else {
        // Other errors should fail the test
        rethrow;
      }
    }
  });
}
