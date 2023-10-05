import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class KidCard extends StatelessWidget {
  final String Fname;
  final String Lname;
  final int age;

  KidCard({required this.Fname, required this.Lname, required this.age});

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
                'First Name: $Fname',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Last Name: $Lname',
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
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  List<String> addedKidNames = [];

  String? currentUserEmail; // Updated to handle null case

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      currentUserEmail = currentUser.email;
    }
  }

  Future<void> _addKidToFirestore(
      String firstName, String lastName, int age) async {
    try {
      if (age >= 2 && age <= 12) {
        final kidCollection = FirebaseFirestore.instance.collection('Kids');

        // Check for existing kid with the same First Name and Last Name
        final existingKid = await kidCollection
            .where('userEmail', isEqualTo: currentUserEmail)
            .where('firstName', isEqualTo: firstName)
            .where('lastName', isEqualTo: lastName)
            .get();

        if (existingKid.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Kid with the same First Name and Last Name already exists.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await kidCollection.add({
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
          'userEmail': currentUserEmail,
        });

        addedKidNames.add(
            '$firstName $lastName'); // Add the Full Name to the list of added kid names

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kid "$firstName $lastName" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        firstNameController.text = '';
        lastNameController.text = '';
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
          color: Colors.black,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
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
                  final firstName = kidData['firstName'] as String;
                  final lastName = kidData['lastName'] as String;
                  final kidAge = kidData['age'] as int;
                  kidWidgets.add(
                    KidCard(Fname: firstName, Lname: lastName, age: kidAge),
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
                      controller: firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      maxLength: 20,
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
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
                      final firstName = firstNameController.text;
                      final lastName = lastNameController.text;
                      final ageStr = ageController.text;

                      if (firstName.isEmpty ||
                          lastName.isEmpty ||
                          ageStr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'First Name, Last Name, and Age can\'t be empty.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (!isNameValid(firstName) || !isNameValid(lastName)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'First Name and Last Name must be between 4 and 20 characters.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (!containsOnlyLetters(firstName) ||
                          !containsOnlyLetters(lastName)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'First Name and Last Name must contain only letters.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final age = int.tryParse(ageStr);
                      if (age != null && age >= 2 && age <= 12) {
                        final isDuplicate =
                            addedKidNames.contains('$firstName $lastName');
                        if (isDuplicate) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Kid with the same First Name and Last Name already exists.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          await _addKidToFirestore(firstName, lastName, age);
                          Navigator.of(context).pop();
                        }
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

void main() => runApp(MaterialApp(
      home: AddKidsPage(),
      debugShowCheckedModeBanner: false,
    ));
