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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyAos_6NS7RdYrmnUR_tfTQzTtthoXa_DC4',
    appId: '1:271694658984:web:9738aa0f5279dc6a1a319d',
    messagingSenderId: '271694658984',
    projectId: 'senturionscalegback',
    authDomain: 'senturionscalegback.firebaseapp.com',
    storageBucket: 'senturionscalegback.appspot.com',
    measurementId: 'G-R6D2WL0J2Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCP8rUFLUqCj7UO_n1ajzxPhCEjOoL4hGs',
    appId: '1:271694658984:android:df5654ea4fc6531b1a319d',
    messagingSenderId: '271694658984',
    projectId: 'senturionscalegback',
    storageBucket: 'senturionscalegback.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4YLahvu5oMtyJdPiJRO8gUBF2xwxhgLY',
    appId: '1:271694658984:ios:c18be36c36311a631a319d',
    messagingSenderId: '271694658984',
    projectId: 'senturionscalegback',
    storageBucket: 'senturionscalegback.appspot.com',
    iosBundleId: 'com.example.senturionscaleg',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD4YLahvu5oMtyJdPiJRO8gUBF2xwxhgLY',
    appId: '1:271694658984:ios:c18be36c36311a631a319d',
    messagingSenderId: '271694658984',
    projectId: 'senturionscalegback',
    storageBucket: 'senturionscalegback.appspot.com',
    iosBundleId: 'com.example.senturionscaleg',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAos_6NS7RdYrmnUR_tfTQzTtthoXa_DC4',
    appId: '1:271694658984:web:8a7170e6bb3e941c1a319d',
    messagingSenderId: '271694658984',
    projectId: 'senturionscalegback',
    authDomain: 'senturionscalegback.firebaseapp.com',
    storageBucket: 'senturionscalegback.appspot.com',
    measurementId: 'G-4HP1XGNPJP',
  );
}
