# App Device Integrity
![Build](https://github.com/Erluan/app_device_attest/workflows/Build/badge.svg)
[![pub package]()](https://pub.dartlang.org/app_device_integrity)
<a href="https://discord.gg/p4nzsMU3"><img src="https://img.shields.io/discord/765557403865186374.svg?logo=discord&color=blue" alt="Discord"></a>

This plugin was created to make your app attestation more easy. It uses the Native Attestation Providers from Apple and Google, App Attest and Play Integrity respectively, to generate tokens to be decrypted by your Server to check if your app is beeing accessed by a reliable device.

<a align="center" href="https://www.buymeacoffee.com/erluan" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-yellow.png" alt="Buy Me A Coffee" height="50" width="183"></a><b>

## How to Use It

To use this plugin correctly, you need to contemplate these two steps:

Provide a Session UUID, in iOS Case<br>
Provide your GCP Project ID, in Android Case<br>

**iOS:**<br>
The Session UUID is the challenge created by your server for App Attest to issue the token requested from the device to be "marked".<br>
Basically your server sends the challenge to Apple to ensure that the token is marked with it, attested by the service with it so that when the server receives the token, it was actually sent by the device with that session UUID sent by the server before.

**Android:**<br>
Providing the GCP Project ID links your app with your development and deployment environment. Before you implement it in your project, you need to follow the steps provided by the following doc:<br>
https://developer.android.com/google/play/integrity/setup?set-google-console#set-google-console

To be more "precise", when you link you GCP Project to your app in Google Play Console, the project ID is right beside of your project name. That's the information you need.<br>
It's recommended to create environmental variable with the project ID to maintain your app, and project, integrity.

**Server:**<br>
I am very proud to provide you with an open-source service that you can Attest your implementations in server side.<br>
It checks from which platform the token is sent and verifies the token, providing very important information about risks, enabling better decision-making to reinforce the security of your services.<br>
Fell comfortable to fork it, or clone it, and customize it, according to your business demands.

For more information about App Attest and Play Integrity, you can access the docs from Apple and Google in the links bellow:<br>
https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity
https://developer.android.com/google/play/integrity

