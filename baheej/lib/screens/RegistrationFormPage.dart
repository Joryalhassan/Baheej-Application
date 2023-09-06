import 'package:flutter/material.dart';

class RegistrationFormPage extends StatefulWidget {
  final String userType;

  RegistrationFormPage(this.userType);

  @override
  _RegistrationFormPageState createState() => _RegistrationFormPageState();
}

class _RegistrationFormPageState extends State<RegistrationFormPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as ${widget.userType}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Registration as ${widget.userType}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle form submission here
                _registerUser();
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _registerUser() {
    // Retrieve user input from controllers
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Perform registration logic here
    // Depending on the user type (widget.userType), you can decide how to register the user (as a client or guardian).
    // You can use Firebase Auth or any other authentication method.

    // After successful registration, you can navigate the user to the home page or any other relevant screen.
  }
}
