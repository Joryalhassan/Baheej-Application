import 'package:flutter/material.dart';

class CenterProfileScreen extends StatelessWidget {
  final String centerName;
  final String email;
  final String phoneNumber;
  final String district;
  final String commercialRegister;
  final String description;

  CenterProfileScreen({
    required this.centerName,
    required this.email,
    required this.phoneNumber,
    required this.district,
    required this.commercialRegister,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Center Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Center Name: $centerName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Email: $email', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Phone Number: $phoneNumber', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('District: $district', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Commercial Register: $commercialRegister',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Description: $description', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
