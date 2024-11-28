// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCr5hrq0HsKD0Q18r3cYeYJNOl0SufZZBc',
    appId: '1:873941599977:web:3474f763d3c3b1074d9278',
    messagingSenderId: '873941599977',
    projectId: 'food-ordering-app-44344',
    authDomain: 'food-ordering-app-44344.firebaseapp.com',
    storageBucket: 'food-ordering-app-44344.firebasestorage.app',
    measurementId: 'G-KYLDNJ749G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCx972QHoCvwXcZq0clwYwTyKGaghhRQ3w',
    appId: '1:873941599977:android:bafe269a458e3f254d9278',
    messagingSenderId: '873941599977',
    projectId: 'food-ordering-app-44344',
    storageBucket: 'food-ordering-app-44344.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCr5hrq0HsKD0Q18r3cYeYJNOl0SufZZBc',
    appId: '1:873941599977:web:e727444a8c5565e24d9278',
    messagingSenderId: '873941599977',
    projectId: 'food-ordering-app-44344',
    authDomain: 'food-ordering-app-44344.firebaseapp.com',
    storageBucket: 'food-ordering-app-44344.firebasestorage.app',
    measurementId: 'G-MCR8LJK33K',
  );
}