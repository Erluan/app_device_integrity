import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_device_integrity_method_channel.dart';

abstract interface class AppDeviceIntegrityPlatform extends PlatformInterface {
  /// Constructs a AppAttestationPlatform.
  AppDeviceIntegrityPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppDeviceIntegrityPlatform _instance =
      MethodChannelAppDeviceIntegrity();

  /// The default instance of [AppAttestationPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppAttestation].
  static AppDeviceIntegrityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppAttestationPlatform] when
  /// they register themselves.
  static set instance(AppDeviceIntegrityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getAttestationServiceSupport({
    required String challengeString,
    int? gcp,
  });

  Future<String?> generateAssertion({
    required String keyID,
    required String clientData,
  });
}
