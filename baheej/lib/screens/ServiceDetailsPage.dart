import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceDetailsPage extends StatefulWidget {
  final String serviceName;
  final String serviceDescription;
  final String centerName;
  final int selectedTimeSlot;
  final int capacityValue;
  final double servicePrice;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final String ageRange;

  ServiceDetailsPage({
    required this.serviceName,
    required this.serviceDescription,
    required this.centerName,
    required this.selectedEndDate,
    required this.selectedStartDate,
    required this.ageRange,
    required this.capacityValue,
    required this.servicePrice,
    required this.selectedTimeSlot,
  });

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  List<String> selectedKids = [];
  double total = 0.0;

  // Function to add service details to Firestore
  Future<void> addServiceToFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Create a map with the service details
      final serviceData = {
        'serviceName': widget.serviceName,
        'serviceDescription': widget.serviceDescription,
        'centerName': widget.centerName,
        'selectedStartDate': widget.selectedStartDate,
        'selectedEndDate': widget.selectedEndDate,
        'ageRange': widget.ageRange,
        'servicePrice': widget.servicePrice,
        'selectedTimeSlot': widget.selectedTimeSlot,
        'selectedKids': selectedKids,
        'totalPrice': total, // Store the calculated total price
      };

      // Add the data to the 'ServiceBook' collection
      await firestore.collection('ServiceBook').add(serviceData);

      // Handle success or show a confirmation to the user
    } catch (error) {
      // Handle any errors here
      print('Error booking service: $error');
      // You can also show an error message to the user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    total = widget.servicePrice * selectedKids.length.toDouble();

    return Scaffold(
      body: Container(
        color: Colors.transparent, // Make the background transparent
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/back3.png', // Replace with your image path
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(120.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Service Name:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.serviceName,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 17, 0, 6),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.serviceDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 7, 0, 2),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Center name:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.centerName,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 7, 0, 2),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Service Price:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '\$${widget.servicePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 7, 0, 2),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Service Start Date:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.selectedStartDate.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 7, 0, 2),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Service End Date:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.selectedEndDate.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 7, 0, 2),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Service Time Slot:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.selectedTimeSlot.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 7, 0, 2),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    'Age Range:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.ageRange,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 7, 0, 2),
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Select Kids:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  // StreamBuilder to display kids from Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Kids')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      final kids = snapshot.data!.docs;
                      List<Widget> checkboxes = [];
                      for (var kid in kids) {
                        final kidData = kid.data() as Map<String, dynamic>;
                        final kidName = kidData['name'] as String;
                        checkboxes.add(
                          ListTile(
                            title: Text(kidName),
                            trailing: Checkbox(
                              value: selectedKids.contains(kid.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null && value) {
                                    selectedKids.add(kid.id);
                                  } else {
                                    selectedKids.remove(kid.id);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: checkboxes,
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      // Call the function to add service details to Firestore
                      addServiceToFirestore();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 23, 34, 191),
                      minimumSize: Size(200, 60),
                    ),
                    child: Text(
                      'Book',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
