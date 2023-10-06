import 'package:flutter/material.dart';
import 'package:baheej/screens/GSignUpScreen.dart';
import 'package:baheej/screens/Csignup.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  final Color buttonColor = Color.fromARGB(255, 58, 138, 207); // Darker shade

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register ',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Image.asset(
            "assets/images/backLo.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Register as:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  buildCustomButton(
                    text: 'Center',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CsignUpScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  buildCustomButton(
                    text: 'Guardian',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GSignUpScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary:
            Color.fromARGB(255, 59, 138, 207), // Change to your desired color
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(30.0), // Adjust the shape as needed
        ),
        minimumSize: Size(200.0, 50.0), // Adjust the size as needed
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.0, // Change the font size as needed
        ),
      ),
    );
  }
}