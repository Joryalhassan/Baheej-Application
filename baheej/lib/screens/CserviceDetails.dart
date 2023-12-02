import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/CenterProfileScreen.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/EditService.dart';


class CserviceDetails extends StatefulWidget {
  final Service service;


  CserviceDetails({required this.service});

  @override
  _CserviceDetailsState createState() => _CserviceDetailsState();
}

class _CserviceDetailsState extends State<CserviceDetails> {
   //void _showAdMessageDialog() {//comJo
    //showDialog(
      //context: context,
      //builder: (BuildContext context) {
        //return AlertDialog(
        //  title: Text('Create Advertisement'),
         // content: TextField(
            //controller: adMessageController,
          //  decoration: InputDecoration(
           //   hintText: 'Enter your advertisement message',
         //   ),
        //  ),
        //  actions: <Widget>[
           // TextButton(
         //     child: Text('Cancel'),
          //    onPressed: () {
            //    Navigator.of(context).pop();
             // },
            //),
           // TextButton(
            //  child: Text('Submit'),
            //  onPressed: () async {
               // String adMessage = adMessageController.text.trim();
                //if (adMessage.isNotEmpty) {
                  // Store ad message in Firestore under 'notification2' collection
                 // await FirebaseFirestore.instance
                     // .collection('notification2')
                     // .add({
                 //   'message': adMessage,
                 //   'timestamp': DateTime.now(),
                //  });
               //   adMessageController.clear(); // Clear the text field
           //       Navigator.of(context).pop(); // Close the dialog
           //     }
        //      },
        //    ),
       //   ],
      //  );
    //  },
   // );
  //}
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false, // Remove all routes in the stack
    );
  }

 

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          
          SizedBox(width: 60),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome ${widget.service.serviceName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
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
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {
                      // Handle tapping on a service
                    },
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: Color.fromARGB(255, 239, 249, 254),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Program name: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              widget.service.serviceName,
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
                                              DateFormat('MM/dd/yyyy').format(
                                                  widget.service.selectedStartDate),
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
                                              DateFormat('MM/dd/yyyy').format(
                                                  widget.service.selectedEndDate),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Program Time: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                               widget.service.selectedTimeSlot,
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
                                           widget.service.description,
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
                                               widget.service.minAge.toString(),
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
                                               widget.service.maxAge.toString(),
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
                                               widget.service.capacityValue.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                         Row(
                                          children: [
                                            Text(
                                              'Participant Number : ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                               widget.service.participateNo.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Program Price: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${ widget.service.servicePrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        
                                     ],
                        ),
                      ),
                    ),
                  ),
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
                  icon: Icon(Icons.history),
                  color: Colors.white,
                  onPressed: () {
                   // Navigator.push(
                     // context,
                     // MaterialPageRoute(
                      //  builder: (context) =>
                          //  compSerListScreen(centerName: centerName),
                      //),
                   // );//comJo
                    // Handle profile button tap
                  },
                ),
                Text(
                  'Booked Programs',
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
                    'Add Program',
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
    // Define the action to take when the button is pressed
  },
  child: Icon(
    Icons.add,
    color: Colors.white,
  ),
),
    );
  }
}