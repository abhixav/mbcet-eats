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
    apiKey: 'AIzaSyDNLbd3P2upzfMcHPUaSSNEL-PrWeNIfNM',
    appId: '1:511029191228:web:5b181b4965d534edcb9939',
    messagingSenderId: '511029191228',
    projectId: 'mbceteats',
    authDomain: 'mbceteats.firebaseapp.com',
    storageBucket: 'mbceteats.firebasestorage.app',
    measurementId: 'G-7FDE9J03JL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACNI-N9230Y-Lqmwzxt_u-8FxkyDegvU4',
    appId: '1:511029191228:android:9a688f4f172cd6cfcb9939',
    messagingSenderId: '511029191228',
    projectId: 'mbceteats',
    storageBucket: 'mbceteats.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBEuaiMK1cTdpVLWBw5M4RB7olnurP2WOE',
    appId: '1:511029191228:ios:eceab94632d0f9fccb9939',
    messagingSenderId: '511029191228',
    projectId: 'mbceteats',
    storageBucket: 'mbceteats.firebasestorage.app',
    iosBundleId: 'com.example.mbcetEats',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBEuaiMK1cTdpVLWBw5M4RB7olnurP2WOE',
    appId: '1:511029191228:ios:eceab94632d0f9fccb9939',
    messagingSenderId: '511029191228',
    projectId: 'mbceteats',
    storageBucket: 'mbceteats.firebasestorage.app',
    iosBundleId: 'com.example.mbcetEats',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDNLbd3P2upzfMcHPUaSSNEL-PrWeNIfNM',
    appId: '1:511029191228:web:de666a2ba60639d9cb9939',
    messagingSenderId: '511029191228',
    projectId: 'mbceteats',
    authDomain: 'mbceteats.firebaseapp.com',
    storageBucket: 'mbceteats.firebasestorage.app',
    measurementId: 'G-BNKB3FZG4H',
  );

}