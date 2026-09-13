import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Firebase is not configured for this platform yet.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCzoKqA1xSptwXnJcp798WigaCtHmsAiZU",
    appId: "1:439239340333:web:364febc1920872992ba3a4",
    messagingSenderId: "439239340333",
    projectId: "sport-team-manager-ca6c3",
    authDomain: "sport-team-manager-ca6c3.firebaseapp.com",
    storageBucket: "sport-team-manager-ca6c3.firebasestorage.app",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBWHZunPQKxH_UZSnjxoAxt4TPIeiE6A8E",
    appId: "1:439239340333:android:5466a9d03adcf6be2ba3a4",
    messagingSenderId: "439239340333",
    projectId: "sport-team-manager-ca6c3",
    storageBucket: "sport-team-manager-ca6c3.firebasestorage.app",
  );
}
