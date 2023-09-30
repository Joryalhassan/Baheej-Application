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
      appBar: AppBar(
        title: Text('Booked Services History'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('ServiceBook')
            .where('userEmail', isEqualTo: currentUserEmail) //////////////////////////////////IMPORTANT//////////////////////////
            .get(),


        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No booked services found');
          } else {
            final bookedServices = snapshot.data!.docs;
            return ListView.builder(
              itemCount: bookedServices.length,
              itemBuilder: (context, index) {
                final serviceDocument = bookedServices[index];
                final data = serviceDocument.data() as Map<String, dynamic>;

                final centerName = data['centerName'];
                final serviceName = data['serviceName'];
                //final selectedKids = data['selectedKids'] as Map<String, dynamic>;

                final selectedStartDate = data['selectedStartDate'] as Timestamp;
                final selectedEndDate = data['selectedEndDate'] as Timestamp;
                final totalPrice = data['totalPrice'] as double;
               final selectedKidsMap = data['selectedKidsNames'] as Map<String, dynamic>?;

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
                  totalPrice,
                );
              },
            );
          }
        },
      ),
    );
  }

Widget buildServiceCard(
    String centerName,
    String serviceName,
    String selectedKidsString,
    DateTime selectedStartDate,
    DateTime selectedEndDate,
    double totalPrice,
   ) {

    // Format selectedStartDate and selectedEndDate to strings
    final startDateFormatted = DateFormat('yyyy-MM-dd').format(selectedStartDate);
    final endDateFormatted = DateFormat('yyyy-MM-dd').format(selectedEndDate);

      return Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          title: Text(serviceName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold, // Make it bolder
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Center Name: $centerName',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Selected Kids: $selectedKidsString',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Start Date: $startDateFormatted',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'End Date: $endDateFormatted',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Total Price: $totalPrice',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
  
 }
}