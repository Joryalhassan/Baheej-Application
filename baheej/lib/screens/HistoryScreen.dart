//import 'package:baheej/screens/HomeScreenGaurdian.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/Addkids.dart';
import 'package:baheej/screens/SignInScreen.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user's email from Firebase Authentication
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    void _handleAddKids() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddKidsPage(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Booked Service"),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            top:
                100, // Adjust the top value to control the vertical position of cards
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
                      child: CircularProgressIndicator()); // Loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No booked services found'), // Centered text
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

                      String selectedKidsString = '';

                      if (selectedKidsMap != null) {
                        // Convert the values of 'selectedKidsMap' into a single string
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
                    // Use pushAndRemoveUntil to navigate to the home page directly
                  //  Navigator.pushAndRemoveUntil(
                  //    context,
                   //   MaterialPageRoute(
                   //     builder: (context) => HomeScreenGaurdian(),
                    //  ),
                    //  (route) => false, // Remove all previous routes
                  //  );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5), // Add margin to the top

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
                  padding: EdgeInsets.fromLTRB(
                      1, 50, 17, 1), // Add margin to the top

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
                  icon: Icon(Icons.person), // Profile Icon

                  color: Colors.white, // Set icon color to white

                  onPressed: () {
                    _handleAddKids();
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
          onPressed:
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
  ) {
    // Format selectedStartDate and selectedEndDate to strings
    final startDateFormatted =
        DateFormat('yyyy-MM-dd').format(selectedStartDate);
    final endDateFormatted = DateFormat('yyyy-MM-dd').format(selectedEndDate);

    // Define margin values (top, bottom, left, right)
    final cardMargin = EdgeInsets.fromLTRB(20, 10, 16, 0); // Adjust as needed

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 26),
      // margin: cardMargin, // Set the margin here
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Customize border radius
      ),
      child: Container(
        padding: EdgeInsets.all(16), // Adjust inner padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 239, 249, 254),
              const Color.fromARGB(255, 239, 249, 254),
            ], // Customize the card background gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10), // Adjust border radius
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serviceName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0), // Customize text color
              ),
            ),
            SizedBox(height: 10), // Add a SizedBox for spacing

            Text(
              '$centerName',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 24, 24, 24), // Customize text color
              ),
            ),
            Text(
              'Selected Kids: $selectedKidsString',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 0, 0), // Customize text color
              ),
            ),
            Text(
              'From: $startDateFormatted' '     To: $endDateFormatted ',
              style: TextStyle(
                fontSize: 16,
                color:
                    const Color.fromARGB(255, 0, 0, 0), // Customize text color
              ),
            ),
            Text(
              'At: $selectedTimeSlot',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 2, 2, 2), // Customize text color
              ),
            ),
            Text(
              'Total Price: $totalPrice' ' SAR',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 0, 0), // Customize text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
