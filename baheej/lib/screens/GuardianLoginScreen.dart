import 'package:flutter/material.dart';

class GuardianLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Guardian Login Page Content'),
            ElevatedButton(
              onPressed: () {
                // You can add Guardian Login logic here
              },
              child: Text('Login as Guardian'),
            ),
          ],
        ),
      ),
    );
  }
}
