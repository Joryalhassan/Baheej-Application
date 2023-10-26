import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CenterProfileViewScreen extends StatefulWidget {
  @override
  _CenterProfileViewScreenState createState() =>
      _CenterProfileViewScreenState();
}

class _CenterProfileViewScreenState extends State<CenterProfileViewScreen> {
  CenterProfile? _centerProfile;

  @override
  void initState() {
    super.initState();
    fetchCenterData().then((centerData) {
      setState(() {
        _centerProfile = centerData;
      });
    });
  }

  Future<CenterProfile> fetchCenterData() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('center')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs[0];
        final data = doc.data() as Map<String, dynamic>;

        return CenterProfile(
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          phonenumber: data['phonenumber'] ?? '',
          address: data['adress'] ?? '',
          comReg: data['comReg'] ?? '',
          Desc: data['Desc'] ?? '',
          // Add more fields as needed
        );
      }
    }

    // Handle the case where the center's data doesn't exist or the user is not authenticated.
    return CenterProfile(
      username: '',
      email: '',
      phonenumber: '',
      address: '',
      comReg: '',
      Desc: '',
      // Initialize additional fields as needed
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Center Profile'),
      ),
      body: Center(
        child: _centerProfile != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Center Name: ${_centerProfile?.username}'),
                  Text('Email: ${_centerProfile?.email}'),
                  Text('Phone Number: ${_centerProfile?.phonenumber}'),
                  Text('Address: ${_centerProfile?.address}'),
                  Text('Commercial Register: ${_centerProfile?.comReg}'),
                  Text('Description: ${_centerProfile?.Desc}'),
                  // Add more widgets to display other center data as needed
                ],
              )
            : CircularProgressIndicator(), // Loading indicator while data is being fetched.
      ),
    );
  }
}

class CenterProfile {
  final String username;
  final String email;
  final String phonenumber;
  final String address;
  final String comReg;
  final String Desc;
  // Add more fields as needed

  CenterProfile({
    required this.username,
    required this.email,
    required this.phonenumber,
    required this.address,
    required this.comReg,
    required this.Desc,
    // Initialize additional fields as needed
  });
}
