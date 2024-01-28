// import 'package:baheej/screens/EditService.dart';
// import 'package:baheej/screens/compSerList.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:baheej/screens/Service.dart';
// //import 'package:baheej/screens/ServiceDetailsPage.dart';
// import 'package:baheej/screens/ServiceFormScreen.dart';
// import 'package:baheej/screens/SignInScreen.dart';
// import 'package:baheej/screens/CenterProfileScreen.dart';
// //import 'package:flutter_local_notifications/flutter_local_notifications.dart';comJo
// //import 'package:timezone/data/latest.dart' as tz;comJo
// //import 'package:timezone/timezone.dart' as tz;comJo
// // import 'package:baheej/screens/NotificationService1.dart';
// import 'package:baheej/screens/CserviceDetails.dart';
// // import math , create random colors card
// import 'dart:math';

// class HomeScreenCenter extends StatefulWidget {
//   final String centerName;

//   HomeScreenCenter({required this.centerName});

//   @override
//   _HomeScreenCenterState createState() => _HomeScreenCenterState();
// }

// class _HomeScreenCenterState extends State<HomeScreenCenter> {
//   List<Service> services = [];
//   List<Service> filteredServices = [];
//   TextEditingController _searchController = TextEditingController();
//   String centerName = ''; // Declare centerName here
//   String? userRole;
//   TextEditingController notificationMessageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadServices();
//   }

//   ///0000000

//   TextEditingController adMessageController = TextEditingController();

//   void _showAdMessageDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Create Advertisement'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 controller: adMessageController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your advertisement message',
//                 ),
//                 maxLength: 100, // Maximum characters allowed
//                 maxLines: null, // Allow multiple lines
//               ),
//               SizedBox(height: 10),
//               // Text(
//               //   'Minimum 15 characters required',
//               //   style: TextStyle(color: Colors.red),
//               // ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Submit'),
//               onPressed: () async {
//                 String adMessage = adMessageController.text.trim();
//                 if (adMessage.isNotEmpty && adMessage.length >= 15) {
//                   // Store ad message in Firestore under 'notification2' collection
//                   await FirebaseFirestore.instance
//                       .collection('notification2')
//                       .add({
//                     'message': adMessage,
//                     'timestamp': DateTime.now(),
//                   });

//                   // Show a SnackBar to indicate successful notification sent
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Notification sent successfully!'),
//                       backgroundColor:
//                           Colors.green, // Set background color to green
//                     ),
//                   );

//                   adMessageController.clear(); // Clear the text field
//                   Navigator.of(context).pop(); // Close the dialog
//                 } else {
//                   // Show an error message if the entered text is invalid
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'Please enter at least 15 characters!',
//                         style: TextStyle(
//                             color: const Color.fromARGB(255, 255, 255, 255)),
//                       ),
//                       backgroundColor: Color.fromARGB(255, 249, 0, 0),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

// //000000

//   double calculatePercentageBooked(int capacity, int participants) {
//     if (capacity <= 0) {
//       return 0.0; // Return 0 if capacity is invalid
//     }

//     return (participants / capacity) * 100; // Calculate percentage booked
//   }

//   Future<void> loadServices() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final userId = user.uid;

//       // Fetch user center data
//       final centerDoc = await FirebaseFirestore.instance
//           .collection('center')
//           .doc(userId)
//           .get();
//       if (centerDoc.exists) {
//         // Now you can use centerDoc.data() to access the data
//         centerName = centerDoc.data()!['username'];
//       }

//       final snapshot = await FirebaseFirestore.instance
//           .collection('center-service')
//           .where('centerName', isEqualTo: widget.centerName)
//           .get();
//       final currentDate = DateTime.now(); // Get the current date
//       final List<Service> loadedServices = snapshot.docs
//           .map((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             DateTime selectedStartDate;
//             DateTime selectedEndDate;

//             // Check if the 'startDate' and 'endDate' are stored as strings or timestamps
//             if (data['startDate'] is String) {
//               selectedStartDate = DateTime.parse(data['startDate'] as String);
//             } else if (data['startDate'] is Timestamp) {
//               selectedStartDate = (data['startDate'] as Timestamp).toDate();
//             } else {
//               selectedStartDate = DateTime.now();
//             }

//             if (data['endDate'] is String) {
//               selectedEndDate = DateTime.parse(data['endDate'] as String);
//             } else if (data['endDate'] is Timestamp) {
//               selectedEndDate = (data['endDate'] as Timestamp).toDate();
//             } else {
//               selectedEndDate = DateTime.now();
//             }
//             final participantNo = data['participateNo'] ?? 0;

//             // Check if the start date is today or earlier
//             if (!selectedStartDate.isBefore(currentDate)) {
//               return Service(
//                 id: doc.id,
//                 serviceName:
//                     data['serviceName'] as String? ?? 'Service Name Missing',
//                 description:
//                     data['serviceDesc'] as String? ?? 'Description Missing',
//                 centerName:
//                     data['centerName'] as String? ?? 'Center Name Missing',
//                 selectedStartDate: selectedStartDate,
//                 selectedEndDate: selectedEndDate,
//                 minAge: data['minAge'] as int? ?? 0,
//                 maxAge: data['maxAge'] as int? ?? 0,
//                 capacityValue: data['serviceCapacity'] as int? ?? 0,
//                 servicePrice: data['servicePrice'] is double
//                     ? data['servicePrice']
//                     : (data['servicePrice'] is int
//                         ? (data['servicePrice'] as int).toDouble()
//                         : 0.0),
//                 selectedTimeSlot:
//                     data['selectedTimeSlot'] as String? ?? 'Time Slot Missing',
//                 participateNo: participantNo,
//                 starsrate: data['starsrate'] as int? ?? 0,
//               );
//             } else {
//               // Return null for services with start dates in the past or today
//               return null;
//             }
//           })
//           .where((service) => service != null) // Filter out null values
//           .cast<Service>() // Cast the list to Service
//           .toList();

//       setState(() {
//         services = loadedServices;
//         filteredServices = loadedServices;
//       });
//     }
//   }

//   void reloadServices() async {
//     await loadServices();
//   }

//   Future<void> _handleLogout() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Are You Sure?'),
//           content: Text('Do you want to log out?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Yes'),
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 try {
//                   await FirebaseAuth.instance.signOut();
//                   showLogoutSuccessDialog();
//                 } catch (e) {
//                   print("Error signing out: $e");
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void updateService(Service updatedService) {
//     final index =
//         services.indexWhere((service) => service.id == updatedService.id);
//     if (index != -1) {
//       setState(() {
//         services[index] = updatedService;
//       });
//     }
//   }

//   void showLogoutSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Logout Successful'),
//           content: Text('You have successfully logged out.'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 navigateToSignInScreen();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void navigateToSignInScreen() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => SignInScreen()),
//       (route) => false, // Remove all routes in the stack
//     );
//   }

//   void _handleSearch(String query) {
//     query = query.trim();
//     final now = DateTime.now();
//     setState(() {
//       filteredServices = services
//           .where((service) =>
//               service.serviceName.toLowerCase().contains(query.toLowerCase()) ||
//               service.description.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   Future<bool?> showDeleteConfirmationDialog() async {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Delete Program'),
//           content: Text('Are you sure you want to delete this service?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               },
//             ),
//             TextButton(
//               child: Text('Delete'),
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> deleteService(Service service) async {
//     // Show a confirmation dialog to confirm the deletion
//     bool? confirmDelete =
//         await showDeleteConfirmationDialog(); // Removed the default value

//     if (confirmDelete == true) {
//       try {
//         // Get the reference to the document you want to delete
//         final DocumentReference serviceRef = FirebaseFirestore.instance
//             .collection('center-service')
//             .doc(service.id);

//         // Delete the document from Firestore
//         await serviceRef.delete();

//         // Remove the service from the UI
//         removeServiceFromUI(service);
//       } catch (e) {
//         print('Error deleting service: $e');
//         // Handle the error, e.g., show an error dialog
//       }
//     }
//   }

//   void removeServiceFromUI(Service service) {
//     setState(() {
//       filteredServices.remove(service);
//     });
//   }

//   //function to create random colors of card
//   final _random = Random();
//   final List<Color> _randomColors = [
//     Color.fromARGB(255, 252, 222, 233),
//     Color.fromARGB(255, 210, 229, 245),
//     Color.fromARGB(255, 251, 242, 212),
//     // Add more colors if needed
//   ];

//   Color _getRandomColor() {
//     return _randomColors[_random.nextInt(_randomColors.length)];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notification_add),
//             onPressed: _showAdMessageDialog,
//           ),
//           SizedBox(width: 60),
//           Expanded(
//               child: Center(
//                   child: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 0.0),
//               child: Align(
//                 alignment: Alignment.centerLeft, // Align the text to the left
//                 child: Text(
//                   'Welcome ${widget.centerName}',
//                   style: TextStyle(
//                     fontFamily: '5yearsoldfont', // Use the defined font family
//                     fontSize: 25, // Adjust the font size as needed
//                     fontWeight:
//                         FontWeight.bold, // Replace with your font family name
//                   ),
//                   textAlign: TextAlign
//                       .center, // Align the text's content in the center
//                 ),
//               ),
//             ),
//           ))),
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: _handleLogout,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             top: 0,
//             child: Image.asset('assets/images/school.png', fit: BoxFit.cover),
//           ),
//           Padding(
//             padding: EdgeInsets.only(top: 200, left: 16, right: 16),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _searchController,
//                   onChanged: _handleSearch,
//                   decoration: InputDecoration(
//                     hintText: 'Search Programs...',
//                     prefixIcon: Icon(Icons.search),
//                   ),
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: filteredServices.isEmpty
//                         ? Center(
//                             child: Text(
//                               "You don't have any services yet.",
//                               style:
//                                   TextStyle(fontSize: 16, color: Colors.grey),
//                             ),
//                           )
//                         : Column(
//                             children: filteredServices.map((service) {
//                               final randomColor =
//                                   _getRandomColor(); // Get a random color for each card
//                               return GestureDetector(
//                                 onTap: () {
//                                   // Handle tapping on a service
//                                 },
//                                 child: Card(
//                                   elevation: 3,
//                                   margin: EdgeInsets.symmetric(
//                                       vertical: 8, horizontal: 16),
//                                   color: randomColor,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         //   Align(
//                                         // alignment: Alignment.topRight,
//                                         // child: GestureDetector(
//                                         // onTap: () {
//                                         //   deleteService(service);
//                                         //  },
//                                         //   child: Icon(Icons.delete), // Delete icon in red
//                                         // ),
//                                         //),

//                                         Text(
//                                           service.serviceName,
//                                           style: TextStyle(
//                                             fontSize: 25,
//                                             fontWeight: FontWeight.bold,
//                                             fontFamily: '5yearsoldfont',
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),

//                                         Row(
//                                           children: [
//                                             Text(
//                                               'Number of Participant : ',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               service.capacityValue.toString(),
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Text(
//                                           'Description: ',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         Text(
//                                           service.description,
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                           ),
//                                         ),

//                                         SizedBox(height: 16),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             GestureDetector(
//                                               onTap: () {
//                                                 // Navigation logic for editing service
//                                                 deleteService(service);
//                                               },
//                                               child: Icon(Icons
//                                                   .delete), // Edit icon on the left
//                                             ),
//                                             ElevatedButton(
//                                               onPressed: () {
//                                                 // Navigation logic for viewing service details
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         CserviceDetails(
//                                                             service: service),
//                                                   ),
//                                                 );
//                                               },
//                                               style: ElevatedButton.styleFrom(
//                                                 primary: Color.fromARGB(
//                                                     255, 59, 138, 207),
//                                                 onPrimary: Color.fromARGB(
//                                                     255, 255, 255, 255),
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           33.0),
//                                                 ),

//                                                 minimumSize: Size(10,
//                                                     30), // Increase the button size
//                                               ),
//                                               child: Text(
//                                                 'View Details',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 16,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color:
//             Color.fromARGB(255, 255, 255, 255), // Set background color to white
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildIconButtonWithLabel(
//                 Icons.query_stats,
//                 'Statistics',
//                 Color.fromARGB(255, 249, 194, 212),
//                 () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           compSerListScreen(centerName: centerName),
//                     ),
//                   );
//                 },
//               ),
//               //   color: Color.fromARGB(
//               //       255, 249, 194, 212), // Set icon color to black
//               //   onPressed: () {
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(builder: (context) => HistoryScreen()),
//               //     );
//               //   },
//               // ),
//               _buildIconButtonWithLabel(
//                 Icons.home,
//                 'Home',
//                 Color.fromARGB(255, 210, 229, 245),
//                 () {
//                   // Handle onPressed action
//                 },
//               ),
//               _buildIconButtonWithLabel(
//                 Icons.add,
//                 'Add Program',
//                 Color.fromARGB(255, 249, 194, 212),
//                 () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           ServiceFormScreen(onServiceAdded: reloadServices),
//                     ),
//                   );
//                 },
//               ),
//               _buildIconButtonWithLabel(
//                 Icons.person,
//                 'Profile',
//                 Color.fromARGB(255, 249, 194, 212),
//                 () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CenterProfileViewScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }

//   Widget _buildIconButtonWithLabel(
//     IconData iconData,
//     String label,
//     Color iconColor,
//     VoidCallback onPressed,
//   ) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: Icon(
//             iconData,
//             size: 35,
//           ),
//           color: iconColor,
//           onPressed: onPressed,
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }
//---------

import 'package:baheej/screens/EditService.dart';
import 'package:baheej/screens/compSerList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/Service.dart';
//import 'package:baheej/screens/ServiceDetailsPage.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/CenterProfileScreen.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';comJo
//import 'package:timezone/data/latest.dart' as tz;comJo
//import 'package:timezone/timezone.dart' as tz;comJo
// import 'package:baheej/screens/NotificationService1.dart';
import 'package:baheej/screens/CserviceDetails.dart';
// import math , create random colors card
import 'dart:math';

class HomeScreenCenter extends StatefulWidget {
  final String? centerName;

  HomeScreenCenter({required this.centerName});

  @override
  _HomeScreenCenterState createState() => _HomeScreenCenterState();
}

class _HomeScreenCenterState extends State<HomeScreenCenter> {
  List<Service> services = [];
  List<Service> filteredServices = [];
  TextEditingController _searchController = TextEditingController();
  String centerName = ''; // Declare centerName here
  String? userRole;
  TextEditingController notificationMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  ///0000000

  TextEditingController adMessageController = TextEditingController();

  void _showAdMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Advertisement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: adMessageController,
                decoration: InputDecoration(
                  hintText: 'Enter your advertisement message',
                ),
                maxLength: 100, // Maximum characters allowed
                maxLines: null, // Allow multiple lines
              ),
              SizedBox(height: 10),
              // Text(
              //   'Minimum 15 characters required',
              //   style: TextStyle(color: Colors.red),
              // ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                String adMessage = adMessageController.text.trim();
                if (adMessage.isNotEmpty && adMessage.length >= 15) {
                  // Store ad message in Firestore under 'notification2' collection
                  await FirebaseFirestore.instance
                      .collection('notification2')
                      .add({
                    'message': adMessage,
                    'timestamp': DateTime.now(),
                  });

                  // Show a SnackBar to indicate successful notification sent
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notification sent successfully!'),
                      backgroundColor:
                          Colors.green, // Set background color to green
                    ),
                  );

                  adMessageController.clear(); // Clear the text field
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  // Show an error message if the entered text is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please enter at least 15 characters!',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      backgroundColor: Color.fromARGB(255, 249, 0, 0),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

//000000

  double calculatePercentageBooked(int capacity, int participants) {
    if (capacity <= 0) {
      return 0.0; // Return 0 if capacity is invalid
    }

    return (participants / capacity) * 100; // Calculate percentage booked
  }

  Future<void> loadServices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      // Fetch user center data
      final centerDoc = await FirebaseFirestore.instance
          .collection('center')
          .doc(userId)
          .get();
      if (centerDoc.exists) {
        // Now you can use centerDoc.data() to access the data
        centerName = centerDoc.data()!['username'];
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('center-service')
          .where('centerName', isEqualTo: widget.centerName)
          .get();
      final currentDate = DateTime.now(); // Get the current date
      final List<Service> loadedServices = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime selectedStartDate;
            DateTime selectedEndDate;

            // Check if the 'startDate' and 'endDate' are stored as strings or timestamps
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
            final participantNo = data['participateNo'] ?? 0;

            // Check if the start date is today or earlier
            if (!selectedStartDate.isBefore(currentDate)) {
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
                participateNo: participantNo,
                starsrate: data['starsrate'] as int? ?? 0,
              );
            } else {
              // Return null for services with start dates in the past or today
              return null;
            }
          })
          .where((service) => service != null) // Filter out null values
          .cast<Service>() // Cast the list to Service
          .toList();

      setState(() {
        services = loadedServices;
        filteredServices = loadedServices;
      });
    }
  }

  void reloadServices() async {
    await loadServices();
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

  void updateService(Service updatedService) {
    final index =
        services.indexWhere((service) => service.id == updatedService.id);
    if (index != -1) {
      setState(() {
        services[index] = updatedService;
      });
    }
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

  void _handleSearch(String query) {
    query = query.trim();
    final now = DateTime.now();
    setState(() {
      filteredServices = services
          .where((service) =>
              service.serviceName.toLowerCase().contains(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<bool?> showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Program'),
          content: Text('Are you sure you want to delete this service?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteService(Service service) async {
    // Show a confirmation dialog to confirm the deletion
    bool? confirmDelete =
        await showDeleteConfirmationDialog(); // Removed the default value

    if (confirmDelete == true) {
      try {
        // Get the reference to the document you want to delete
        final DocumentReference serviceRef = FirebaseFirestore.instance
            .collection('center-service')
            .doc(service.id);

        // Delete the document from Firestore
        await serviceRef.delete();

        // Remove the service from the UI
        removeServiceFromUI(service);
      } catch (e) {
        print('Error deleting service: $e');
        // Handle the error, e.g., show an error dialog
      }
    }
  }

  void removeServiceFromUI(Service service) {
    setState(() {
      filteredServices.remove(service);
    });
  }

  //function to create random colors of card
  final _random = Random();
  final List<Color> _randomColors = [
    Color.fromARGB(255, 252, 222, 233),
    Color.fromARGB(255, 210, 229, 245),
    Color.fromARGB(255, 251, 242, 212),
    // Add more colors if needed
  ];

  Color _getRandomColor() {
    return _randomColors[_random.nextInt(_randomColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notification_add),
            onPressed: _showAdMessageDialog,
          ),
          SizedBox(width: 60),
          Expanded(
              child: Center(
                  child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Align(
                alignment: Alignment.centerLeft, // Align the text to the left
                child: Text(
                  'Welcome ${widget.centerName}',
                  style: TextStyle(
                    fontFamily: '5yearsoldfont', // Use the defined font family
                    fontSize: 25, // Adjust the font size as needed
                    fontWeight:
                        FontWeight.bold, // Replace with your font family name
                  ),
                  textAlign: TextAlign
                      .center, // Align the text's content in the center
                ),
              ),
            ),
          ))),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 0,
            child: Image.asset('assets/images/school.png', fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.only(top: 200, left: 16, right: 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  decoration: InputDecoration(
                    hintText: 'Search Programs...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: filteredServices.isEmpty
                        ? Center(
                            child: Text(
                              "You don't have any services yet.",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : Column(
                            children: filteredServices.map((service) {
                              final randomColor =
                                  _getRandomColor(); // Get a random color for each card
                              return GestureDetector(
                                onTap: () {
                                  // Handle tapping on a service
                                },
                                child: Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  color: randomColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //   Align(
                                        // alignment: Alignment.topRight,
                                        // child: GestureDetector(
                                        // onTap: () {
                                        //   deleteService(service);
                                        //  },
                                        //   child: Icon(Icons.delete), // Delete icon in red
                                        // ),
                                        //),

                                        Text(
                                          service.serviceName,
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: '5yearsoldfont',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        Row(
                                          children: [
                                            Text(
                                              'Number of Participant : ',
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

                                        SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // Navigation logic for editing service
                                                deleteService(service);
                                              },
                                              child: Icon(Icons
                                                  .delete), // Edit icon on the left
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Navigation logic for viewing service details
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CserviceDetails(
                                                            service: service),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Color.fromARGB(
                                                    255, 59, 138, 207),
                                                onPrimary: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          33.0),
                                                ),

                                                minimumSize: Size(10,
                                                    30), // Increase the button size
                                              ),
                                              child: Text(
                                                'View Details',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
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
                Icons.query_stats,
                'Statistics',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          compSerListScreen(centerName: centerName),
                    ),
                  );
                },
              ),
              //   color: Color.fromARGB(
              //       255, 249, 194, 212), // Set icon color to black
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => HistoryScreen()),
              //     );
              //   },
              // ),
              _buildIconButtonWithLabel(
                Icons.home,
                'Home',
                Color.fromARGB(255, 210, 229, 245),
                () {
                  // Handle onPressed action
                },
              ),
              _buildIconButtonWithLabel(
                Icons.add,
                'Add Program',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceFormScreen(onServiceAdded: reloadServices),
                    ),
                  );
                },
              ),
              _buildIconButtonWithLabel(
                Icons.person,
                'Profile',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CenterProfileViewScreen(),
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
}
