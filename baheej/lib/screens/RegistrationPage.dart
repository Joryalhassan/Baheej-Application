import 'package:flutter/material.dart';
import 'package:baheej/screens/RegistrationFormPage.dart';

class RegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Register as:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle registration as a client
                _navigateToRegistrationForm(context, 'Client');
              },
              child: Text('Register as Client'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle registration as a guardian
                _navigateToRegistrationForm(context, 'Guardian');
              },
              child: Text('Register as Guardian'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRegistrationForm(BuildContext context, String userType) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationFormPage(userType)),
    );
  }
}
