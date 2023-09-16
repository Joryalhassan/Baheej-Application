import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
//import 'package:baheej/screens/HomeScreenGaurdian.dart';
import 'package:baheej/utlis/utilas.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailTextController = TextEditingController();
  String _infoText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Reset Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _emailTextController,
                  decoration: InputDecoration(
                    labelText: "Enter Email Id",
                    icon: Icon(Icons.person_outline),
                    errorText: _infoText.isNotEmpty ? _infoText : null,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    _validateAndResetPassword(context);
                  },
                  child: Text("Reset Password"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndResetPassword(BuildContext context) async {
    final email = _emailTextController.text;

    try {
      // Check if the user with the entered email exists
      final signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (signInMethods.isEmpty) {
        setState(() {
          _infoText = "Email not found. Please enter a valid email.";
        });
      } else {
        // Email exists, send a password reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        setState(() {
          _infoText =
              "Password reset email sent. Please check your email to reset your password.";
        });
      }
    } catch (e) {
      setState(() {
        _infoText = "Error occurred. Please try again later.";
      });
    }
  }
}