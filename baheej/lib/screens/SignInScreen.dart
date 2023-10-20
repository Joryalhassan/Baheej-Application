import 'package:baheej/screens/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import " HomeScreenCenter.dart";
import 'HomeScreenGaurdian.dart';
import 'ResetPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _performSignIn() async {
    final email = _emailTextController.text.trim();
    final password = _passwordTextController.text.trim();

    setState(() {
      emailErrorText = null;
      passwordErrorText = null;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        emailErrorText = email.isEmpty ? 'Email is required' : null;
        passwordErrorText = password.isEmpty ? 'Password is required' : null;
      });
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        emailErrorText = 'Invalid email format';
      });
    } else {
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;

        if (user != null) {
          final centerDoc = await FirebaseFirestore.instance
              .collection('center')
              .doc(user.uid)
              .get();

          final usersDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (centerDoc.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          } else if (usersDoc.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenGaurdian(),
              ),
            );
          } else {
            // Handle unknown user type or user not found
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          // Invalid email or password
          setState(() {
            emailErrorText = 'Email or password is incorrect';
            passwordErrorText = 'Email or password is incorrect';
          });
        } else {
          print('Error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign In",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            "assets/images/backLo.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).size.height * 0.15,
                20,
                0,
              ),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "assets/images/logo2.png",
                    width: 100.0,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildEmailField(),
                  const SizedBox(
                    height: 20,
                  ),
                  buildPasswordField(),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    text: "Sign In",
                    onPressed: _performSignIn,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  signUpOption(),
                  SizedBox(
                    height: 5,
                  ),
                  forgetPassword(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter Email ID",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: TextField(
            controller: _emailTextController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      emailErrorText != null ? Colors.red : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      emailErrorText != null ? Colors.red : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
        if (emailErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              emailErrorText!,
              style: TextStyle(
                color: Colors.red, // Red error text color
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Column buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter Password",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: TextField(
            controller: _passwordTextController,
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: passwordErrorText != null
                      ? Colors.red
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: passwordErrorText != null
                      ? Colors.red
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
        if (passwordErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              passwordErrorText!,
              style: TextStyle(
                color: Colors.red, // Red error text color
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterPage(),
              ),
            );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  Row forgetPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Forget Password?",
          style: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
        ),
        const SizedBox(width: 8),
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
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 59, 138, 207),
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        minimumSize: Size(200.0, 50.0),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}
