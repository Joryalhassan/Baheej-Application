import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CenterProfileScreen extends StatefulWidget {
  const CenterProfileScreen({Key? key}) : super(key: key);

  @override
  _CenterProfileScreenState createState() => _CenterProfileScreenState();
}

class _CenterProfileScreenState extends State<CenterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _phoneNumTextController = TextEditingController();
  TextEditingController _descriptionTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the user's profile information from Firestore
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('center')
        .doc(user?.uid)
        .get();
    if (userData.exists) {
      final data = userData.data() as Map<String, dynamic>;
      setState(() {
        _userNameTextController.text = data['username'];
        _emailTextController.text = data['email'];
        _phoneNumTextController.text = data['phonenumber'];
        _descriptionTextController.text = data['Desc'];
      });
    }
  }

  Future<void> saveProfileChanges() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('center')
          .doc(user?.uid)
          .update({
        'username': _userNameTextController.text.trim(),
        'email': _emailTextController.text.trim(),
        'phonenumber': _phoneNumTextController.text.trim(),
        'Desc': _descriptionTextController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Center Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userNameTextController,
                decoration: InputDecoration(labelText: 'Center Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Center Name is required';
                  }
                  // Add other validation rules here
                  return null;
                },
              ),
              TextFormField(
                controller: _emailTextController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  // Add email validation here
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumTextController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone Number is required';
                  }
                  // Add phone number validation here
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionTextController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  // Add description validation rules here
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: saveProfileChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
