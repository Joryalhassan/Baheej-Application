import 'package:firebase_auth/firebase_auth.dart';
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
    body: SingleChildScrollView( // Wrap your content in SingleChildScrollView
      child: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/back3.png', // Replace with your image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                   "",
                   style: TextStyle(
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                   ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildStyledTextField(
                    controller: _emailTextController,
                    labelText: "Enter Email",
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomBigButton(
                    text: "Reset Password",
                    onPressed: () {
                      _validateAndResetPassword(context);
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    _infoText, // Display the info text here
                    style: TextStyle(
                      color: Colors.red, // You can style it as needed
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  void _validateAndResetPassword(BuildContext context) async {
    final email = _emailTextController.text;
    final emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regExp = RegExp(emailPattern);

    if (!regExp.hasMatch(email)) {
    setState(() {
      _infoText = "Invalid email format. Please enter a valid email.";
    });
    return;
  }

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

Widget buildStyledTextField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  required String? Function(String?) validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        labelText,
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
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
      ),
      if (validator(" ") != null && validator(" ")!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            validator("") ?? "",
            style: TextStyle(
              color: Colors.red, // Red error text color
              fontSize: 12,
            ),
          ),
        ),
    ],
  );
}


class CustomBigButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomBigButton({
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
