import 'package:baheej/screens/CenterProfileScreen.dart';
import 'package:baheej/screens/HomeScreenCenter.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/Service.dart'; // Import the Service class if it's in a separate file

class compSerListScreen extends StatefulWidget {
  //final String centerName;

  //compSerListScreen({required this.centerName});

  @override
  _compSerListScreenState createState() => _compSerListScreenState();
}

class _compSerListScreenState extends State<compSerListScreen> {
  List<Service> completedServices = [];
  CenterProfile? _centerProfile;

  @override
  void initState() {
    super.initState();
    loadCompletedServices();
  }

  Future<void> loadCompletedServices() async {
    final currentDate = DateTime.now();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('center-service')
          .where('endDate', isLessThan: Timestamp.fromDate(currentDate))
          .get();

      final List<Service> loadedServices = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // The same logic as in HomeScreenCenter to create Service objects
            DateTime selectedStartDate;
            DateTime selectedEndDate;

            if (data['startDate'] is String) {
              selectedStartDate = DateTime.parse(data['startDate'] as String);
            } else if (data['startDate'] is Timestamp) {
              selectedStartDate = (data['startDate'] as Timestamp).toDate();
            } else {
              selectedStartDate = DateTime.now();
            }

            if (data['endDate'] is String) {
              selectedEndDate = DateTime.parse(data['endDate'] as String);
            } else if (data['endDate'] is Timestamp) {
              selectedEndDate = (data['endDate'] as Timestamp).toDate();
            } else {
              selectedEndDate = DateTime.now();
            }

            if (selectedEndDate.isBefore(currentDate)) {
              return Service(
                id: doc.id,
                serviceName:
                    data['serviceName'] as String? ?? 'Service Name Missing',
                description:
                    data['serviceDesc'] as String? ?? 'Description Missing',
                centerName:
                    data['centerName'] as String? ?? 'Center Name Missing',
                selectedStartDate: selectedStartDate,
                selectedEndDate: selectedEndDate,
                minAge: data['minAge'] as int? ?? 0,
                maxAge: data['maxAge'] as int? ?? 0,
                capacityValue: data['serviceCapacity'] as int? ?? 0,
                servicePrice: data['servicePrice'] is double
                    ? data['servicePrice']
                    : (data['servicePrice'] is int
                        ? (data['servicePrice'] as int).toDouble()
                        : 0.0),
                selectedTimeSlot:
                    data['selectedTimeSlot'] as String? ?? 'Time Slot Missing',
              );
            } else {
              return null;
            }
          })
          .where((service) => service != null)
          .cast<Service>()
          .toList();

      setState(() {
        completedServices = loadedServices;
      });
    } catch (e) {
      print('Error loading completed services: $e');
    }
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Completed Services Statistics'),
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
          Padding(
            padding: EdgeInsets.only(top: 160, left: 16, right: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: completedServices.length,
                    itemBuilder: (context, index) {
                      Service service = completedServices[index];

                      return Card(
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Color.fromARGB(255, 239, 249, 254),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Service Name: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    service.serviceName,
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
                                    DateFormat('MM/dd/yyyy')
                                        .format(service.selectedStartDate),
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
                                    DateFormat('MM/dd/yyyy')
                                        .format(service.selectedEndDate),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Service Time: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    service.selectedTimeSlot,
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
                                service.description,
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
                                    service.minAge.toString(),
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
                                    service.maxAge.toString(),
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
                                    service.capacityValue.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Service Price: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${service.servicePrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
                  icon: Icon(Icons.home_filled),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreenCenter(
                            centerName: _centerProfile?.username ?? ''),
                      ),
                    );
                  },
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'Add Service',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CenterProfileViewScreen(),
                      ),
                    );
                    // Handle profile button tap
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceFormScreen(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
