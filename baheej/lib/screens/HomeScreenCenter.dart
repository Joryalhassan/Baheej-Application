import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:baheej/screens/SignInScreen.dart';

import 'package:baheej/screens/Service.dart';

import 'package:baheej/screens/ServiceFormScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Index for the selected bottom navigation item.

  List<Service> services = [];

  // Function to handle the bottom navigation item selection.

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation when the "Add Service" icon is tapped.

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ServiceFormScreen()),
      ).then((newService) {
        // Check if a new service was returned

        if (newService != null) {
          setState(() {
            // Add the new service to the list

            services.add(newService);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Extend the body to the bottom app bar.

      body: Stack(
        children: [
          // Background Image

          Image.asset(
            'assets/images/backG.png', // Replace with your image path

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
                    'Home',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.logout), // Logout icon

                      onPressed: () {
                        FirebaseAuth.instance.signOut().then((value) {
                          print("Signed Out");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInScreen()),
                          );
                        });
                      },
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
        shape: CircularNotchedRectangle(), // Circular notch at the center.

        color: Color.fromARGB(
            255, 245, 198, 239), // Set bottom app bar color to pink.

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 24), // Add spacing to the left

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.history), // Booking with History Icon

                  color: Colors.white, // Set icon color to white

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

            SizedBox(), // Add empty space in the center

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 50), // Add margin to the bottom

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

            // Add empty space in the center

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.person), // Profile Icon

                  color: Colors.white, // Set icon color to white

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

            SizedBox(width: 32), // Add spacing to the right
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(
            255, 174, 207, 250), // Set FAB background color to pink.

        onPressed: () async {
          final newService = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ServiceFormScreen()),
          );

          if (newService != null) {
            setState(() {
              services.add(newService);
            });
          }
        },

        child: Icon(
          Icons.add,

          color: Colors.white, // Set FAB icon color to white.
        ),
      ),
    );
  }
}
