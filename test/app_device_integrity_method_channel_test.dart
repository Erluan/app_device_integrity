import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_device_integrity/app_device_integrity_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAppDeviceIntegrity platform = MethodChannelAppDeviceIntegrity();
  const MethodChannel channel = MethodChannel('app_device_integrity');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getAttestationServiceSupport(challengeString: 'UUID_TEST'), 'UUID_RESPONSE');
  });
}
