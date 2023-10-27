import 'package:baheej/screens/GProfileScreen.dart';
import 'package:baheej/screens/HistoryScreen.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

//import 'package:baheej/screens/WelcomePage.dart';

class HomeScreenGaurdian extends StatefulWidget {
  const HomeScreenGaurdian({Key? key}) : super(key: key);

  @override
  _HomeScreenGaurdianState createState() => _HomeScreenGaurdianState();
}

class _HomeScreenGaurdianState extends State<HomeScreenGaurdian> {
  int _currentIndex = 0;

  // Function to handle the bottom navigation item selection.

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Handle the Home button tap

      // You can navigate to the home screen or perform any other action here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the app bar

      appBar: AppBar(
        title: Text("Home"),

        backgroundColor: Colors.transparent, // Make the app bar transparent

        elevation: 0, // Remove the app bar shadow

        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout Icon

            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              });
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          // Background Image

          Positioned.fill(
            child: Image.asset(
              'assets/images/backG.png', // Replace with your image path

              fit: BoxFit.cover,
            ),
          ),

          // Your content goes here
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
                    'Booking Service',
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
                    'Add Child',
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
          // Handle the floating action button tap (Home)

          // You can navigate to the home screen or perform any other action here
        },
        child: Icon(
          Icons.add_reaction_outlined, // Home Icon

          color: Colors.white, // Set FAB icon color to white.
        ),
      ),
    );
  }
}
