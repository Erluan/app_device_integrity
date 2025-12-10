import 'package:app_device_integrity/app_device_integrity_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelAppDeviceIntegrity();
  const channel = MethodChannel('app_attestation');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAttestationServiceSupport') {
          return 'UUID_RESPONSE';
        }
        if (methodCall.method == 'generateAssertion') {
          return 'ASSERTION_RESPONSE';
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getAttestationServiceSupport', () async {
    expect(
        await platform.getAttestationServiceSupport(
            challengeString: 'UUID_TEST'),
        'UUID_RESPONSE');
  });

  test('generateAssertion', () async {
    expect(
        await platform.generateAssertion(
            keyID: 'TEST_KEY_ID', clientData: 'test client data for hashing'),
        'ASSERTION_RESPONSE');
  });
}
