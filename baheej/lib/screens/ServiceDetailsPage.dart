import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';
import 'package:intl/intl.dart';

class ServiceDetailsPage extends StatefulWidget {
  final Service service;

  ServiceDetailsPage({required this.service});

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  List<String> selectedKids = [];
  bool isKidsPanelExpanded = false; // List to track selected kids
  int minAge = 0;
  int maxAge = 0;

  void bookService() {
    if (selectedKids.isEmpty) {
      // No kids selected, show a message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Warning!'),
            content: Text('Please select your kids before booking.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (selectedKids.isNotEmpty) {
      // Kids are selected, and the kids selection panel is expanded
      // Proceed with booking logic here

      // Kids are not selected, and the kids selection panel is not expanded
      // Show a message to select kids first
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Warning!'),
            content: Text('there are no kids'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fem = 1.0;
    final double ffem = 1.0;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/backasf.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16, top: 55), //16 the arraw
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: 70),
                Container(
                  margin: EdgeInsets.fromLTRB(10 * fem, 0, 16 * fem, 22 * fem),
                  padding: EdgeInsets.fromLTRB(
                      0, 0, 0, 5 * fem), //5 size of the card
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffffffff)),
                    borderRadius: BorderRadius.circular(20 * fem),
                    gradient: LinearGradient(
                      begin: Alignment(0, -1),
                      end: Alignment(0, 1),
                      colors: <Color>[
                        Color.fromARGB(255, 255, 231, 231),
                        Color.fromARGB(255, 238, 184, 233),
                        Color.fromARGB(237, 214, 240, 254),
                      ],
                      stops: <double>[0, 0, 1],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3f000000),
                        offset: Offset(0 * fem, 4 * fem),
                        blurRadius: 2 * fem,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 30 * fem),
                        width: 400 * fem,
                        height: 95 * fem,
                        // decoration: BoxDecoration(
                        //   //Color.fromARGB(255, 194, 202, 205), grey
                        //   //Color.fromARGB(255, 190, 214, 239), blue
                        //   color: Color.fromARGB(237, 214, 240, 254),
                        //   borderRadius: BorderRadius.circular(20 * fem),
                        // ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                "Service Name:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Imprima',
                                  fontSize: 25 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 2.4 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                              Text(
                                widget.service
                                    .serviceName, // Display service name
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Imprima',
                                  fontSize: 25 * ffem,
                                  fontWeight: FontWeight.w200,
                                  height: 1 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20 * fem),
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(
                                "Description:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Imprima',
                                  fontSize: 25 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                              Text(
                                widget.service
                                    .description, // Display service description
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Imprima',
                                  fontSize: 20 * ffem,
                                  fontWeight: FontWeight.w300,
                                  height: 1 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        margin:
                            EdgeInsets.fromLTRB(0 * fem, 0, 20 * fem, 53 * fem),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(right: 10 * fem),
                                child: Column(
                                  children: [
                                    Text(
                                      "Center Name:",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Imprima',
                                        fontSize: 25 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                    Text(
                                      widget.service
                                          .centerName, // Display center name
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Imprima',
                                        fontSize: 20 * ffem,
                                        fontWeight: FontWeight.w300,
                                        height: 1 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    "Service Price:",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Imprima',
                                      fontSize: 25 * ffem,
                                      fontWeight: FontWeight.w400,
                                      height: 1 * ffem / fem,
                                      color: Color(0xff000000),
                                    ),
                                  ),
                                  Text(
                                    '\$ ${widget.service.servicePrice.toStringAsFixed(2)}', // Display service price
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Imprima',
                                      fontSize: 20 * ffem,
                                      fontWeight: FontWeight.w300,
                                      height: 1 * ffem / fem,
                                      color: Color(0xff000000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10 * fem,
                        ),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Start Date:",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 25 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('MM/dd/yyyy').format(widget.service.selectedStartDate)}', // Display selected start date
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 20 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 100 * fem,
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "End Date:",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 25 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('MM/dd/yyyy').format(widget.service.selectedEndDate)}', // Display selected end date
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 20 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Add max and min age here
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Max Age:",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 25 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 2 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      Text(
                                        widget.service.maxAge.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 20 * ffem,
                                          fontWeight: FontWeight.w300,
                                          height: 1 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 130 * fem,
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Min Age:",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 25 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 2 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      Text(
                                        widget.service.minAge.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 20 * ffem,
                                          fontWeight: FontWeight.w300,
                                          height: 1 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //!!!!!!!!! make sure  with jory //!!!!!!!
                      //
                      //
                      //
                      //
                      //
                      //

                      // Center(
                      //   child: Container(
                      //     margin: EdgeInsets.only(
                      //       right: 280 * fem,
                      //       top: 10 * fem,
                      //     ),
                      //     child: Column(
                      //       children: [
                      //         Text(
                      //           "Time slot:",
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //             fontFamily: 'Imprima',
                      //             fontSize: 25 * ffem,
                      //             fontWeight: FontWeight.w400,
                      //             height: 1 * ffem / fem,
                      //             color: Color(0xff000000),
                      //           ),
                      //         ),
                      //         Text(
                      //           widget.service.selectedTimeSlot,
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //             fontFamily: 'Imprima',
                      //             fontSize: 20 * ffem,
                      //             fontWeight: FontWeight.w300,
                      //             height: 1 * ffem / fem,
                      //             color: Color(0xff000000),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // Display Kids selection panel
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            90 * fem, 0, 71 * fem, 40 * fem),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isKidsPanelExpanded = !isKidsPanelExpanded;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(255, 59, 138,
                                    207), // Change the button's background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Change the button's shape
                                ),
                              ),
                              child: Text(
                                'Select Your Kids',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20, // Change the text color
                                  height: 1 * ffem / fem, // the title place
                                ),
                              ),
                            ),
                            if (isKidsPanelExpanded)
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Kids')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return CircularProgressIndicator();
                                  }

                                  // Calculate the minimum and maximum allowed ages
                                  final minAge = widget.service.minAge as int;
                                  final maxAge = widget.service.maxAge as int;

                                  final kids = snapshot.data!.docs;

                                  List<Widget> checkboxes = [];
                                  bool hasKidsWithinAgeRange = false;

                                  for (var kid in kids) {
                                    final kidData =
                                        kid.data() as Map<String, dynamic>;
                                    final kidName = kidData['name'] as String;
                                    final kidAge = kidData['age'] as int;

                                    // Check if the kid's age is within the allowed range
                                    if (kidAge >= minAge && kidAge <= maxAge) {
                                      checkboxes.add(
                                        CheckboxListTile(
                                          title: Text(kidName),
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
                                      );
                                      hasKidsWithinAgeRange = true;
                                    }
                                  }

                                  if (!hasKidsWithinAgeRange) {
                                    checkboxes.add(
                                      Text(
                                          "You do not have any kids within the age range."),
                                    );
                                  }

                                  // Add the "Done" button at the end
                                  checkboxes.add(
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isKidsPanelExpanded = false;
                                        });
                                      },
                                      child: Text('Done'),
                                    ),
                                  );

                                  return Column(
                                    children: checkboxes,
                                  );
                                },
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(40 * fem, 0, 65, 20 * fem),
                  //80 change the size
                  padding: EdgeInsets.fromLTRB(35 * fem, 0, 27 * fem, 0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 59, 138, 207),
                    borderRadius: BorderRadius.circular(10 * fem),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10 * fem),
                        child: Text(
                          'Total Price',
                          style: TextStyle(
                            fontFamily: 'Imprima',
                            fontSize: 20 * ffem,
                            fontWeight: FontWeight.w400,
                            height: 1.6666666667 * ffem / fem,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 29 * fem),
                        width: 1 * fem,
                        height: 46 * fem,
                        decoration: BoxDecoration(
                          color: Color(0xfffdfdfd),
                        ),
                      ),
                      Text(
                        '\$ ${calculateTotalPrice(widget.service)}', // Calculate and display total price
                        style: TextStyle(
                          fontFamily: 'Imprima',
                          fontSize: 20 * ffem,
                          fontWeight: FontWeight.w400,
                          height: 1.6666666667 * ffem / fem,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(74 * fem, 0, 123 * fem, 0),
                  width: double.infinity,
                  height: 70 * fem,
                  decoration: BoxDecoration(
                    //color: Color.fromARGB(255, 117, 150, 183),
                    borderRadius: BorderRadius.circular(20 * fem),
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: bookService, // Call the bookService function
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 59, 138,
                            207), // Change the background color here
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize: Size(120, 48),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          fontFamily: 'Imprima',
                          fontSize: 20 * ffem,
                          fontWeight: FontWeight.w400,
                          height: 1 * ffem / fem,
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
    );
  }

  // Calculate the total price here
  String calculateTotalPrice(Service service) {
    // Calculate the total price based on the service price and the number of selected kids
    double totalPrice = service.servicePrice * (1 + selectedKids.length);
    return totalPrice.toStringAsFixed(2);
  }
}
