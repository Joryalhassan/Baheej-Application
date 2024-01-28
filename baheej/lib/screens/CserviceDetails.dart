import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/CenterProfileScreen.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/EditService.dart';
import 'package:baheej/screens/compSerList.dart';
// import math , create random colors card
import 'dart:math';

class CserviceDetails extends StatefulWidget {
  final Service service;

  CserviceDetails({required this.service});

  @override
  _CserviceDetailsState createState() => _CserviceDetailsState();
}

class _CserviceDetailsState extends State<CserviceDetails> {
  late Service _serviceDetails;

  @override
  void initState() {
    super.initState();
    _serviceDetails = widget.service;
  }

  void _updateServiceDetails(Service updatedService) {
    setState(() {
      _serviceDetails = updatedService;
    });
  }

  //void _showAdMessageDialog() {//comJo
  //showDialog(
  //context: context,
  //builder: (BuildContext context) {
  //return AlertDialog(
  //  title: Text('Create Advertisement'),
  // content: TextField(
  //controller: adMessageController,
  //  decoration: InputDecoration(
  //   hintText: 'Enter your advertisement message',
  //   ),
  //  ),
  //  actions: <Widget>[
  // TextButton(
  //     child: Text('Cancel'),
  //    onPressed: () {
  //    Navigator.of(context).pop();
  // },
  //),
  // TextButton(
  //  child: Text('Submit'),
  //  onPressed: () async {
  // String adMessage = adMessageController.text.trim();
  //if (adMessage.isNotEmpty) {
  // Store ad message in Firestore under 'notification2' collection
  // await FirebaseFirestore.instance
  // .collection('notification2')
  // .add({
  //   'message': adMessage,
  //   'timestamp': DateTime.now(),
  //  });
  //   adMessageController.clear(); // Clear the text field
  //       Navigator.of(context).pop(); // Close the dialog
  //     }
  //      },
  //    ),
  //   ],
  //  );
  //  },
  // );
  //}
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are You Sure?'),
          content: Text('Do you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseAuth.instance.signOut();
                  showLogoutSuccessDialog();
                } catch (e) {
                  print("Error signing out: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showLogoutSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Successful'),
          content: Text('You have successfully logged out.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                navigateToSignInScreen();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToSignInScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false, // Remove all routes in the stack
    );
  }

  void _dummyServiceAddedFunction() {
    // This function intentionally left blank.
  } //add by jo to fix serviceadding

  //function to create random colors of card
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          SizedBox(width: 60),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_serviceDetails.serviceName} Details',
                  style: const TextStyle(
                    //   fontFamily: '5yearsoldfont', // Use the defined font family
                    fontSize: 25, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                    //EdgeInsets.only(right: 100.0),

                    fontFamily:
                        '5yearsoldfont', // Use the font family name declared in pubspec.yaml
                  ),
                  //  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _handleLogout();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mom.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 250, left: 16, right: 16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: GestureDetector(
                      onTap: () {
                        // Handle tapping on a service
                      },
                      child: Card(
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color:
                            _getRandomColor(), // Get a random color for each card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Program name: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _serviceDetails.serviceName,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Start Date: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MM/dd/yyyy').format(
                                        _serviceDetails.selectedStartDate),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'End Date: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MM/dd/yyyy').format(
                                        _serviceDetails.selectedEndDate),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Program Time: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _serviceDetails.selectedTimeSlot,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Description: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _serviceDetails.description,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Minimum Age: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _serviceDetails.minAge.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Maximum Age: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _serviceDetails.maxAge.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Capacity : ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _serviceDetails.capacityValue.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Participant Number : ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _serviceDetails.participateNo.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Program Price: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_serviceDetails.servicePrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditService(
                                        service: _serviceDetails,
                                        onUpdateService: _updateServiceDetails,
                                      ),
                                    ),
                                  );
                                },
                                child:
                                    Icon(Icons.edit), // Edit icon on the left
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color:
            Color.fromARGB(255, 255, 255, 255), // Set background color to white
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButtonWithLabel(
                Icons.query_stats,
                'Program Statistics',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => compSerListScreen(
                          centerName: widget.service.centerName),
                    ),
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
                Color.fromARGB(255, 210, 229, 245),
                () {
                  // Handle onPressed action
                },
              ),
              _buildIconButtonWithLabel(
                Icons.add,
                'Add Program',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceFormScreen(
                          onServiceAdded: _dummyServiceAddedFunction),
                    ),
                  );
                },
              ),
              _buildIconButtonWithLabel(
                Icons.person,
                'Profile',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CenterProfileViewScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
