import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddKidsPage extends StatefulWidget {
  @override
  _AddKidsPageState createState() => _AddKidsPageState();
}

class _AddKidsPageState extends State<AddKidsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  Future<void> _addKidToFirestore(String name, int age) async {
    try {
      final kidCollection = FirebaseFirestore.instance.collection('Kids');
      await kidCollection.add({
        'name': name,
        'age': age,
      });
    } catch (e) {
      print('Error adding kid to Firestore: $e');
    }
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
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text('Done'),
                    onPressed: () async {
                      final name = nameController.text;
                      final ageStr = ageController.text;

                      if (name.isNotEmpty && ageStr.isNotEmpty) {
                        final age = int.tryParse(ageStr);
                        if (age != null) {
                          await _addKidToFirestore(name, age);
                          Navigator.of(context).pop();
                        } else {
                          // Handle invalid age input
                          // Show an error message or alert the user
                        }
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
