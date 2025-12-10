import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_device_integrity_platform_interface.dart';

final class AppDeviceIntegrity {
  const AppDeviceIntegrity();

  Future<String?> getAttestationServiceSupport({
    required String challengeString,
    int? gcp,
  }) {
    assert(
      !Platform.isAndroid || gcp != null,
      'gcp parameter is required for Android platform',
    );

    return AppDeviceIntegrityPlatform.instance.getAttestationServiceSupport(
        challengeString: challengeString, gcp: gcp);
  }

  /// Generates an assertion for an existing key.
  ///
  /// **iOS only** - This method is only supported on iOS platform.
  ///
  /// [keyID] - The identifier received when generating a cryptographic key.
  /// [clientData] - Unique, single-use data block that will be hashed with SHA256
  ///                and signed with the attested private key. Should be at least 16 bytes.
  ///
  /// Returns a base64-encoded assertion object to send to your server for verification.
  ///
  /// Throws [PlatformException] if called on non-iOS platform.
  Future<String?> generateAssertion({
    required String keyID,
    required String clientData,
  }) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw PlatformException(
        code: 'UNSUPPORTED_PLATFORM',
        message: 'generateAssertion is only supported on iOS platform',
      );
    }

    return AppDeviceIntegrityPlatform.instance.generateAssertion(
      keyID: keyID,
      clientData: clientData,
    );
  }
}
