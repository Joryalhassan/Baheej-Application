import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:baheej/utlis/utilas.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



Future<List<DocumentSnapshot>> getBookedServicesForGuardian(String guardianUid) async {
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('ServiceBook')
      .where('guardianUid', isEqualTo: guardianUid)
      .get();
  
  return querySnapshot.docs;
}


Widget buildServiceCard(DocumentSnapshot serviceDocument) {
  final data = serviceDocument.data() as Map<String, dynamic>;
  
  final centerName = data['centerName'];
  final serviceName = data['serviceName'];
  final selectedStartDate = data['selectedStartDate'];
  final selectedEndDate = data['selectedEndDate'];
  final totalPrice = data['totalPrice'];

  return Card(
    elevation: 3,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ListTile(
      title: Text(centerName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service: $serviceName'),
          Text('Start Date: $selectedStartDate'),
          Text('End Date: $selectedEndDate'),
          Text('Total Price: $totalPrice'),
        ],
      ),
    ),
  );
}


class HistoryPage extends StatelessWidget {
  final String guardianUid;

  HistoryPage({required this.guardianUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Services History'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getBookedServicesForGuardian(guardianUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No booked services found.');
          } else {
            final bookedServices = snapshot.data!;
            return ListView.builder(
              itemCount: bookedServices.length,
              itemBuilder: (context, index) {
                final serviceDocument = bookedServices[index];
                return buildServiceCard(serviceDocument);
              },
            );
          }
        },
      ),
    );
  }
}


