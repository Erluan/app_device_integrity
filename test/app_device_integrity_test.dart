import 'package:flutter_test/flutter_test.dart';
import 'package:app_device_integrity/app_device_integrity.dart';
import 'package:app_device_integrity/app_device_integrity_platform_interface.dart';
import 'package:app_device_integrity/app_device_integrity_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppDeviceIntegrityPlatform
    with MockPlatformInterfaceMixin
    implements AppDeviceIntegrityPlatform {
  @override
  Future<String?> getAttestationServiceSupport(
          {required String challengeString, int? gcp}) =>
      Future.value('UUID_RESPONSE');
}

void main() {
  final AppDeviceIntegrityPlatform initialPlatform =
      AppDeviceIntegrityPlatform.instance;

  test('$MethodChannelAppDeviceIntegrity is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAppDeviceIntegrity>());
  });

  test('getAttestationServiceSupport', () async {
    AppDeviceIntegrity appDeviceIntegrityPlugin = AppDeviceIntegrity();
    MockAppDeviceIntegrityPlatform fakePlatform =
        MockAppDeviceIntegrityPlatform();
    AppDeviceIntegrityPlatform.instance = fakePlatform;

    expect(
        await appDeviceIntegrityPlugin.getAttestationServiceSupport(
            challengeString: 'UUID_TEST'),
        '42');
  });
}
