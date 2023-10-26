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
          selectedGender: data['selectedGender'] ?? '',
        );
      }
    }

    // Handle the case where the guardian's data doesn't exist or the user is not authenticated.
    return GuardianProfile(
      firstName: '',
      lastName: '',
      email: '',
      phoneNumber: '',
      selectedGender: '',
    );
  }

  void _editProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return GProfileEditScreen(_guardianProfile);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
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

class GProfileEditScreen extends StatefulWidget {
  final GuardianProfile? initialProfile;

  GProfileEditScreen(this.initialProfile);

  @override
  _GProfileEditScreenState createState() => _GProfileEditScreenState();
}

class _GProfileEditScreenState extends State<GProfileEditScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _selectedGenderController;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(text: widget.initialProfile?.firstName);
    _lastNameController = TextEditingController(text: widget.initialProfile?.lastName);
    _phoneNumberController = TextEditingController(text: widget.initialProfile?.phoneNumber);
    _selectedGenderController = TextEditingController(text: widget.initialProfile?.selectedGender);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _selectedGenderController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Save changes to Firestore
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'fname': _firstNameController.text.trim(),
        'lname': _lastNameController.text.trim(),
        'phonenumber': _phoneNumberController.text.trim(),
        'selectedGender': _selectedGenderController.text.trim(),
      });

      // Pop the edit screen and return to the profile view
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _selectedGenderController,
              decoration: InputDecoration(labelText: 'Selected Gender'),
            ),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

