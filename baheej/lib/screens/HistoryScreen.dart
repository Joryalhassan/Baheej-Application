import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/Addkids.dart';
import 'package:baheej/screens/HomeScreenGaurdian.dart';
import 'package:baheej/screens/GProfileScreen.dart';
import 'dart:math';

import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/star_rating.dart'; // Replace with the actual path to your StarRating file

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  }

  void _handleAddKids() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddKidsPage(),
      ),
    );
  }

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

  Future<void> cancelService(DocumentSnapshot serviceDocument) async {
    final currentDate = DateTime.now();

    final selectedStartDate =
        (serviceDocument['selectedStartDate'] as Timestamp).toDate();

    final canCancel = currentDate.isBefore(selectedStartDate);

    if (canCancel) {
      try {
        bool confirmCancel = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text('Are you sure you want to cancel your service?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel Program'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Return false when canceled
                  },
                ),
                TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Return true when confirmed
                  },
                ),
              ],
            );
          },
        );

        if (confirmCancel == true) {
          await FirebaseFirestore.instance
              .collection('ServiceBook')
              .doc(serviceDocument.id)
              .delete();

          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Program Canceled Successfully!'),
                content: Text('Your program has been canceled.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );

          setState(() {});
        }
      } catch (error) {
        print('Error canceling service: $error');
      }
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cannot Cancel Program'),
            content: Text(
                'You cannot cancel this program now because the program start.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  final _random = Random();
  final List<Color> _randomColors = [
    Color.fromARGB(255, 250, 207, 221),
    Color.fromARGB(255, 210, 229, 245),
    Color.fromARGB(255, 246, 241, 201),
    // Add more colors if needed
  ];

  Color _getRandomColor() {
    return _randomColors[_random.nextInt(_randomColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    Color randomColor = _getRandomColor();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Bookings",
          style: TextStyle(
            fontFamily: '5yearsoldfont',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/pinkWaves.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: EdgeInsets.only(top: 35),
              color: Colors.transparent,
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('ServiceBook')
                    .where('userEmail', isEqualTo: currentUserEmail)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No booked program found'),
                    );
                  } else {
                    final bookedServices = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: bookedServices.length,
                      itemBuilder: (context, index) {
                        final serviceDocument = bookedServices[index];
                        final randomColor =
                            _getRandomColor(); // Here's the updated line

                        final data =
                            serviceDocument.data() as Map<String, dynamic>;

                        final centerName = data['centerName'];

                        final serviceName = data['serviceName'];

                        final selectedKidsMap =
                            data['selectedKidsNames'] as Map<String, dynamic>?;

                        final selectedStartDate =
                            data['selectedStartDate'] as Timestamp;

                        final selectedEndDate =
                            data['selectedEndDate'] as Timestamp;

                        final totalPrice = data['totalPrice'] as double;

                        final selectedTimeSlot = data['selectedTimeSlot'];

                        final starsrate = data['starsrate'];

                        String selectedKidsString = '';

                        if (selectedKidsMap != null) {
                          selectedKidsString =
                              selectedKidsMap.values.join(', ');
                        }

                        return buildServiceCard(
                          context,
                          centerName,
                          serviceName,
                          selectedKidsString,
                          selectedStartDate.toDate(),
                          selectedEndDate.toDate(),
                          selectedTimeSlot,
                          totalPrice,
                          serviceDocument,
                          starsrate,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          )
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
                Icons.history,
                'Bookings',
                Color.fromARGB(255, 210, 229, 245),
                () {},
              ),
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
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddKidsPage(),
                    ),
                    (route) => false,
                  );
                },
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

  Widget buildServiceCard(
    BuildContext context,
    String centerName,
    String serviceName,
    String selectedKidsString,
    DateTime selectedStartDate,
    DateTime selectedEndDate,
    String selectedTimeSlot,
    double totalPrice,
    DocumentSnapshot serviceDocument,
    int? starsrate,
  ) {
    final startDateFormatted =
        DateFormat('yyyy-MM-dd').format(selectedStartDate);
    final endDateFormatted = DateFormat('yyyy-MM-dd').format(selectedEndDate);
    final randomColor = _getRandomColor();

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 26),
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
              serviceName,
              style: TextStyle(
                fontSize: 25,
                fontFamily: '5yearsoldfont',
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            buildLabelAndValue('Center Name:', centerName),
            buildLabelAndValue('Selected Kids:', selectedKidsString),
            buildLabelAndValue(
                'Period: ', '$startDateFormatted  To  $endDateFormatted'),
            buildLabelAndValue('At:', selectedTimeSlot),
            buildLabelAndValue('Total Price:', '$totalPrice SAR'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Text(
                'Rate the program:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: StarRating(
                serviceDocumentId: serviceDocument.id,
                initialRating: starsrate ?? 0,
                onRatingChanged: (newRating) {
                  print(
                      "you rated with $newRating stars for ${serviceDocument.id}");
                  // Handle the new rating as needed
                },
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  cancelService(serviceDocument);
                },
                child: Text(
                  'Cancel booking',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    // Remove the underline
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLabelAndValue(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 24, 24, 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }
}
