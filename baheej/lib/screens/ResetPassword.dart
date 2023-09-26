import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailTextController = TextEditingController();
  String _infoText = "";
  Color _infoTextColor = Colors.red; // Color for error messages

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
      body: Stack(
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
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Reset Password",
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
                        if (!isValidEmail(value)) {
                          return "Invalid email format";
                        }
                        return null;
                      },
                      showError: _infoText.isNotEmpty,
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
                      _infoText,
                      style: TextStyle(
                        color: _infoTextColor, // Use the updated color
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to validate email format using regular expression
  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return regex.hasMatch(email);
  }

  void _validateAndResetPassword(BuildContext context) async {
    final email = _emailTextController.text;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('center')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _infoText = "Email not found. Please enter a valid email.";
          _infoTextColor = Colors.red; // Set color for error message
        });
      } else {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        setState(() {
          _infoText =
              "Password reset email sent. Please check your email to reset your password.";
          _infoTextColor = Colors.green; // Set color for success message
        });
      }
    } catch (e) {
      setState(() {
        _infoText = "Error occurred. Please try again later.";
        _infoTextColor = Colors.red; // Set color for error message
      });
    }
  }
}

// Define buildStyledTextField function here
Widget buildStyledTextField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  required String? Function(String?) validator,
  bool showError = false,
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
      if (showError &&
          validator(controller.text) != null &&
          validator(controller.text)!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            validator(controller.text) ?? "",
            style: TextStyle(
              color: Colors.red,
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
