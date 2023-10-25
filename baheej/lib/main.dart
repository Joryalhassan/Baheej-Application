import 'package:baheej/firebase_options.dart';
import 'package:baheej/screens/HistoryScreen.dart';
import 'package:baheej/screens/HomeScreenGaurdian.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'BAHEEJ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      

      //home:  HistoryScreen(),
           home:  SignInScreen(),
 
    );
  }
}

