// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class HistoryScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Get the current user's email from Firebase Authentication
//     final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Booked Services History'),
//         ),
//         body: FutureBuilder<QuerySnapshot>(
//           future: FirebaseFirestore.instance
//               .collection('ServiceBook')
//               .where('userEmail', isEqualTo: currentUserEmail)
//               .get(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return CircularProgressIndicator(); // Loading indicator
//             } else if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text(' No booked services found '), // Centered text
//               );
//             } else {
//               final bookedServices = snapshot.data!.docs;
//               return ListView.builder(
//                 itemCount: bookedServices.length,
//                 itemBuilder: (context, index) {
//                   final serviceDocument = bookedServices[index];
//                   final data = serviceDocument.data() as Map<String, dynamic>;

//                   final centerName = data['centerName'];
//                   final serviceName = data['serviceName'];
//                   final selectedKidsMap =
//                       data['selectedKidsNames'] as Map<String, dynamic>?;
//                   final selectedStartDate =
//                       data['selectedStartDate'] as Timestamp;
//                   final selectedEndDate = data['selectedEndDate'] as Timestamp;
//                   final totalPrice = data['totalPrice'] as double;
//                   final selectedTimeSlot = data['selectedTimeSlot'];

//                   String selectedKidsString = '';

//                   if (selectedKidsMap != null) {
//                     // Convert the values of 'selectedKidsMap' into a single string
//                     selectedKidsString = selectedKidsMap.values.join(', ');
//                   }

//                   return buildServiceCard(
//                     centerName,
//                     serviceName,
//                     selectedKidsString,
//                     selectedStartDate.toDate(),
//                     selectedEndDate.toDate(),
//                     selectedTimeSlot,
//                     totalPrice,
//                   );
//                 },
//               );
//             }
//           },
//         ));
//   }

//   Widget buildServiceCard(
//       String centerName,
//       String serviceName,
//       String selectedKidsString,
//       DateTime selectedStartDate,
//       DateTime selectedEndDate,
//       String selectedTimeSlot,
//       double totalPrice) {
//     // Format selectedStartDate and selectedEndDate to strings
//     final startDateFormatted =
//         DateFormat('yyyy-MM-dd').format(selectedStartDate);
//     final endDateFormatted = DateFormat('yyyy-MM-dd').format(selectedEndDate);

//     return Card(
//       elevation: 3,
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: Stack(
//         children: [
//           ListTile(
//             title: Text(
//               serviceName,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 10), // Add a SizedBox for spacing

//                 Text(
//                   '$centerName',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 Text(
//                   'Selected Kids: $selectedKidsString',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 Text(
//                   'From: $startDateFormatted' '     To: $endDateFormatted ',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 Text(
//                   'At: $selectedTimeSlot',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 Text(
//                   'Total Price: $totalPrice' ' SAR',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 12, // Adjust the position as needed
//             right: 12, // Adjust the position as needed
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                   horizontal: 12, vertical: 6), // Adjust padding
//               decoration: BoxDecoration(
//                 color: Colors.green, // Customize the background color
//                 borderRadius:
//                     BorderRadius.circular(8), // Adjust the border radius
//               ),
//               child: Text(
//                 'Booked',
//                 style: TextStyle(
//                   fontSize: 14, // Adjust font size
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white, // Customize the text color
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
