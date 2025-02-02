// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBnBFgAmaNS-qSrc3sa97Ntl6cuhQKiRZM',
    appId: '1:1094199968652:web:01609d47fb0fb9a9938ca9',
    messagingSenderId: '1094199968652',
    projectId: 'schedulesnap',
    authDomain: 'schedulesnap.firebaseapp.com',
    storageBucket: 'schedulesnap.appspot.com',
    measurementId: 'G-KPK6YJ48ZQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrt0Aub3OXHn0f_7AWo384s3bm3csjWm4',
    appId: '1:1094199968652:android:084c2fb21fc874f9938ca9',
    messagingSenderId: '1094199968652',
    projectId: 'schedulesnap',
    storageBucket: 'schedulesnap.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAnz8fI85SgFPR9MH7zE0MHbl0oGgecMvM',
    appId: '1:1094199968652:ios:d65a0c6f75098400938ca9',
    messagingSenderId: '1094199968652',
    projectId: 'schedulesnap',
    storageBucket: 'schedulesnap.appspot.com',
    androidClientId: '1094199968652-fb994in2m2qrfovq4ai81769pogk86dq.apps.googleusercontent.com',
    iosClientId: '1094199968652-ok8bes9c5lp7skj23f42j9fpmorvdhgv.apps.googleusercontent.com',
    iosBundleId: 'com.example.scheduleSnap',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAnz8fI85SgFPR9MH7zE0MHbl0oGgecMvM',
    appId: '1:1094199968652:ios:d65a0c6f75098400938ca9',
    messagingSenderId: '1094199968652',
    projectId: 'schedulesnap',
    storageBucket: 'schedulesnap.appspot.com',
    androidClientId: '1094199968652-fb994in2m2qrfovq4ai81769pogk86dq.apps.googleusercontent.com',
    iosClientId: '1094199968652-ok8bes9c5lp7skj23f42j9fpmorvdhgv.apps.googleusercontent.com',
    iosBundleId: 'com.example.scheduleSnap',
  );
}
