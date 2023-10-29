import 'package:baheej/notification_manager/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Service> services = [];
  String userName = ''; // Initialize userName
  String? userRole;
  TextEditingController notificationMessageController = TextEditingController();

  // Future<void> sendNotification(String message) async {
  //   final firestore = FirebaseFirestore.instance;
  //   await firestore.collection('notifications').add({
  //     'message': message,
  //     'timestamp': FieldValue.serverTimestamp(),
  //     'seenBy':
  //         [] // This will be an empty list, as no one has seen the notification yet.
  //   });
  // }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      navigateToServiceFormScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the user's name from Firestore when the screen initializes
    fetchUserName();
    fetchUserRoleAndName();
  }

  // This function fetches both the user's role and name
  Future<void> fetchUserRoleAndName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final centerDoc = await FirebaseFirestore.instance
          .collection('center')
          .doc(userId)
          .get();
      if (centerDoc.exists) {
        userRole = 'center'; // Set user role to center
        final userData = centerDoc.data() as Map<String, dynamic>;
        final firstName = userData['username'] ?? '';
        setState(() {
          userName = firstName;
        });
      } else {
        final guardianDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (guardianDoc.exists) {
          userRole = 'guardian'; // Set user role to guardian
        }
      }
    }
  }

  Future<void> sendNotification(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final userRole = userDoc['userType'];
        if (userRole == 'center') {
          final firestore = FirebaseFirestore.instance;
          await firestore.collection('notifications').add({
            'message': message, // Use the custom message
            'timestamp': FieldValue.serverTimestamp(),
            'seenBy': []
          });
        }
      }
    }
  }

  void fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('center')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final firstName =
            userData['username'] ?? ''; // Get the first name from Firestore
        setState(() {
          userName = firstName;
        });
      }
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

  void navigateToServiceFormScreen() async {
    final newService = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServiceFormScreen()),
    );

    if (newService != null) {
      setState(() {
        services.add(newService);
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    // final userName = user?.displayName ?? 'User';

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/backG.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Welcome $userName',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: _handleLogout,
                      color: Colors.white,
                    ),
                  ],
                  floating: false,
                  pinned: true,
                  snap: false,
                ),
              ];
            },
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Send Notification'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextField(
                                      controller: notificationMessageController,
                                      decoration: InputDecoration(
                                        labelText: 'Notification Message',
                                      ),
                                    ),
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
                                    child: Text('Done'),
                                    onPressed: () {
                                      sendNotification(
                                          notificationMessageController.text);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Send Notification'),
                      )
                    ],
                  ),
                  Column(
                    children: services.map((service) {
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(service.serviceName),
                          subtitle: Text(
                            'Start Date: ${service.selectedStartDate.toLocal().toString().split(' ')[0]} - End Date: ${service.selectedEndDate.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
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
                  icon: Icon(Icons.history),
                  color: Colors.white,
                  onPressed: () {
                    // Handle booking history button tap
                  },
                ),
                Text(
                  'Booking Service',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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
        onPressed: () async {
          navigateToServiceFormScreen();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
