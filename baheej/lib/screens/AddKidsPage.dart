import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class KidCard extends StatelessWidget {
  final String name;
  final int age;

  KidCard({required this.name, required this.age});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle tapping on a kid card
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Color.fromARGB(255, 251, 241, 241),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: $name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Age: $age',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class AddKidsPage extends StatefulWidget {
  @override
  _AddKidsPageState createState() => _AddKidsPageState();
}

class _AddKidsPageState extends State<AddKidsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  List<String> addedKidNames = [];

  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  Future<void> _addKidToFirestore(String name, int age) async {
    try {
      if (age >= 2 && age <= 12) {
        final kidCollection = FirebaseFirestore.instance.collection('Kids');

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
          'userEmail': currentUserEmail,
        });

        addedKidNames.add(name);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kid "$name" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

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
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black, // Set the icon color to black
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous page
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Kids',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                    KidCard(name: kidName, age: kidAge),
                  );
                }
                return ListView(
                  children: kidWidgets,
                );
              },
            ),
          ),
        ],
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
                      maxLength: 20,
                    ),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
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

                      if (name.isEmpty || ageStr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Name and age can\'t be empty.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

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
