import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddKidsPage extends StatefulWidget {
  @override
  _AddKidsPageState createState() => _AddKidsPageState();
}

class _AddKidsPageState extends State<AddKidsPage> {
  TextEditingController nameController = TextEditingController();
  int age = 2; // Initialize age with 0
  String? errorText; // Error text for age validation

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 4 || value.length > 25) {
      return 'Name must be between 4 and 25 letters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name should only contain letters';
    }

    return null;
  }

  String? _validateAge(int value) {
    if (value < 2 || value > 12) {
      return 'Age must be between 2 and 12';
    }

    return null;
  }

  Future<void> _addKidToFirestore(String name, int age) async {
    try {
      final kidCollection = FirebaseFirestore.instance.collection('Kids');

      // Check if a kid with the same name already exists
      final querySnapshot =
          await kidCollection.where('name', isEqualTo: name).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Kid with the same name already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A kid with this name already exists.'),
          ),
        );
      } else {
        // Kid with the same name doesn't exist, proceed to add

        // Validate age before adding
        final ageValidationMessage = _validateAge(age);
        if (ageValidationMessage != null) {
          setState(() {
            errorText = ageValidationMessage;
          });
        } else {
          // Reset the error text if age is valid
          setState(() {
            errorText = null;
          });

          await kidCollection.add({
            'name': name,
            'age': age,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kid added successfully.'),
            ),
          );

          // Clear the name field and reset age
          nameController.clear();
          setState(() {
            age = 0;
          });
        }
      }
    } catch (e) {
      print('Error adding kid to Firestore: $e');
    }
  }

  Widget buildIncrementDecrementField(
    String label,
    int value,
    void Function() onIncrement,
    void Function() onDecrement,
    String? Function(int value)? validator, // Add a validator parameter
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    onDecrement();
                  });
                },
              ),
              Container(
                width: 100,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    errorText: validator != null
                        ? validator(value)
                        : null, // Use the validator
                  ),
                  // Value is now controlled by the value variable
                  controller: TextEditingController(text: value.toString()),
                  readOnly: true, // Make the field read-only
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    onIncrement();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Kids'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Kids').snapshots(),
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
                      decoration: InputDecoration(
                        labelText: 'Name',
                        counterText: '', // Remove the character count
                      ),
                      maxLength: 25, // Set the maximum length to 25 characters
                    ),
                    buildIncrementDecrementField(
                      'Age',
                      age,
                      () {
                        // Increment age
                        setState(() {
                          if (age < 12) {
                            age++;
                          }
                        });
                      },
                      () {
                        // Decrement age (ensure it doesn't go below 2)
                        setState(() {
                          if (age > 2) {
                            age--;
                          }
                        });
                      },
                      (value) {
                        // Validator function for age
                        if (value < 2 || value > 12) {
                          return 'Age must be between 2 and 12';
                        }
                        return null; // No error if it's within the valid range
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .red, // Set the button's background color to red
                      textStyle: TextStyle(
                        fontSize: 16, // Set the font size
                        fontWeight: FontWeight.bold, // Set the font weight
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ), // Set padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // Set button's border radius
                      ),
                    ),
                    child: Text('Cancel'), // Text for the Cancel button
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Close the dialog without saving
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .blue, // Set the button's background color to blue
                      textStyle: TextStyle(
                        fontSize: 16, // Set the font size
                        fontWeight: FontWeight.bold, // Set the font weight
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ), // Set padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // Set button's border radius
                      ),
                    ),
                    child: Text('Done'), // Text for the Done button
                    onPressed: () async {
                      final name = nameController.text;
                      final ageValidationMessage = _validateAge(age);
                      final nameValidationMessage = _validateName(name);
                      if (name.isNotEmpty &&
                          ageValidationMessage == null &&
                          nameValidationMessage == null) {
                        await _addKidToFirestore(name, age);
                        Navigator.of(context)
                            .pop(); // Close the dialog after saving
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
