import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AddKidsPage extends StatefulWidget {
  @override
  _AddKidsPageState createState() => _AddKidsPageState();
}

class _AddKidsPageState extends State<AddKidsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  List<String> addedKidNames = []; // Maintain a list of added kid names

  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  Future<void> _addKidToFirestore(String name, int age) async {
    try {
      if (age >= 2 && age <= 12) {
        final kidCollection = FirebaseFirestore.instance.collection('Kids');

        // Check if a kid with the same name exists for the current user's email
        final existingKid = await kidCollection
            .where('userEmail', isEqualTo: currentUserEmail)
            .where('name', isEqualTo: name)
            .get();

        if (existingKid.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kid with the same name already exists.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await kidCollection.add({
          'name': name,
          'age': age,
          'userEmail': currentUserEmail, // Include user's email
        });

        // Add the name to the list of added kid names
        addedKidNames.add(name);

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kid "$name" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the text fields
        nameController.text = '';
        ageController.text = '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Age must be between 2 and 12.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error adding kid to Firestore: $e');
    }
  }

  bool isNameValid(String name) {
    return name.length >= 4 && name.length <= 20;
  }

  bool containsOnlyLetters(String name) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Kids'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Kids')
            .where('userEmail', isEqualTo: currentUserEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final kids = snapshot.data!.docs;
          List<Widget> kidWidgets = [];
          for (var kid in kids) {
            final kidData = kid.data() as Map<String, dynamic>;
            final kidName = kidData['name'] as String;
            final kidAge = kidData['age'] as int;
            kidWidgets.add(
              ListTile(
                title: Text('Name: $kidName'),
                subtitle: Text('Age: $kidAge'),
              ),
            );
          }
          return ListView(
            children: kidWidgets,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Kid'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      maxLength: 20, // Limit to 20 characters
                    ),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                            2), // Limit to 2 characters
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text('Done'),
                    onPressed: () async {
                      final name = nameController.text;
                      final ageStr = ageController.text;

                      // Check for empty fields first
                      if (name.isEmpty || ageStr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Name and age can\'t be empty.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Validate name length
                      if (!isNameValid(name)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Name must be between 4 and 20 characters.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Validate name contains only letters
                      if (!containsOnlyLetters(name)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Name must contain only letters.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (addedKidNames.contains(name)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Kid with the same name already exists.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final age = int.tryParse(ageStr);
                      if (age != null && age >= 2 && age <= 12) {
                        await _addKidToFirestore(name, age);
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Invalid age input. Age must be between 2 and 12.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
