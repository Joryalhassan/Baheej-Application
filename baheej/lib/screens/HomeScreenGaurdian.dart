import 'package:baheej/screens/HistoryScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/Addkids.dart';
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/ServiceDetailsPage.dart';
import 'dart:async';
import 'package:baheej/screens/LocalNotificationHandler.dart';
import 'package:baheej/screens/NotificationsPage.dart';
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
  LocalNotificationHandler _notificationHandler = LocalNotificationHandler();
  final Set<String> notifiedDocumentIds = Set<String>();
  StreamSubscription<QuerySnapshot>?
      _subscription; // To manage the subscription
  //final String? payload;

  bool hasNewNotification = false;

  void initState() {
    super.initState();
    fetchDataFromFirebase().then((services) {
      setState(() {
        _allServices = services;
        _filteredServices = services;
      });
    });
    fetchName(); // Call fetchName to fetch the user's first name

    _pollingTimer = Timer.periodic(
        Duration(seconds: 30), (timer) => checkForNotifications());
  }

  void checkForNotifications() {
    final User? user = _auth.currentUser;
    if (user != null) {
      final String currentUserId = user.uid;
      final firestore = FirebaseFirestore.instance;

      // Cancel any existing subscription before starting a new one
      _subscription?.cancel();

      _subscription = firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          if (!notifiedDocumentIds.contains(doc.id)) {
            final String? message = doc.data()?['message'];
            if (message != null) {
              _notificationHandler.showNotification('Baheej App', message);
              notifiedDocumentIds.add(doc.id);
              doc.reference.update({
                'seenBy': FieldValue.arrayUnion([currentUserId])
              });

              // Set hasNewNotification to true when a new notification is received
              setState(() {
                hasNewNotification = true;
              });
            }
          }
        }
      });
    } else {
      // Handle the scenario where the user is not logged in, if needed.
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _showLocalNotification(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bheej App'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
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
          final serviceName = data['serviceName'] ?? 'Title';
          final description = data['serviceDesc'] ?? 'Description';
          final startDate = data['startDate'] != null
              ? DateTime.parse(data['startDate'])
              : DateTime.now();
          final endDate = data['endDate'] != null
              ? DateTime.parse(data['endDate'])
              : DateTime.now();
          final centerName = data['centerName'] ?? 'Center Name';
          final selectedTimeSlot = data['selectedTimeSlot'] ?? 'time slot';
          final capacityValue = data['capacityValue'] ?? 0;
          final servicePrice = (data['servicePrice'] ?? 0).toDouble();
          final minAge = data['minAge'] ?? 4;
          final maxAge = data['maxAge'] ?? 17;
          final id = data['id'] ?? 'id';

          if (!startDate.isBefore(currentDate)) {
            return Service(
              serviceName: serviceName,
              description: description,
              centerName: centerName,
              selectedTimeSlot: selectedTimeSlot,
              capacityValue: capacityValue,
              servicePrice: servicePrice,
              selectedStartDate: startDate,
              selectedEndDate: endDate,
              minAge: minAge,
              maxAge: maxAge,
              id: id,
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

  // @override
  // void initState() {
  //   super.initState();
  //   // Fetch the user's name from Firestore when the screen initializes
  //   fetchName();
  // }

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Welcome $FirstName'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.notifications, // Bell icon
                      color: Colors.yellow, // Set icon color to yellow
                    ),
                    // if (hasNewNotification) // Only show the indicator if there are new notifications
                    //   Positioned(
                    //     right: 0,
                    //     top: 0,
                    //     child: Container(
                    //       padding: EdgeInsets.all(4),
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Colors.red, // Indicator color
                    //       ),
                    //       child: Text(
                    //         '1',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
                onPressed:
                    navigateToNotificationsPage, // Navigate to notifications page
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _handleLogout,
              ),
            ],
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
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _handleSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search services...',
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
                      return GestureDetector(
                        onTap: () {
                          // Handle tapping on a service
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            color: Color.fromARGB(255, 239, 249, 254),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.serviceName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'center name: ${service.centerName}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Service Time: ${service.selectedTimeSlot}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ServiceDetailsPage(
                                                      service: service),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'View Details',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
                                              color: Colors.grey,
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
                  icon: Icon(Icons.history), // Home Icon

                  color: Colors.white, // Set icon color to white

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5), // Add margin to the top

                  child: Text(
                    'Booked Service ',
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
                    String currentUserEmail =
                        FirebaseAuth.instance.currentUser?.email ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GProfileViewScreen()),
                    );
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
}
