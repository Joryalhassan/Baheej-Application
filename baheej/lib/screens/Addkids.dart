import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:baheej/screens/HistoryScreen.dart';
import 'package:baheej/screens/HomeScreenGaurdian.dart';

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
        color: Color.fromARGB(255, 239, 249, 254),
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
      if (age >= 4 && age <= 17) {
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
            content: Text('Age must be between 4 and 17.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error adding kid to Firestore: $e');
    }
  }

  bool isNameValid(String name) {
    return name.length >= 10 && name.length <= 40;
  }

  bool containsOnlyLettersAndSpaces(String name) {
    return RegExp(r'^[a-zA-Z ]+$').hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Color.fromARGB(0, 255, 255, 255),
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back,
          color: const Color.fromARGB(255, 255, 255, 255)),
      onPressed: () {
        Navigator.of(context).pop(); // Go back to the previous page
      },
    ),
  ),
  body: Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/backG.png'),
        fit: BoxFit.cover,
      ),
    ),
    child: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(100.0),
          child: Text(
            'My Kids',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(
                  255, 255, 255, 255), // Change the text color to blue
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
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  floatingActionButton: FloatingActionButton(
    backgroundColor: Color.fromARGB(255, 174, 207, 250),
    onPressed: () {
       Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreenGaurdian()),
                );
    },
    child: Icon(
      Icons.home,
      color: Colors.white,
    ),
  ),
  bottomNavigationBar: BottomAppBar(
    shape: CircularNotchedRectangle(),
    color: Color.fromARGB(255, 245, 198, 239),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 24),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.history), // Home Icon
              color: Colors.white, // Set icon color to white
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 5), // Add margin to the top
              child: Text(
                'Booked Service ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        SizedBox(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  1, 50, 17, 1), // Add margin to the top
              child: Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 25),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.person), // Profile Icon
              color: Colors.white, // Set icon color to white
              onPressed: () {
                // _handleAddKids();
              },
            ),
            Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(width: 32),
      ],
    ),
  ),
);

  }
}
