// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct..

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baheej/screens/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:baheej/screens/HomeScreenCenter.dart';
import 'package:baheej/screens/HomeScreenGaurdian.dart';


// import 'package:baheej/screens/login_register_page.dart';


import 'package:baheej/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

// class WidgetTree extends StatefulWidget {
//   WidgetTree({Key? key}) : super(key: key);
//   @override
//   State<WidgetTree> createState() => _WidgetTreeState();
// }

// class _WidgetTreeState extends State<WidgetTree> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: Auth().authStateChanges,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return HomePage();
//         } else {
//           return const LoginPage();
//         }
//       },
//     );
//   }
// }
