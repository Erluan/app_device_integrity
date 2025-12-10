import 'package:app_device_integrity/app_device_integrity.dart';
import 'package:app_device_integrity/app_device_integrity_method_channel.dart';
import 'package:app_device_integrity/app_device_integrity_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppDeviceIntegrityPlatform
    with MockPlatformInterfaceMixin
    implements AppDeviceIntegrityPlatform {
  @override
  Future<String?> getAttestationServiceSupport({
    required String challengeString,
    int? gcp,
  }) =>
      Future.value('42');

  @override
  Future<String?> generateAssertion({
    required String keyID,
    required String clientData,
  }) =>
      Future.value('mock_assertion_response');
}

void main() {
  final AppDeviceIntegrityPlatform initialPlatform =
      AppDeviceIntegrityPlatform.instance;

  test('$MethodChannelAppDeviceIntegrity is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAppDeviceIntegrity>());
  });

  test('getAttestationServiceSupport', () async {
    AppDeviceIntegrity appDeviceIntegrityPlugin = const AppDeviceIntegrity();
    MockAppDeviceIntegrityPlatform fakePlatform =
        MockAppDeviceIntegrityPlatform();
    AppDeviceIntegrityPlatform.instance = fakePlatform;

    expect(
        await appDeviceIntegrityPlugin.getAttestationServiceSupport(
            challengeString: 'UUID_TEST'),
        '42');
  });

  test('generateAssertion', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    const appDeviceIntegrityPlugin = AppDeviceIntegrity();
    final fakePlatform = MockAppDeviceIntegrityPlatform();
    AppDeviceIntegrityPlatform.instance = fakePlatform;

    expect(
      await appDeviceIntegrityPlugin.generateAssertion(
        keyID: 'TEST_KEY_ID',
        clientData: 'test client data for hashing',
      ),
      'mock_assertion_response',
    );

    debugDefaultTargetPlatformOverride = null;
  });
}
