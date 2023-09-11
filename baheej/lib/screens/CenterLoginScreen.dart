import 'package:flutter/material.dart';

class CenterLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Center Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Center Login Page Content'),
            ElevatedButton(
              onPressed: () {
                // You can add Center Login logic here
              },
              child: Text('Login as Center'),
            ),
          ],
        ),
      ),
    );
  }
}
