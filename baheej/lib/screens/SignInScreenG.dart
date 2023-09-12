 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'package:baheej/screens/HomeScreenGaurdian.dart';
import 'package:baheej/screens/ResetPassword.dart';
import 'package:baheej/screens/GSignUpScreen.dart';
import 'package:baheej/utlis/utilas.dart'; // تأكد من استيراد المكتبة الصحيحة

class SignInScreenG extends StatefulWidget {
  const SignInScreenG({Key? key}) : super(key: key);

  @override
  _SignInScreenGState createState() => _SignInScreenGState();
}

class _SignInScreenGState extends State<SignInScreenG> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  String? emailErrorText;
  String? passwordErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
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
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.png"),
                const SizedBox(
                  height: 30,
                ),
                // Email Input Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enter Email", style: TextStyle(color: Colors.white)),
                    TextField(
                      controller: _emailTextController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        errorText:
                            emailErrorText, // Display the email error message
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Password Input Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enter Password",
                        style: TextStyle(color: Colors.white)),
                    TextField(
                      controller: _passwordTextController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        errorText:
                            passwordErrorText, // Display the password error message
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                // Sign-In Button
                firebaseUIButton(context, "Sign In", () {
                  final email = _emailTextController.text.trim();
                  final password = _passwordTextController.text.trim();

                  setState(() {
                    // Reset error messages
                    emailErrorText = null;
                    passwordErrorText = null;
                  });

                  if (email.isEmpty) {
                    setState(() {
                      emailErrorText = 'Email is required';
                    });
                  } else if (!email.contains('@')) {
                    setState(() {
                      emailErrorText = 'Invalid email format';
                    });
                  }

                  if (password.isEmpty) {
                    setState(() {
                      passwordErrorText = 'Password is required';
                    });
                  }

                  if (emailErrorText == null && passwordErrorText == null) {
                    // Both fields are non-empty, and email format is valid
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    )
                        .then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreenGaurdian(),//check if it center or gaurdian
                        ),
                      );
                    }).catchError((error) {
                      print("Error: $error");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Invalid username or password'),
                        backgroundColor: Color.fromARGB(255, 245, 19, 3),
                      ));
                    });
                  }
                }),
                signUpOption(),
                forgetPassword()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GSignUpScreen(),
              ),
            );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }



 Row forgetPassword() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Forget Password?", style: TextStyle(color: Colors.white70)),
      const SizedBox(width: 8), // Add some horizontal spacing
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPassword(),
            ),
          );
        },
        child: const Text(
          "Reset Your Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}
}