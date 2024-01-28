import 'package:baheej/screens/HistoryScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/Addkids.dart';
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/ServiceDetailsPage.dart';
import 'dart:async';
// import math , create random colors card
import 'dart:math';
import 'package:baheej/screens/NotificationsPage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:baheej/screens/GProfileScreen.dart';

class HomeScreenGaurdian extends StatefulWidget {
  const HomeScreenGaurdian({Key? key}) : super(key: key);

  @override
  _HomeScreenGaurdianState createState() => _HomeScreenGaurdianState();
}

class _HomeScreenGaurdianState extends State<HomeScreenGaurdian> {
  String FirstName = '';
  String? type;
  late List<Service> _allServices;
  List<Service> _filteredServices = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _pollingTimer; // The timer for polling
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Set<String> notifiedDocumentIds = Set<String>();
  StreamSubscription<QuerySnapshot>?
      _subscription; // To manage the subscription
  //final String? payload;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    startPollingNotifications();
    requestNotificationPermission();

    fetchDataFromFirebase().then((services) {
      setState(() {
        _allServices = services;
        _filteredServices = services;
      });
    });
    fetchName(); // Call fetchName to fetch the user's first name
    ;
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      print('Local notification permission granted');
    } else {
      print('Local notification permission denied');
    }
  }

  void initializeNotifications() async {
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> startPollingNotifications() async {
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (_) {
      checkNewNotification();
    });
  }

  Future<void> checkNewNotification() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('notification2').get();

    querySnapshot.docs.forEach((doc) {
      final String message = doc.data()['message'] ?? '';
      if (!notifiedDocumentIds.contains(doc.id)) {
        notifiedDocumentIds.add(doc.id);
        showNotification(message);
      }
    });
  }

  Future<void> showNotification(String message) async {
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(iOS: iosPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Baheej App',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<List<Service>> fetchDataFromFirebase() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('center-service');
    final querySnapshot = await collection.get();
    final currentDate = DateTime.now(); // Get the current date

    final services = querySnapshot.docs
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
          final serviceName = data['serviceName'] ?? 'Title';
          final description = data['serviceDesc'] ?? 'Description';
          final centerName = data['centerName'] ?? 'Center Name';
          final selectedTimeSlot = data['selectedTimeSlot'] ?? 'time slot';
          final capacityValue = data['capacityValue'] ?? 0;
          final servicePrice = (data['servicePrice'] ?? 0).toDouble();
          final minAge = data['minAge'] ?? 4;
          final maxAge = data['maxAge'] ?? 17;
          //final id = data['id'] ?? 'id';
          final participantNo = data['participateNo'] ?? 0;
          final starsrate = data['starsrate'] ?? 0;
          if (!selectedStartDate.isBefore(currentDate)) {
            return Service(
              serviceName: serviceName,
              description: description,
              centerName: centerName,
              selectedTimeSlot: selectedTimeSlot,
              capacityValue: capacityValue,
              servicePrice: servicePrice,
              selectedStartDate: selectedStartDate,
              selectedEndDate: selectedEndDate,
              minAge: minAge,
              maxAge: maxAge,
              id: doc.id,
              participateNo: participantNo,
              starsrate: starsrate,
            );
          } else {
            return null;
          }
        })
        .where((service) => service != null)
        .toList();

    return List<Service>.from(services);
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

  void _handleSearch(String query) {
    query = query.trim();
    setState(() {
      _filteredServices = _allServices
          .where((service) =>
              service.serviceName
                  .toLowerCase()
                  .startsWith(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _handleAddKids() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddKidsPage(),
      ),
    );
  }

  void fetchName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final firstName = userData['fname'] ?? '';
        final userRole = userData[
            'userType']; // Assuming userType is a field in the Firestore document
        print('Fetched first name: $firstName');
        setState(() {
          FirstName = firstName;
          type = userRole;
        });
      }
    }
  }

  // view the notification
  void navigateToNotificationsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(),
      ),
    );
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.notifications_active, // Bell icon
                        color: Colors.white,
                        // Set icon color to yellow
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsPage()),
                    );
                  },
                ),

                SizedBox(width: 8), // Add some space between the icons and text
              ],
            ),
            Text(
              'Welcome $FirstName',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily:
                    '5yearsoldfont', // Use the font family name declared in pubspec.yaml
              ),
            ),
            Row(
              children: [
                SizedBox(width: 8), // Add some space between the text and icon
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _handleLogout,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 0,
            child: Image.asset(
              'assets/images/kidW111.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 170, left: 16, right: 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _handleSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search program...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  toolbarOptions: null, // Remove paste button
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 30),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      // defined the random color
                      final randomColor =
                          _getRandomColor(); // Get a random color for each card

                      return GestureDetector(
                        onTap: () {
                          // Handle tapping on a service
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Card(
                            elevation: 3,

                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 1),
                            //here call randomColor to call the function
                            color: randomColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20), // Adjust the circular shape here
                            ), // Use the random color here

                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 12),
                                  Text(
                                    service.serviceName,
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: '5yearsoldfont',
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'center name: ${service.centerName}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight
                                          .bold, // Set the font weight to bold
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Program Time: ${service.selectedTimeSlot}\n\n\n',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight
                                              .bold, // Set the font weight to bold
                                        ),
                                      ),
                                      InkWell(
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.blue,
                                                textStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                // padding: EdgeInsets.symmetric(
                                                //   horizontal: 20,
                                                //   vertical: 12,
                                                // ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          33.0),
                                                ),
                                                backgroundColor: Color.fromARGB(
                                                    255, 59, 138, 207),
                                                minimumSize: Size(10, 30),
                                              ),
                                              child: Text('View Details'),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ServiceDetailsPage(
                                                            service: service),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
        color:
            Color.fromARGB(255, 255, 255, 255), // Set background color to white
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButtonWithLabel(
                Icons.history,
                'Bookings',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
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
                Icons.child_care,
                'view Kids',
                Color.fromARGB(255, 249, 194, 212),
                () {
                  _handleAddKids();
                },
              ),
              _buildIconButtonWithLabel(
                Icons.person,
                'Profile',
                Color.fromARGB(255, 249, 194, 212),
                () {
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
