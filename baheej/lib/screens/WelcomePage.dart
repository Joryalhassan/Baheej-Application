import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:baheej/screens/home-page.dart';
//import 'package:baheej/screens/SignInScreenC.dart';
import 'package:baheej/screens/SignInScreen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  // void _loginAsCenter(BuildContext context) {
  //   // Implement Center Login logic here
  //   // You can navigate to the Center Login screen or perform other actions.
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>
  //           SignInScreenC(), // Replace with the actual Center Login screen.
  //     ),
  //   );
  // }

  void _loginAsGuardian(BuildContext context) {
    // Implement Guardian Login logic here
    // You can navigate to the Guardian Login screen or perform other actions.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SignInScreenG(), // Replace with the actual Guardian Login screen.
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFCB2B93),
              Color(0xFF9546C4),
              Color(0xFF5E61F4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                // Your logoWidget here if needed
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    //_loginAsCenter(context);
                  },
                  child: Text('Center '),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    _loginAsGuardian(context);
                  },
                  child: Text('Guardian '),
                ),
                // signUpOption(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
