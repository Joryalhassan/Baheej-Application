import 'package:baheej/firebase_options.dart';
import 'package:baheej/screens/HomeScreenGaurdian.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// import 'package:baheej/screens/SignInScreen.dart';

//jory
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreenGaurdian(),
    );
  }
}
