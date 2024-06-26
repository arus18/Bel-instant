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
    apiKey: 'AIzaSyDzej1x673jq3gzKKtlzGmZtwd6dhMhWcU',
    appId: '1:176756455192:web:a04706489ecb807b1b906d',
    messagingSenderId: '176756455192',
    projectId: 'interactive-message-5a9a2',
    authDomain: 'interactive-message-5a9a2.firebaseapp.com',
    databaseURL: 'https://interactive-message-5a9a2.firebaseio.com',
    storageBucket: 'interactive-message-5a9a2.appspot.com',
    measurementId: 'G-DC86W8KSQV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDaXS8X9VTpjSqizvsVbspAW6DJvEL-KG4',
    appId: '1:176756455192:android:1ee061f1e4c7e93f1b906d',
    messagingSenderId: '176756455192',
    projectId: 'interactive-message-5a9a2',
    databaseURL: 'https://interactive-message-5a9a2.firebaseio.com',
    storageBucket: 'interactive-message-5a9a2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4OfiGh6JMTurIJABJMkRBMJJUbiAJHGQ',
    appId: '1:176756455192:ios:820b1c1db2dcd1891b906d',
    messagingSenderId: '176756455192',
    projectId: 'interactive-message-5a9a2',
    databaseURL: 'https://interactive-message-5a9a2.firebaseio.com',
    storageBucket: 'interactive-message-5a9a2.appspot.com',
    androidClientId: '176756455192-c2qjpb3q3et8i8g6gm1m388jnq9jbsur.apps.googleusercontent.com',
    iosBundleId: 'com.example.belInstant',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA4OfiGh6JMTurIJABJMkRBMJJUbiAJHGQ',
    appId: '1:176756455192:ios:820b1c1db2dcd1891b906d',
    messagingSenderId: '176756455192',
    projectId: 'interactive-message-5a9a2',
    databaseURL: 'https://interactive-message-5a9a2.firebaseio.com',
    storageBucket: 'interactive-message-5a9a2.appspot.com',
    androidClientId: '176756455192-c2qjpb3q3et8i8g6gm1m388jnq9jbsur.apps.googleusercontent.com',
    iosBundleId: 'com.example.belInstant',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDzej1x673jq3gzKKtlzGmZtwd6dhMhWcU',
    appId: '1:176756455192:web:3708bcf4f3b693aa1b906d',
    messagingSenderId: '176756455192',
    projectId: 'interactive-message-5a9a2',
    authDomain: 'interactive-message-5a9a2.firebaseapp.com',
    databaseURL: 'https://interactive-message-5a9a2.firebaseio.com',
    storageBucket: 'interactive-message-5a9a2.appspot.com',
    measurementId: 'G-XRE6EQPX11',
  );
}