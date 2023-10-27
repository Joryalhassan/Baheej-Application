import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/Service.dart';

class EditServicePopup extends StatefulWidget {
  final Service service;

  EditServicePopup({required this.service});

  @override
  _EditServicePopupState createState() => _EditServicePopupState();
}

class _EditServicePopupState extends State<EditServicePopup> {
  String editedServiceName = '';
  String editedDescription = '';
  DateTime editedStartDate = DateTime.now();
  DateTime editedEndDate = DateTime.now();
  int editedMinAge = 0;
  int editedMaxAge = 0;
  double editedServicePrice = 0.0;
  int editedCapacityValue = 10;
  bool timeSlotSelected = false;
  String userName = '';

  @override
  void initState() {
    super.initState();
    // Initialize the edited values with the current values (you can load these from Firebase if needed)
    editedServiceName = ''; // Load from Firestore
    editedDescription = ''; // Load from Firestore
    editedStartDate = DateTime.now(); // Load from Firestore
    editedEndDate = DateTime.now(); // Load from Firestore
    editedMinAge = 0; // Load from Firestore
    editedMaxAge = 0; // Load from Firestore
    editedServicePrice = 0.0; // Load from Firestore
    editedCapacityValue = 10; // Load from Firestore
    fetchUserName();
  }

  void fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userDoc = await FirebaseFirestore.instance.collection('center').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final centerName = userData['username'] ?? '';
        setState(() {
          userName = centerName;
        });
      }
    }
  }

  void updateServiceInFirebase() async {
    try {
      final serviceRef = FirebaseFirestore.instance.collection('center-service').doc(widget.service.documentId);

      await serviceRef.update({
        'serviceName': editedServiceName,
        'description': editedDescription,
        'centerName': userName,
        'selectedStartDate': editedStartDate.toIso8601String(),
        'selectedEndDate': editedEndDate.toIso8601String(),
        'minAge': editedMinAge,
        'maxAge': editedMaxAge,
        'servicePrice': editedServicePrice,
        'capacityValue': editedCapacityValue,
      });

      print('Service updated in Firestore');

      Navigator.of(context).pop(); // Close the pop-up
    } catch (e) {
      print('Error updating service in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Service Data'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: editedServiceName,
              onChanged: (value) {
                setState(() {
                  editedServiceName = value;
                });
              },
              decoration: InputDecoration(labelText: 'Service Name'),
            ),

            TextFormField(
              initialValue: editedServicePrice.toString(),
              onChanged: (value) {
                setState(() {
                  editedServicePrice = double.tryParse(value) ?? 0.0;
                });
              },
              decoration: InputDecoration(labelText: 'Service Price'),
            ),

            TextFormField(
              initialValue: editedMinAge.toString(),
              onChanged: (value) {
                setState(() {
                  editedMinAge = int.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(labelText: 'Min Age'),
            ),

            TextFormField(
              initialValue: editedMaxAge.toString(),
              onChanged: (value) {
                setState(() {
                  editedMaxAge = int.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(labelText: 'Max Age'),
            ),

            TextFormField(
              initialValue: editedCapacityValue.toString(),
              onChanged: (value) {
                setState(() {
                  editedCapacityValue = int.tryParse(value) ?? 0;
                });
              },
              decoration: InputDecoration(labelText: 'Service Capacity'),
            ),

            TextFormField(
              initialValue: editedDescription,
              onChanged: (value) {
                setState(() {
                  editedDescription = value;
                });
              },
              decoration: InputDecoration(labelText: 'Service Description'),
            ),

            TextFormField(
              initialValue: DateFormat('MM/dd/yyyy').format(editedStartDate),
              onChanged: (value) {
                // Handle date input (parse and set DateTime)
                final date = DateFormat('MM/dd/yyyy').parse(value);
                setState(() {
                  editedStartDate = date;
                });
              },
              decoration: InputDecoration(labelText: 'Start Date (MM/dd/yyyy)'),
            ),

            TextFormField(
              initialValue: DateFormat('MM/dd/yyyy').format(editedEndDate),
              onChanged: (value) {
                // Handle date input (parse and set DateTime)
                final date = DateFormat('MM/dd/yyyy').parse(value);
                setState(() {
                  editedEndDate = date;
                });
              },
              decoration: InputDecoration(labelText: 'End Date (MM/dd/yyyy)'),
            ),

            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirmation'),
                    content: Text('Are you sure you want to change service data?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the confirmation dialog
                        },
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Save the edited data to Firebase
                          updateServiceInFirebase();
                        },
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
