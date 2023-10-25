import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GProfileViewScreen extends StatefulWidget {
  @override
  _GProfileViewScreenState createState() => _GProfileViewScreenState();
}




class _GProfileViewScreenState extends State<GProfileViewScreen> {
  late String currentUserEmail;
  String? firstName;
  String? lastName;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    // Get the current user's email from Firebase Authentication
    currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    fetchGuardianProfileData();
  }

  Future<void> fetchGuardianProfileData() async {
    // Fetch guardian's information from Firestore based on email
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserEmail)
          .get();

      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['fname'];
          lastName = userDoc['lname'];
          phoneNumber = userDoc['phonenumber'];
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(currentUserEmail),
            SizedBox(height: 20),
            Text(
              'First Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(firstName ?? 'Not available'),
            SizedBox(height: 20),
            Text(
              'Last Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(lastName ?? 'Not available'),
            SizedBox(height: 20),
            Text(
              'Phone Number',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(phoneNumber ?? 'Not available'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GProfileEditScreen(
                      email: currentUserEmail,
                      firstName: firstName ?? '',
                      lastName: lastName ?? '',
                      phoneNumber: phoneNumber ?? '',
                    ),
                  ),
                );
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}




class GProfileEditScreen extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  GProfileEditScreen({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  @override
  _GProfileEditScreenState createState() => _GProfileEditScreenState();
}

class _GProfileEditScreenState extends State<GProfileEditScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing data
    firstNameController.text = widget.firstName;
    lastNameController.text = widget.lastName;
    phoneNumberController.text = widget.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(widget.email),
            SizedBox(height: 20),
            Text(
              'First Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: firstNameController),
            SizedBox(height: 20),
            Text(
              'Last Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: lastNameController),
            SizedBox(height: 20),
            Text(
              'Phone Number',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: phoneNumberController),
            ElevatedButton(
              onPressed: () {
                // Save the edited information back to Firestore
                updateGuardianProfileData();
                Navigator.pop(context); // Go back to the view profile screen
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateGuardianProfileData() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.email).update({
        'fname': firstNameController.text,
        'lname': lastNameController.text,
        'phonenumber': phoneNumberController.text,
      });
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of controllers
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}


