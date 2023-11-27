import 'package:baheej/screens/CenterProfileScreen.dart';
import 'package:baheej/screens/HomeScreenCenter.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart'; // Make sure to import the Cupertino library

import 'package:intl/intl.dart';
import 'package:baheej/screens/Service.dart'; // Import the Service class if it's in a separate file

class compSerListScreen extends StatefulWidget {
  final String centerName;

  compSerListScreen({required this.centerName});

  @override
  _compSerListScreenState createState() => _compSerListScreenState();
}

class _compSerListScreenState extends State<compSerListScreen> {
  List<Service> completedServices = [];
  CenterProfile? _centerProfile;
  List<Service> services = []; // Add this line
  List<Service> filteredServices = []; // Add this line

  @override
  void initState() {
    super.initState();
    loadCompletedServices();
  }

  Future<double> calculateBookingRatio(Service service) async {
    if (service.capacityValue > 0) {
      // Fetch the booked services for the logged-in center
      int bookedServicesCount =
          await getBookedServicesCount(service.centerName);

      // Calculate the booking ratio
      return bookedServicesCount > 0
          ? bookedServicesCount / service.capacityValue
          : 0.0;
    } else {
      return 0.0; // Handle the case where capacityValue is 0 to avoid division by zero
    }
  }

// Fetch the number of booked services for the specified center
  Future<int> getBookedServicesCount(String centerName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      try {
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('ServiceBook')
            .where('centerName', isEqualTo: centerName)
            .get();

        return snapshot.size; // Return the count of booked services
      } catch (e) {
        print('Error fetching booked services: $e');
      }
    }

    return 0; // Return 0 in case of an error or no booked services
  }

  static String formatServiceInfo(Service service) {
    return """
      Service Name: ${service.serviceName}
      Description: ${service.description}
      Center Name: ${service.centerName}
      Start Date: ${service.selectedStartDate}
      End Date: ${service.selectedEndDate}
      Min Age: ${service.minAge}
      Max Age: ${service.maxAge}
      Capacity: ${service.capacityValue}
      Service Price: ${service.servicePrice}
      Time Slot: ${service.selectedTimeSlot}
    """;
  }

  Future<void> loadCompletedServices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('center-service')
          .where('centerName', isEqualTo: widget.centerName)
          .get();
      final currentDate = DateTime.now();
      final List<Service?> loadedServices =
          await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
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
          // List<String> subscribedUsers = await getSubscribedUsers(doc.id);
          final participantNo = data['participateNo'] ?? 0;

          return Service(
            id: doc.id,
            serviceName:
                data['serviceName'] as String? ?? 'Service Name Missing',
            description:
                data['serviceDesc'] as String? ?? 'Description Missing',
            centerName: data['centerName'] as String? ?? 'Center Name Missing',
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
            participantNo: participantNo,
            starsrate: data['starsrate'] as int? ?? 0,
        

          );
        } else {
          return null;
        }
      }));

      setState(() {
        services = loadedServices
            .where((service) => service != null)
            .cast<Service>()
            .toList();
        filteredServices = loadedServices
            .where((service) => service != null)
            .cast<Service>()
            .toList();
      });
    }
  }

  double calculatePercentageBooked(int capacity, int participants) {
    if (capacity <= 0) {
      return 0.0; // Return 0 if capacity is invalid
    }

    return (participants / capacity) * 100; // Calculate percentage booked
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
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      // or filteredServices[index]

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
                                    Divider(),
                                    Row(
                                      children: [
                                        Text(
                                          'Booked Capacity Percentage: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${calculatePercentageBooked(service.capacityValue, service.participantNo).toStringAsFixed(2)}%',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                   Row(
                                      children: [
                                        Text(
                                          'Average Rating: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${calculateAverageRating(services, service.serviceName).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        _showServiceDetails(
                                          service,
                                        ); // Create a method to show details
                                      },
                                      child: Text(
                                        'More Details',
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ]))
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
                          centerName: _centerProfile?.username ?? '',
                        ),
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

// Outside the build method, create the method to show detailed information in a pop-up
  void _showServiceDetails(Service service) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            // color: const Color.fromARGB(255, 234, 212, 219),
            color: Color.fromARGB(255, 239, 249, 254),

            borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.0)), // Customize the shape here
          ),
          child: CupertinoActionSheet(
            title: Text(
              'Service Details',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            message: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Description: ${service.description}',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                Text(
                  'Start Date: ${DateFormat('MM/dd/yyyy').format(service.selectedStartDate)}',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                Text(
                  'End Date: ${DateFormat('MM/dd/yyyy').format(service.selectedEndDate)}',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                Text(
                  'Service Capacity: ${service.capacityValue}',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),

                // Include other details you want to display here
              ],
              
            ),
            
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors
                        .black, // Change text color for the 'Close' button
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}


//  double calculateAverageRating(List<Service> services, String serviceName) {
//   final List<Service> filteredServices =
//       services.where((service) => service.serviceName == serviceName).toList();

//   if (filteredServices.isEmpty) {
//     return 0.0;
//   }

//   // Calculate the sum of starsrate
//   int sumOfStars = 0;
//   for (Service service in filteredServices) {
//     sumOfStars += service.starsrate;
//   }

//   // Calculate the average rating
//   return sumOfStars / filteredServices.length.toDouble();
// }

// Map<String, double> calculateAverageRating(List<Service> services) {
//   Map<String, List<Service>> servicesMap = {};

//   // Group services by serviceName
//   for (Service service in services) {
//     if (!servicesMap.containsKey(service.serviceName)) {
//       servicesMap[service.serviceName] = [];
//     }
//     servicesMap[service.serviceName]!.add(service);
//   }

//   // Calculate average rating for each serviceName
//   Map<String, double> averageRatings = {};
//   servicesMap.forEach((serviceName, serviceList) {
//     double sumOfStars = 0;
//     for (Service service in serviceList) {
//       sumOfStars += service.starsrate;
//     }
//     averageRatings[serviceName] = sumOfStars / serviceList.length;
//   });

//   return averageRatings;
// }



double calculateAverageRating(List<Service> services, String serviceName) {
  final List<Service> filteredServices =
      services.where((service) => service.serviceName == serviceName).toList();

  if (filteredServices.isEmpty) {
    return 0.0;
  }

  // Calculate the sum of starsrate
  int sumOfStars = 0;
  for (Service service in filteredServices) {
    sumOfStars += service.starsrate;
  }

  // Calculate the average rating
  return sumOfStars / filteredServices.length.toDouble();
}



