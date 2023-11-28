import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/Addkids.dart';
import 'package:baheej/screens/star_rating.dart'; // Replace with the actual path to your StarRating file
import 'package:baheej/screens/GProfileScreen.dart';
import 'package:baheej/screens/HomeScreenGaurdian.dart';
import 'package:baheej/screens/SignInScreen.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    void _handleAddKids() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddKidsPage(),
        ),
      );
    }

    void navigateToSignInScreen() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
        (route) =>
            false, // Replace the current route and prevent back navigation
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Booked Programs"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
              'assets/images/backG.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
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
                    child: Text('No booked services found'),
                  );
                } else {
                  final bookedServices = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: bookedServices.length,
                    itemBuilder: (context, index) {
                      final serviceDocument = bookedServices[index];
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
                        selectedKidsString = selectedKidsMap.values.join(', ');
                      }

                      return buildServiceCard(
                        centerName,
                        serviceName,
                        selectedKidsString,
                        selectedStartDate.toDate(),
                        selectedEndDate.toDate(),
                        selectedTimeSlot,
                        totalPrice,
                        serviceDocument,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
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
                  icon: Icon(Icons.home),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreenGaurdian(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    '         Home        ',
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
                  padding: EdgeInsets.fromLTRB(1, 50, 17, 1),
                  child: Text(
                    'View Kids',
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
                  icon: Icon(Icons.person),
                  color: Colors.white,
                  onPressed: () {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 174, 207, 250),
        onPressed: () {
          _handleAddKids();
        },
        child: Icon(
          Icons.add_reaction_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildServiceCard(
    String centerName,
    String serviceName,
    String selectedKidsString,
    DateTime selectedStartDate,
    DateTime selectedEndDate,
    String selectedTimeSlot,
    double totalPrice,
    DocumentSnapshot serviceDocument,
  ) {
    final startDateFormatted =
        DateFormat('yyyy-MM-dd').format(selectedStartDate);
    final endDateFormatted = DateFormat('yyyy-MM-dd').format(selectedEndDate);

    final cardMargin = EdgeInsets.fromLTRB(20, 10, 16, 0);
    final isStartDateInPast = selectedStartDate.isBefore(DateTime.now());
    final data = serviceDocument.data() as Map<String, dynamic>;
    final starsrate = data['starsrate'] ?? 0;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 239, 249, 254),
              const Color.fromARGB(255, 239, 249, 254),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serviceName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            SizedBox(height: 10),
            Text(
              '$centerName',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 24, 24, 24),
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Selected Kids:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight
                          .bold, // Making the "Selected Kids:" text bold
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  TextSpan(
                    text:
                        ' $selectedKidsString', // Adding the selected kids string
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'From: ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold, // Making "From:" bold
                    ),
                  ),
                  TextSpan(
                    text: '$startDateFormatted',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  TextSpan(
                    text: '     To: ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold, // Making "To:" bold
                    ),
                  ),
                  TextSpan(
                    text: '$endDateFormatted',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'At: ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 2, 2, 2),
                      fontWeight: FontWeight.bold, // Making "At:" bold
                    ),
                  ),
                  TextSpan(
                    text: '$selectedTimeSlot',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 2, 2, 2),
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Total Price: ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold, // Making "Total Price:" bold
                    ),
                  ),
                  TextSpan(
                    text: '$totalPrice SAR',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            if (isStartDateInPast)
              Text(
                'Rate the program:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            if (isStartDateInPast)
              StarRating(
                serviceDocumentId: serviceDocument.id, // Pass the document ID
                initialRating: starsrate ?? 0,
                onRatingChanged: (newRating) {
                  print(
                      "you rated with $newRating stars for ${serviceDocument.id}");
                  // You can handle the new rating as needed
                },
              )
          ],
        ),
      ),
    );
  }
}
