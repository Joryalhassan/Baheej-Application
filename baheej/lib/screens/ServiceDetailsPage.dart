import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui' as ui; // Import dart:ui with an alias

class ServiceDetailsPage extends StatefulWidget {
  final Service service;

  ServiceDetailsPage({required this.service});

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  //defind anything you want
  double total = 0.0;
  Map<String, String> selectedKidsNames = {};
  Map<String, dynamic>? paymentIntent;
  String? userEmail; //for gaurdian kids display
  // Tracks the selected kid

  @override
  void initState() {
    super.initState();
    // Fetch the current user's email when the widget is initialized
    final user = FirebaseAuth.instance.currentUser;
    userEmail = user?.email;
    // fetchUserKids();
  }

  //store info in firebase
  Future<void> addServiceToFirestore(
      String selectedTimeSlot, String? userEmail) async {
    try {
      final firestore = FirebaseFirestore.instance;
      if (userEmail == null) {
        print('Error: userEmail is null. Cannot add service to Firestore.');
        return; // Return early or handle the error as needed
      }
      final selectedKidsNames = await getSelectedKidsNames(selectedKids);

      final serviceData = {
        'serviceName': widget.service.serviceName,
        'serviceDescription': widget.service.description,
        'centerName': widget.service.centerName,
        'selectedStartDate': widget.service.selectedStartDate,
        'selectedEndDate': widget.service.selectedEndDate,
        'maxAge': widget.service.maxAge,
        'minAge': widget.service.minAge,
        'servicePrice': widget.service.servicePrice,
        'selectedTimeSlot': selectedTimeSlot,
        //here if you want it as map put selectedKidsNames .
        'selectedKidsNames': selectedKidsNames,
        'totalPrice': total, // Store the calculated total price
        'userEmail': userEmail,
      };

      // Add the data to the 'ServiceBook' collection
      await firestore.collection('ServiceBook').add(serviceData);
      // Update the participant number in the original service document(jory)

      await updateServiceParticipantNo();
    } catch (error) {
      print('Error booking service: $error');
    }
  }

  //function to get kids
  Future<Map<String, String>> getSelectedKidsNames(List<String> kidIds) async {
    final firestore = FirebaseFirestore.instance;
    final selectedKidsNames = <String, String>{};
    for (var kidId in kidIds) {
      final kidDoc = await firestore.collection('Kids').doc(kidId).get();
      if (kidDoc.exists) {
        final kidData = kidDoc.data() as Map<String, dynamic>;
        final kidName = kidData['name'] as String;
        selectedKidsNames[kidId] = kidName;
      }
    }
    return selectedKidsNames;
  }

  Future<void> updateServiceParticipantNo() async {
    try {
      await FirebaseFirestore.instance
          .collection('center-service')
          .doc(widget.service.id)
          .update({
        'participateNo': calculateparticipant(widget.service),
      });
    } catch (error) {
      print('Error updating service participant number: $error');
    }
  } //add it to update part (jory)

  Future<void> succPayment() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // ignore: prefer_const_constructors
          title: Text('Payment Successful'),
          // ignore: prefer_const_constructors
          content: Text('Your payment was successful!'),
          actions: <Widget>[
            TextButton(
              // ignore: prefer_const_constructors
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); //  the dialog
              },
            ),
          ],
        );
      },
    );
  }

//validation conflict service
  Future<void> checkForServiceConflict(
    DateTime selectedStartDate,
    DateTime selectedEndDate,
    String selectedTimeSlot,
  ) async {
    bool conflict = false;
    final firestore = FirebaseFirestore.instance;
    final servicesSnapshot = await firestore.collection('ServiceBook').get();

    for (var doc in servicesSnapshot.docs) {
      final serviceData = doc.data() as Map<String, dynamic>;

      // Extract the date and time from the Firestore document
      final serviceStartDate =
          (serviceData['selectedStartDate'] as Timestamp).toDate();
      final serviceEndDate =
          (serviceData['selectedEndDate'] as Timestamp).toDate();
      final serviceTimeSlot = serviceData['selectedTimeSlot'] as String;

      // Check for conflicts by comparing start date, end date, time slot, and kids
      if (selectedStartDate.isBefore(serviceEndDate) &&
          selectedEndDate.isAfter(serviceStartDate) &&
          selectedTimeSlot == serviceTimeSlot) {
        conflict = true;
        // ignore: use_build_context_synchronously
        // Conflict found
      } //if
    } //for
    if (conflict) {
      print('step1');
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(' Warning!'),
            content: Text(
                'There is a conflict with a prebooked service for the selected time ,date for one of your kids!\nDo you want to proceed with the payment?'),
            actions: <Widget>[
              TextButton(
                child: Text('No'), // User chooses not to proceed
                onPressed: () {
                  Navigator.of(context).pop(); //  the dialog
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  makePayment(context);
                  Navigator.of(context).pop();
                  // showDialog(
                  // Make the payment
                },
              )
            ],
          );
        },
      );
    } else {
      makePayment(context);
      // ignore: use_build_context_synchronously
    } // No conflict found
  }

// create payment
  void makePayment(BuildContext context) async {
    try {
      double totalPrice = calculateTotalPrice(widget.service);
      paymentIntent = await createPaymentIntent(totalPrice);

      // ignore: prefer_const_constructors
      var gpay = PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: 'SAR',
        testEnv: true,
      );

      NumberFormat.currency(locale: 'en_US', symbol: '').format(totalPrice);

      Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "baheej",
          googlePay: gpay,
        ),
      );

      await displayPaymentSheet(context);
      // Always display payment sheet
    } catch (e) {
      print("Error: $e");
    }
  }

  displayPaymentSheet(BuildContext context) async {
    try {
      print('before await');
      await Stripe.instance.presentPaymentSheet();

      print('after await');
      succPayment();
      // Show a success message
      // ignore: use_build_context_synchronously
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       // ignore: prefer_const_constructors
      //       title: Text('Payment Successful'),
      //       // ignore: prefer_const_constructors
      //       content: Text('Your payment was successful!'),
      //       actions: <Widget>[
      //         TextButton(
      //           // ignore: prefer_const_constructors
      //           child: Text('OK'),
      //           onPressed: () {
      //             Navigator.of(context).pop(); //  the dialog
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );

      final user = FirebaseAuth
          .instance.currentUser; //use it for display kids for this gaurd
      final userEmail = user?.email;
      await addServiceToFirestore(widget.service.selectedTimeSlot, userEmail);

      print("Done");
    } catch (e) {
      print("Payment failed or was canceled: $e");
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(double totalPrice) async {
    try {
      Map<String, dynamic> body = {
        "amount": (totalPrice * 100).toInt().toString(), // Amount in cents
        "currency": "SAR", // Currency code
      };
      http.Response response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization":
              "Bearer sk_test_51NxYJkAzFvFRBXEyLv2uL2YXnoi10BOsD6BlEJdyA8hc6O0g6qa4XeQetTJpq0jHZjw966vT7VqZAs2ZaJO8F1Pv00tJ9qnZNk",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      return json.decode(response.body);
    } catch (e) {
      print(e.toString());
      throw Exception(e);
    }
  }

  List<String> selectedKids = [];
  bool isKidsPanelExpanded = false; // List to track selected kids
  int minAge = 0;
  int maxAge = 0;

  void bookService(VoidCallback onKidsSelected) async {
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
    } else {
      onKidsSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    total = widget.service.servicePrice * selectedKids.length.toDouble();
    final double fem = 1.0;
    final double ffem = 1.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "View Details",
          style: TextStyle(
            fontFamily: '5yearsoldfont', // Use the defined font family
            fontSize: 25, // Adjust the font size as needed
            fontWeight: FontWeight.bold, // Add other desired styles
            // Add more styles as required
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              //bottom: 0,
              child: Container(
                width: double.maxFinite,
                height: 400,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/mm.png"),
                        fit: BoxFit.cover)),
              ),
            ),
            Positioned(
              top: 250,
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 10, top: 25),
                //color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 900,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pop(); // Replace '.pop()' with your navigation logic
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.service.serviceName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: '5yearsoldfont',
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                            width: 20), // Adjust the width between the texts

                        Text(
                          '${widget.service.servicePrice} SAR',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: '5yearsoldfont',
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: 300,
                          top: 0), // Adjust the left padding value as needed
                      child: Text(
                        widget.service.centerName,
                        style: TextStyle(
                          fontSize: 20,
                          //fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: 10,
                              top:
                                  0), // Adjust the left padding value as needed
                        ),
                        Icon(
                          Icons.calendar_today_sharp,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Start at:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                            // Add other desired properties like fontSize, fontFamily, etc.
                          ),
                        ),
                        Text(
                          DateFormat('MM/dd/yy')
                              .format(widget.service.selectedStartDate),
                          style: TextStyle(
                            fontSize:
                                20, // Change this to the desired font size
                            // fontWeight:
                            //     20, // Adjust the font weight if needed
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'End at:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                            // Add other desired properties like fontSize, fontFamily, etc.
                          ),
                        ),
                        Text(
                          DateFormat('MM/dd/yy')
                              .format(widget.service.selectedEndDate),
                          style: TextStyle(
                            fontSize:
                                20, // Change this to the desired font size
                            fontWeight: FontWeight
                                .normal, // Adjust the font weight if needed
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: 10,
                              top:
                                  0), // Adjust the left padding value as needed
                        ),
                        Icon(
                          Icons.access_time,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 5),
                        Text(
                          widget.service.selectedTimeSlot,
                          style: TextStyle(
                            fontSize:
                                20, // Change this to the desired font size
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                            // Other text style properties can be added here
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: 15,
                              top:
                                  0), // Adjust the left padding value as needed
                        ),
                        Text(
                          'kids range:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                            // Add other desired properties like fontSize, fontFamily, etc.
                          ),
                        ),
                        Text(
                          widget.service.minAge.toString(),
                          style: TextStyle(
                            fontSize:
                                20, // Change this to the desired font size
                            // fontWeight: FontWeight
                            //     .bold, // If you want the text to be bold
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        Text(
                          "-",
                          style: TextStyle(
                            fontSize:
                                20, // Change this to the desired font size
                            // fontWeight: FontWeight
                            //     .bold, // If you want the text to be bold
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        Text(
                          widget.service.maxAge.toString(),
                          style: TextStyle(
                            fontSize:
                                20, // Change this to the desired font size
                            // fontWeight: FontWeight
                            //     .bold, // If you want the text to be bold
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin:
                          EdgeInsets.fromLTRB(0 * fem, 10, 71 * fem, 40 * fem),
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
                                  207), //primary: Color.fromARGB(255, 213, 214, 214),
                              onPrimary: Color.fromARGB(255, 217, 231,
                                  253), // Change text color when pressed
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: ui.Size(150, 50), // Set button size
                            ),
                            child: Text(
                              'Select Your Kids',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 20, // Change the text color
                                height: 1 * ffem / fem,
                                fontFamily: 'Imprima',
                                fontWeight: FontWeight.w400, // the title place
                              ),
                            ),
                          ),
                          if (isKidsPanelExpanded)
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Kids')
                                  .where('userEmail',
                                      isEqualTo:
                                          userEmail) // Filter by user email
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }

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
                                  if (kidAge >= minAge && kidAge <= maxAge) {
                                    checkboxes.add(
                                      CheckboxListTile(
                                        title: Text(kidName),
                                        value: selectedKids.contains(kid.id),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value != null && value) {
                                              selectedKids.add(kid.id);

                                              // selectedKidsNames[kid.id] =
                                              // kidName;
                                            } else {
                                              selectedKids.remove(kid.id);
                                              selectedKidsNames.remove(kidName);
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
                                checkboxes.add(ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isKidsPanelExpanded = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                  ),
                                  child: Text('Done'),
                                ));
                                return Column(
                                  children: checkboxes,
                                );
                              },
                            )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0), // Adjust the top padding value as needed
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Your existing content...
                            ],
                          ),
                        ),
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontFamily: 'Imprima',
                            fontSize: 18, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  right: 0 * fem, left: 0 * fem),
                              width: 1 * fem,
                              height: 0 * fem,
                            ),
                            SizedBox(height: 0),
                            Text(
                              widget.service.description,
                              style: TextStyle(
                                fontFamily: 'Imprima',
                                fontSize: 20 * ffem,
                                //fontWeight: FontWeight.bold,
                                height: 1.6666666667 * ffem / fem,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  right: 0 * fem, left: 0 * fem),
                              width: 1 * fem,
                              height: 20 * fem,
                            ),
                            Text(
                              '-----------------------------------',
                              style: TextStyle(
                                fontFamily: 'Imprima',
                                fontSize: 20 * ffem,
                                //fontWeight: FontWeight.bold,
                                height: 1.6666666667 * ffem / fem,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 6 * fem),
                              child: Text(
                                'Total Price',
                                style: TextStyle(
                                  fontFamily: 'Imprima',
                                  fontSize: 20 * ffem,
                                  fontWeight: FontWeight.bold,
                                  height: 1.6666666667 * ffem / fem,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 29 * fem),
                              width: 1 * fem,
                              height: 25 * fem,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 6, 6, 6),
                              ),
                            ),
                            Text(
                              ' ${calculateTotalPrice(widget.service)}\ SAR', // Calculate and display total price
                              style: TextStyle(
                                fontFamily: 'Imprima',
                                fontSize: 20 * ffem,
                                fontWeight: FontWeight.bold,
                                height: 1.6666666667 * ffem / fem,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Container(
                      margin: EdgeInsets.fromLTRB(100 * fem, 0, 100 * fem, 0),
                      width: double.infinity,
                      height: 60 * fem,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15 * fem),
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            bookService(() {
                              // Simulate a successful payment, then trigger fireworks
                              checkForServiceConflict(
                                  widget.service.selectedStartDate,
                                  widget.service.selectedEndDate,
                                  widget.service.selectedTimeSlot);
                              //addServiceToFirestore();
                              // Check if payment is successful (you can replace this with your actual logic)
                              //bool paymentSuccessful = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 59, 138, 207),
                            onPrimary: Color.fromARGB(255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            minimumSize: ui.Size(150, 50),
                          ),
                          child: Text(
                            'Pay to Book',
                            style: TextStyle(
                              fontFamily: 'Imprima',
                              fontSize: 22 * ffem,
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
            )
          ],
        ),
      ),
    );
  }

  // Calculate the total price here
  double calculateTotalPrice(Service service) {
    double totalPrice = service.servicePrice * (selectedKids.length);
    return totalPrice;
  }

  int calculateparticipant(Service service) {
    // Update the participant number(jory)
    int newParticipantNo = widget.service.participateNo + (selectedKids.length);
    print(widget.service.participateNo);
    print('calculated kids and add new');
    print(newParticipantNo);
    return newParticipantNo;
  }
}
