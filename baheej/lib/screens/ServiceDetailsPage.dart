import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    // Fetch the current user's email when the widget is initialized
    final user = FirebaseAuth.instance.currentUser;
    userEmail = user?.email;
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
    await FirebaseFirestore.instance.collection('center-service')
            .doc(widget.service.id)
            .update({
          'serviceName':widget.service.serviceName,
          'serviceDesc': widget.service.description,
          'centerName': widget.service.centerName,
          'serviceCapacity': widget.service.capacityValue,
          'servicePrice': widget.service.servicePrice,
          'startDate': widget.service.selectedStartDate,
          'endDate': widget.service.selectedEndDate,
          'minAge':widget.service.minAge,
          'maxAge': widget.service.maxAge,
          'selectedTimeSlot': widget.service.selectedTimeSlot,
          'participateNo':calculateparticipant(widget.service),
        });
  } catch (error) {
    print('Error updating service participant number: $error');
  }
}//add it to update part (jory)

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
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text('Yes'), // User chooses to proceed with payment
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  makePayment(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      // ignore: use_build_context_synchronously
      makePayment(context);
    } // No conflict found
  }

// create payment
  void makePayment(BuildContext context) async {
    try {
      double totalPrice = calculateTotalPrice(widget.service);
      paymentIntent = await createPaymentIntent(totalPrice);

      // ignore: prefer_const_constructors
     // var gpay = PaymentSheetGooglePay(
      //  merchantCountryCode: "US",
      //  currencyCode: 'SAR',
       // testEnv: true,
     // );//make it comment(jory)

      String formattedPrice =
          NumberFormat.currency(locale: 'en_US', symbol: '').format(totalPrice);

    //  Stripe.instance.initPaymentSheet(
     //   paymentSheetParameters: SetupPaymentSheetParameters(
      //    paymentIntentClientSecret: paymentIntent!["client_secret"],
      //    style: ThemeMode.dark,
      //    merchantDisplayName: "baheej",
      //    googlePay: gpay,
//),
     // );//make it comment(jory)

      await displayPaymentSheet(context); // Always display payment sheet
    } catch (e) {
      print("Error: $e");
    }
  }

  displayPaymentSheet(BuildContext context) async {
    try {
      print('before await');
     // await Stripe.instance.presentPaymentSheet();//make it comment(jory)
      print('after await');
      // Show a success message
      // ignore: use_build_context_synchronously
       
      
      
      showDialog(
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
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
      

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
        title: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Text(
            "Service details",
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: Color.fromARGB(0, 255, 255, 255),
        elevation: 0,
      ),
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
                ),
                SizedBox(height: 70),
                Container(
                  margin: EdgeInsets.fromLTRB(10 * fem, 0, 16 * fem, 22 * fem),
                  padding: EdgeInsets.fromLTRB(
                      0, 0, 0, 5 * fem), //5 size of the card
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border:
                        //Color.fromARGB(255, 229, 226, 226)
                        Border.all(color: Color.fromARGB(255, 250, 249, 249)),
                    borderRadius: BorderRadius.circular(20 * fem),
                    gradient: LinearGradient(
                      begin: Alignment(0, -1),
                      end: Alignment(0, 1),
                      colors: <Color>[
                        Color.fromARGB(255, 239, 249, 254),
                        Color.fromARGB(255, 239, 249, 254),
                        Color.fromARGB(255, 239, 249, 254)

                        // Color.fromARGB(255, 255, 231, 231),
                        // Color.fromARGB(255, 238, 184, 233),
                        // Color.fromARGB(237, 214, 240, 254),
                      ],
                      stops: <double>[0, 0, 1],
                    ),
                    boxShadow: [
                      BoxShadow(
                        //Color.fromARGB(62, 212, 208, 214),
                        color: Color.fromARGB(60, 173, 170, 174),
                        offset: Offset(
                          8 * fem,
                          8 * fem,
                        ),
                        blurRadius: 4 * fem,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            right: 100 * fem, left: 0 * fem, bottom: 10 * fem),
                        width: 400 * fem,
                        height: 80 * fem,
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                widget.service
                                    .serviceName, // Display service name
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Imprima',
                                  fontSize: 25 * ffem,
                                  //fontWeight: FontWeight.w200,
                                  fontWeight: FontWeight.bold,
                                  height: 3 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.fromLTRB(
                            20 * fem, 0, 200 * fem, 20 * fem),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: 0 * fem, left: 0 * fem, bottom: 0),
                                child: Column(
                                  children: [
                                    Text(
                                      widget.service
                                          .centerName, // Display center name
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Imprima',
                                        fontSize: 20 * ffem,
                                        fontWeight: FontWeight.w500,
                                        height: 1 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20 * fem,
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
                                        'Start Date : ${DateFormat('MM/dd/yyyy').format(widget.service.selectedStartDate)}', // Display selected start date
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Column(),
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'End Date : ${DateFormat('MM/dd/yyyy').format(widget.service.selectedEndDate)}', // Display selected end date
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Imprima',
                                          fontSize: 20 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 2 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 6,
                                      top: 5 *
                                          fem), // Adjust the value as needed
                                  child: Text(
                                    "Age range: ",
                                    style: TextStyle(
                                      fontFamily: 'Imprima',
                                      fontSize: 20 * ffem,
                                      fontWeight: FontWeight.w400,
                                      height: 1 * ffem / fem,
                                      color: Color(0xff000000),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${widget.service.minAge} - ${widget.service.maxAge}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Imprima',
                                    fontSize: 20 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 2 * ffem / fem,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ],
                            ),

                            //end row
                          ],
                        ),
                      ),
                      // service time
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: 160 * fem,
                            top: 10 * fem,
                            left: 15,
                          ),
                          child: Row(
                            children: [
                              Text(
                                ' Time: ',
                                style: TextStyle(
                                  fontFamily: 'Imprima',
                                  fontSize: 20 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                              Text(
                                widget.service.selectedTimeSlot,
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
                      ),

                      Container(
                        margin: EdgeInsets.only(
                            right: 180 * fem,
                            left: 15 * fem,
                            bottom: 10 * fem,
                            top: 15 * fem),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              ' Price: ',
                              style: TextStyle(
                                fontFamily: 'Imprima',
                                fontSize: 20 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1 * ffem / fem,
                                color: Color(0xff000000),
                              ),
                            ),
                            Text(
                              ' ${widget.service.servicePrice.toStringAsFixed(2)}\ SAR', // Display service price
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

                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                              bottom: 35 * fem,
                              top: 8 * fem,
                              right: 230 * fem,
                              left: 16 * fem),
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(
                                "Description",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Imprima',
                                  fontSize: 24 * ffem,
                                  fontWeight: FontWeight.w300,
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
                                  fontWeight: FontWeight.w200,
                                  height: 1 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Display Kids selection panel
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            20 * fem, 0, 71 * fem, 40 * fem),
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
                                primary: Color.fromARGB(255, 255, 255,
                                    255), //primary: Color.fromARGB(255, 213, 214, 214),
                                onPrimary: Color.fromARGB(255, 217, 231,
                                    253), // Change text color when pressed
                                // shape: RoundedRectangleBorder(
                                // borderRadius: BorderRadius.circular(30.0),
                                // ),
                                ///shadowColor: Color(black),
                                minimumSize: Size(100, 48), // Set button size
                              ),
                              child: Text(
                                'Select Your Kids',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 20, // Change the text color
                                  height: 1 * ffem / fem,
                                  fontFamily: 'Imprima',
                                  fontWeight:
                                      FontWeight.w400, // the title place
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

                                                // selectedKidsNames[kid.id] =
                                                // kidName;
                                              } else {
                                                selectedKids.remove(kid.id);
                                                selectedKidsNames
                                                    .remove(kidName);

                                                // selectedKidsNames
                                                // .remove(kid.id);
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
                  margin: EdgeInsets.fromLTRB(40 * fem, 0, 57, 20 * fem),
                  //80 change the size
                  padding: EdgeInsets.fromLTRB(35 * fem, 0, 27 * fem, 0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    //borderRadius: BorderRadius.circular(30 * fem),
                  ),
                  child: Row(
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
                        height: 46 * fem,
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
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(74 * fem, 0, 123 * fem, 0),
                  width: double.infinity,
                  height: 70 * fem,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20 * fem),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      bookService(() {
                         makePayment(context);
                        // Simulate a successful payment, then trigger fireworks
                      //  checkForServiceConflict(
                        //    widget.service.selectedStartDate,
                        //    widget.service.selectedEndDate,
                         //   widget.service.selectedTimeSlot);
                        //addServiceToFirestore();
                        // Check if payment is successful (you can replace this with your actual logic)
                        //bool paymentSuccessful = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 59, 138, 207),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: Size(120, 48),
                    ),
                    child: Center(
                      child: Text(
                        'pay to book',
                        style: TextStyle(
                          fontFamily: 'Imprima',
                          fontSize: 25 * ffem,
                          fontWeight: FontWeight.w400,
                          height: 1 * ffem / fem,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
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
    int newParticipantNo = service.participantNo + (selectedKids.length);
    print('calculated kids and add new');
    print(newParticipantNo);
    return newParticipantNo;
}
}