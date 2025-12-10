import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_device_integrity_platform_interface.dart';

/// An implementation of [AppDeviceIntegrityPlatform] that uses method channels.
final class MethodChannelAppDeviceIntegrity
    implements AppDeviceIntegrityPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('app_attestation');

  @override
  Future<String?> getAttestationServiceSupport({
    required String challengeString,
    int? gcp,
  }) {
    return methodChannel.invokeMethod('getAttestationServiceSupport', {
      'challengeString': challengeString,
      'gcp': gcp,
    });
  }

  @override
  Future<String?> generateAssertion({
    required String keyID,
    required String clientData,
  }) {
    return methodChannel.invokeMethod('generateAssertion', {
      'keyID': keyID,
      'clientData': clientData,
    });
  }
}
