import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user's email from Firebase Authentication
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("History"),
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
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('ServiceBook')
                .where('userEmail', isEqualTo: currentUserEmail)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Loading indicator
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
                    final data = serviceDocument.data() as Map<String, dynamic>;

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
        ],
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
    final cardMargin = EdgeInsets.fromLTRB(20, 100, 16, 8); // Adjust as needed

    return Card(
      elevation: 3,
      margin: cardMargin, // Set the margin here
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
