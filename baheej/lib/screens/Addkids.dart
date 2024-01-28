// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:baheej/screens/HomeScreenGaurdian.dart';
// import 'package:baheej/screens/GProfileScreen.dart';
// import 'package:baheej/screens/HistoryScreen.dart';
// import 'dart:math';

// class KidCard extends StatelessWidget {
//   final String name;
//   final int age;

//   KidCard({required this.name, required this.age});
//   final _random = Random();
//   final List<Color> _randomColors = [
//     Color.fromARGB(255, 249, 194, 212),
//     Color.fromARGB(255, 210, 229, 245),
//     const Color.fromARGB(255, 255, 242, 123),
//     // Add more colors if needed
//   ];

//   Color _getRandomColor() {
//     return _randomColors[_random.nextInt(_randomColors.length)];
//   }

//   @override
//   @override
//   Widget build(BuildContext context) {
//     Color randomColor = _getRandomColor();

//     return GestureDetector(
//       onTap: () {
//         // Handle tapping on a kid card
//       },
//       child: Card(
//         elevation: 3,
//         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         color: randomColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Container(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Name: $name',
//                 style: TextStyle(
//                   fontSize: 25,
//                   // fontWeight: FontWeight.bold,
//                   fontFamily: '5yearsoldfont',
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Age: $age',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 4),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AddKidsPage extends StatefulWidget {
//   @override
//   _AddKidsPageState createState() => _AddKidsPageState();
// }

// class _AddKidsPageState extends State<AddKidsPage> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController ageController = TextEditingController();
//   List<String> addedKidNames = [];

//   final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

//   Future<void> _addKidToFirestore(String name, int age) async {
//     try {
//       if (age >= 4 && age <= 17) {
//         final kidCollection = FirebaseFirestore.instance.collection('Kids');

//         final existingKid = await kidCollection
//             .where('userEmail', isEqualTo: currentUserEmail)
//             .where('name', isEqualTo: name)
//             .get();

//         if (existingKid.docs.isNotEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Kid with the same name already exists.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }

//         await kidCollection.add({
//           'name': name,
//           'age': age,
//           'userEmail': currentUserEmail,
//         });

//         addedKidNames.add(name);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Kid "$name" added successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         nameController.text = '';
//         ageController.text = '';
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Age must be between 4 and 17.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error adding kid to Firestore: $e');
//     }
//   }

//   bool isNameValid(String name) {
//     return name.length >= 10 && name.length <= 40;
//   }

//   bool containsOnlyLettersAndSpaces(String name) {
//     return RegExp(r'^[a-zA-Z ]+$').hasMatch(name);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(0, 255, 255, 255),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back,
//               color: const Color.fromARGB(255, 255, 255, 255)),
//           onPressed: () {
//             Navigator.of(context).pop(); // Go back to the previous page
//           },
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/childWaves.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Column(
//           children: <Widget>[
//             Padding(
//               padding: EdgeInsets.all(100.0),
//               child: Text(
//                 'My Kids',
//                 style: TextStyle(
//                   fontSize: 35,
//                   fontFamily: '5yearsoldfont',
//                   // fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(
//                       255, 255, 255, 255), // Change the text color to blue
//                 ),
//               ),
//             ),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('Kids')
//                     .where('userEmail', isEqualTo: currentUserEmail)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return CircularProgressIndicator();
//                   }
//                   final kids = snapshot.data!.docs;
//                   List<Widget> kidWidgets = [];
//                   for (var kid in kids) {
//                     final kidData = kid.data() as Map<String, dynamic>;
//                     final kidName = kidData['name'] as String;
//                     final kidAge = kidData['age'] as int;
//                     kidWidgets.add(
//                       KidCard(name: kidName, age: kidAge),
//                     );
//                   }
//                   return ListView(
//                     children: kidWidgets,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text('Add Kid'),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(labelText: 'Full Name'),
//                       maxLength: 40,
//                     ),
//                     TextField(
//                       controller: ageController,
//                       decoration: InputDecoration(labelText: 'Age'),
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(2),
//                       ],
//                     ),
//                   ],
//                 ),
//                 actions: <Widget>[
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.red,
//                       textStyle: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                     ),
//                     child: Text('Cancel'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.blue,
//                       textStyle: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                     ),
//                     child: Text('Done'),
//                     onPressed: () async {
//                       final name = nameController.text;
//                       final ageStr = ageController.text;

//                       if (name.isEmpty || ageStr.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Name and Age can\'t be empty.'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }

//                       if (!isNameValid(name)) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                                 'Name must be between 10 and 40 characters.'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }

//                       if (!containsOnlyLettersAndSpaces(name)) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Name must contain only letters.'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }

//                       if (addedKidNames.contains(name)) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content:
//                                 Text('Kid with the same name already exists.'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }

//                       final age = int.tryParse(ageStr);
//                       if (age != null && age >= 4 && age <= 17) {
//                         await _addKidToFirestore(name, age);
//                         Navigator.of(context).pop();
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                                 'Invalid age input. Age must be between 4 and 17.'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         child: Icon(Icons.add),
//         backgroundColor: Color.fromARGB(255, 174, 207, 250),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: BottomAppBar(
//         color:
//             Color.fromARGB(255, 255, 255, 255), // Set background color to white
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildIconButtonWithLabel(
//                 Icons.history,
//                 'Bookings',
//                 Color.fromARGB(255, 249, 194, 212),
//                 () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => HistoryScreen()),
//                   );
//                 },
//               ),
//               //   color: Color.fromARGB(
//               //       255, 249, 194, 212), // Set icon color to black
//               //   onPressed: () {
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(builder: (context) => HistoryScreen()),
//               //     );
//               //   },
//               // ),
//               _buildIconButtonWithLabel(
//                 Icons.home,
//                 'Home',
//                 Color.fromARGB(255, 249, 194, 212),
//                 () {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => HomeScreenGaurdian()),
//                     (route) => false,
//                   );
//                 },
//               ),
//               _buildIconButtonWithLabel(
//                 Icons.child_care,
//                 'view Kids',
//                 Color.fromARGB(255, 210, 229, 245),
//                 () {},
//               ),
//               _buildIconButtonWithLabel(
//                 Icons.person,
//                 'Profile',
//                 Color.fromARGB(255, 249, 194, 212),
//                 () {
//                   String currentUserEmail =
//                       FirebaseAuth.instance.currentUser?.email ?? '';
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => GProfileViewScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildIconButtonWithLabel(
//     IconData iconData,
//     String label,
//     Color iconColor,
//     VoidCallback onPressed,
//   ) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: Icon(
//             iconData,
//             size: 35,
//           ),
//           color: iconColor,
//           onPressed: onPressed,
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:baheej/screens/HomeScreenGaurdian.dart';
import 'package:baheej/screens/GProfileScreen.dart';
import 'package:baheej/screens/HistoryScreen.dart';
import 'dart:math';

class KidCard extends StatelessWidget {
  final String name;
  final int age;

  KidCard({required this.name, required this.age});
  final _random = Random();
  final List<Color> _randomColors = [
    Color.fromARGB(255, 252, 222, 233),
    Color.fromARGB(255, 210, 229, 245),
    Color.fromARGB(255, 251, 242, 212),
    // Add more colors if needed
  ];

  Color _getRandomColor() {
    return _randomColors[_random.nextInt(_randomColors.length)];
  }

  @override
  @override
  Widget build(BuildContext context) {
    Color randomColor = _getRandomColor();

    return GestureDetector(
      onTap: () {
        // Handle tapping on a kid card
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: randomColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: $name',
                style: TextStyle(
                  fontSize: 25,
                  // fontWeight: FontWeight.bold,
                  fontFamily: '5yearsoldfont',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Age: $age',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
            image: AssetImage('assets/images/kidW222.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(68.0),
              child: Text(
                'My Kids',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: '5yearsoldfont',
                  // fontWeight: FontWeight.bold,
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
                      decoration: InputDecoration(labelText: 'Full Name'),
                      maxLength: 40,
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
                            content: Text('Name and Age can\'t be empty.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (!isNameValid(name)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Name must be between 10 and 40 characters.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (!containsOnlyLettersAndSpaces(name)) {
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
                      if (age != null && age >= 4 && age <= 17) {
                        await _addKidToFirestore(name, age);
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Invalid age input. Age must be between 4 and 17.'),
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
        backgroundColor: Color.fromARGB(255, 174, 207, 250),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color:
            Color.fromARGB(255, 255, 255, 255), // Set background color to white
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButtonWithLabel(
                Icons.history,
                'Bookings',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
              ),
              //   color: Color.fromARGB(
              //       255, 249, 194, 212), // Set icon color to black
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => HistoryScreen()),
              //     );
              //   },
              // ),
              _buildIconButtonWithLabel(
                Icons.home,
                'Home',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreenGaurdian()),
                    (route) => false,
                  );
                },
              ),
              _buildIconButtonWithLabel(
                Icons.child_care,
                'view Kids',
                Color.fromARGB(255, 210, 229, 245),
                () {},
              ),
              _buildIconButtonWithLabel(
                Icons.person,
                'Profile',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  String currentUserEmail =
                      FirebaseAuth.instance.currentUser?.email ?? '';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GProfileViewScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButtonWithLabel(
    IconData iconData,
    String label,
    Color iconColor,
    VoidCallback onPressed,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            iconData,
            size: 35,
          ),
          color: iconColor,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
