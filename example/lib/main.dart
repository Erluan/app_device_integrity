import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_device_integrity/app_device_integrity.dart';
import 'package:app_device_integrity_example/services/providers/attest_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tokenExample = 'UNKNOWN';
  String _keyID = '';
  String _assertionExample = 'UNKNOWN';
  final _appAttestationPlugin = const AppDeviceIntegrity();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    AttestProvider attestProvider = AttestProvider();

    try {
      String sessionId = await attestProvider.getSession();

      int? gpc = Platform.isAndroid
          ? 0000000000
          : null; // YOUR GCP PROJECT ID IN ANDROID
      if (await _appAttestationPlugin.getAttestationServiceSupport(
              challengeString: sessionId, gcp: gpc)
          case final tokenReceived?) {
        // Try to parse the JSON response to extract keyID
        try {
          final Map<String, dynamic> response = jsonDecode(tokenReceived);
          final String? keyID = response['keyID'] as String?;

          setState(() {
            _tokenExample = tokenReceived;
            if (keyID != null) {
              _keyID = keyID;
            }
          });
        } catch (e) {
          // If parsing fails, just store the token
          setState(() {
            _tokenExample = tokenReceived;
          });
        }
      }
    } on PlatformException {
      debugPrint('Failed to get token.');
    }
  }

  Future<void> generateAssertionExample() async {
    if (_keyID.isEmpty) {
      setState(() {
        _assertionExample = 'No keyID available. Run attestation first.';
      });
      return;
    }

    try {
      // Example client data (will be hashed with SHA256 internally)
      // This should be unique, single-use data block (e.g., timestamp + nonce + request data)
      final clientData =
          'unique-request-${DateTime.now().millisecondsSinceEpoch}';

      if (await _appAttestationPlugin.generateAssertion(
              keyID: _keyID, clientData: clientData)
          case final assertion?) {
        setState(() {
          _assertionExample = assertion;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to generate assertion: ${e.message}');
      setState(() {
        _assertionExample = 'ERROR: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: _tokenExample));
                  },
                  child: Text(
                    'Attestation Token: $_tokenExample',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: generateAssertionExample,
                  child: const Text('Generate Assertion'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: _assertionExample));
                  },
                  child: Text(
                    'Assertion: $_assertionExample',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
