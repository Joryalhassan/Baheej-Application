// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
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
    apiKey: 'AIzaSyAINMcQ0b0abG_gwihm8UXz5QOufgoDt58',
    appId: '1:656395346341:web:527aa39e951a3d0b97884c',
    messagingSenderId: '656395346341',
    projectId: 'baheejdatabase',
    authDomain: 'baheejdatabase.firebaseapp.com',
    storageBucket: 'baheejdatabase.appspot.com',
    measurementId: 'G-MWKH7W8X12',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3m6RyQe2HYapnOYKYj7ROmkoCGDCe9Sk',
    appId: '1:656395346341:android:096db054614e7ab297884c',
    messagingSenderId: '656395346341',
    projectId: 'baheejdatabase',
    storageBucket: 'baheejdatabase.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC6j3oo4469M3AVYNxXtzb_sIVzxHb1WOA',
    appId: '1:656395346341:ios:e6f10974ebb585ef97884c',
    messagingSenderId: '656395346341',
    projectId: 'baheejdatabase',
    storageBucket: 'baheejdatabase.appspot.com',
    iosClientId:
        '656395346341-g8b1l4tvp2li3hsnifj7hh6glbshstob.apps.googleusercontent.com',
    iosBundleId: 'com.example.baheej',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC6j3oo4469M3AVYNxXtzb_sIVzxHb1WOA',
    appId: '1:656395346341:ios:05254a787ca6f24397884c',
    messagingSenderId: '656395346341',
    projectId: 'baheejdatabase',
    storageBucket: 'baheejdatabase.appspot.com',
    iosClientId:
        '656395346341-rhkfu4v9ndp2ak2mevpr4c7beh06n5fk.apps.googleusercontent.com',
    iosBundleId: 'com.example.baheej.RunnerTests',
  );
}
