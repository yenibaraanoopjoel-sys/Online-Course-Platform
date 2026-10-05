// PLACEHOLDER — Replace this file with the output of `flutterfire configure`
// or paste your firebase_options.dart content here.
//
// To generate this file:
//   1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
//   2. Run: flutterfire configure
//   3. Select your Firebase project
//   4. This file will be auto-generated
//
// DO NOT commit real Firebase credentials to public repositories.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured. Run flutterfire configure.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS not configured. Run flutterfire configure.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows not configured. Run flutterfire configure.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux not configured. Run flutterfire configure.');
      default:
        throw UnsupportedError('Unknown platform. Run flutterfire configure.');
    }
  }

  // ── Production Firebase Project Configuration ────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCO1DQXhK3fbNPT0N3w0RkqfIVq3xtKIdQ',
    appId: '1:506735022105:web:82372c941762530f6b9a88',
    messagingSenderId: '506735022105',
    projectId: 'onilne-course-platform',
    authDomain: 'onilne-course-platform.firebaseapp.com',
    storageBucket: 'onilne-course-platform.firebasestorage.app',
    measurementId: 'G-KX5JCSDV4S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCO1DQXhK3fbNPT0N3w0RkqfIVq3xtKIdQ',
    appId: '1:506735022105:web:82372c941762530f6b9a88',
    messagingSenderId: '506735022105',
    projectId: 'onilne-course-platform',
    storageBucket: 'onilne-course-platform.firebasestorage.app',
  );
  // ───────────────────────────────────────────────────────────────────────────
}
