import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GProfileViewScreen extends StatefulWidget {
  @override
  _GProfileViewScreenState createState() => _GProfileViewScreenState();
}

class _GProfileViewScreenState extends State<GProfileViewScreen> {
  GuardianProfile? _guardianProfile;

  @override
  void initState() {
    super.initState();
    fetchGuardianData().then((guardianData) {
      setState(() {
        _guardianProfile = guardianData;
      });
    });
  }

  Future<GuardianProfile> fetchGuardianData() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs[0];
        final data = doc.data() as Map<String, dynamic>;

        return GuardianProfile(
          firstName: data['fname'] ?? '',
          lastName: data['lname'] ?? '',
          email: data['email'] ?? '',
          phoneNumber: data['phonenumber'] ?? '',
          selectedGender: data['selectedGender'] ?? '', // Retrieve selectedGender
        );
      }
    }

    // Handle the case where the guardian's data doesn't exist or the user is not authenticated.
    return GuardianProfile(
      firstName: '',
      lastName: '',
      email: '',
      phoneNumber: '',
      selectedGender: '', // Set selectedGender to an empty string
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Profile'),
      ),
      body: Center(
        child: _guardianProfile != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('First Name: ${_guardianProfile?.firstName}'),
                  Text('Last Name: ${_guardianProfile?.lastName}'),
                  Text('Email: ${_guardianProfile?.email}'),
                  Text('Phone Number: ${_guardianProfile?.phoneNumber}'),
                  Text('Gender: ${_guardianProfile?.selectedGender}'),
                  // Add more widgets to display other guardian data as needed
                ],
              )
            : CircularProgressIndicator(), // You can use a loading indicator while data is being fetched.
      ),
    );
  }
}

class GuardianProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String selectedGender;

  GuardianProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.selectedGender,
  });
}
