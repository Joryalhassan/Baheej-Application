import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'package:baheej/screens/home-page.dart';
//import 'package:baheej/screens/reset_password.dart';
import 'package:baheej/screens/signup.dart';
import 'package:baheej/utlis/utilas.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  String? emailErrorText;
  String? passwordErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          builder: (context) => HomeScreen(),
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
                signUpOption()
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
                builder: (context) => SignUpScreen(),
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
}


  // Widget forgetPassword(BuildContext context) {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     height: 35,
  //     alignment: Alignment.bottomRight,
  //     child: TextButton(
  //       child: const Text(
  //         "Forgot Password?",
  //         style: TextStyle(color: Colors.white70),
  //         textAlign: TextAlign.right,
  //       ),
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ResetPassword(),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

