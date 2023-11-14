import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MaterialApp(
    home: ServiceFormScreen(),
  ));
}

class ServiceFormScreen extends StatefulWidget {
  @override
  _ServiceFormScreenState createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
String userName = '';// add this to store centername(jo)
  // TextField Declarations
  String? serviceName;
  String? serviceCenter;
 // String? centerName;
  String? selectedTimeSlot;
  double? selectedPrice;
  String? selectedDescription;
  int capacityValue = 10;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool dateSelected = false;
  bool timeSlotSelected = false;
  int minAge = 4;
  int maxAge = 17;
   @override
  void initState() {// add this to store centername(jo)
    super.initState();
    // Fetch the user's name from Firestore when the screen initializes
    fetchUserName();
  }

  void fetchUserName() async {// add this to store centername(jo)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('center')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final CenterName =
            userData['username'] ?? ''; // Get the first name from Firestore
        setState(() {
          userName = CenterName;
        });
      }
    }
  }

  // Center name validation
  String? validateCenterName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Center name is required';
    }

    if (value.trim().isEmpty) {
      return 'Center name should not be only spaces';
    }

    return null;
  }

  // Service name
  String? validateServiceName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Service name is required';
    }

    if (value.trim().isEmpty) {
      return 'Service name should not be only spaces';
    }

    if (value.length < 5 || value.length > 20) {
      return 'Service name should be between 5 and 20 characters';
    }

    final RegExp serviceNamePattern = RegExp(r'^[a-zA-Z0-9\s]+$');

    if (!serviceNamePattern.hasMatch(value)) {
      return 'Service name should only contain letters,\n numbers, and spaces';
    }

    return null;
  }

  // Capacity
  String? validateCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field \n required';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Fill a number';
    }
    if (intValue < 0) {
      return 'Positive';
    }
    if (intValue == 0) {
      return 'More than 0';
    }
    if (intValue > 1000) {
      return 'Max 1000';
    }
    return null;
  }

  // Description
  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.trim().isEmpty) {
      return 'Description should not be only spaces';
    }
    if (value.length < 5) {
      return 'Description should be at least 5 characters long';
    }
    if (value.length > 225) {
      return 'Description should not exceed 225 characters';
    }
    if (!RegExp(r'[a-zA-Z!@#\$%^&*()_+{}\[\]:;<>,.?~\\/\-]').hasMatch(value)) {
      return 'Description should contain at least one non-numeric character';
    }
    return null;
  }

  // Price
  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final RegExp validPricePattern = RegExp(r'^\d+(\.\d+)?$');

    if (!validPricePattern.hasMatch(value)) {
      return 'Only numbers are allowed';
    }
    final double? doubleValue = double.tryParse(value);
    if (doubleValue == null) {
      return 'Please enter a valid number';
    }
    if (doubleValue > 10000) {
      return 'Maximum price limit exceeded (10000)';
    }
    if (doubleValue < 0) {
      return 'There is no negative price!!';
    }
    return null;
  }

  // Widget buildPriceTextField() {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 8),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Service Price',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),
  //         SizedBox(height: 4),
  //         TextFormField(
  //           keyboardType: TextInputType.phone, // Change here
  //           inputFormatters: <TextInputFormatter>[
  //             FilteringTextInputFormatter.digitsOnly,
  //             // Allow only digits and a single dot
  //             FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  //           ],
  //           decoration: InputDecoration(
  //             hintText: '',
  //             filled: true,
  //             fillColor: Colors.grey[300],
  //             contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12.0),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12.0),
  //               borderSide: BorderSide(color: Colors.transparent),
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12.0),
  //               borderSide: BorderSide(color: Colors.transparent),
  //             ),
  //           ),
  //           validator: validatePrice,
  //           onChanged: (value) {
  //             setState(() {
  //               selectedPrice = double.tryParse(value);
  //             });
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Age range validation
  String? validateMinRange(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final minAge = int.tryParse(value);
    if (minAge == null) {
      return 'Please enter a valid age';
    }

    if (minAge > maxAge) {
      return 'Minimum age cannot \n be greater than maximum age';
    }

    return null;
  }

  String? validateMaxRange(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final maxAge = int.tryParse(value);
    if (maxAge == null) {
      return 'Please enter a valid age';
    }

    if (maxAge < minAge) {
      return 'max greater \n than min';
    }

    return null;
  }

  // Method to send data to Firebase
  void sendDataToFirebase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!dateSelected) {
      _showDialog('Warning', 'You must select both start and end dates!');
      return;
    }

    if (!timeSlotSelected) {
      _showDialog('Warning', 'You must select the service time!');
      return;
    }

    final int? endDate = selectedEndDate?.millisecondsSinceEpoch;
    final int? startDate = selectedStartDate?.millisecondsSinceEpoch;

    if (endDate != null && startDate != null && endDate < startDate) {
      _showDialog('Warning', 'End date cannot be before the start date!');
      return;
    }

    CollectionReference serviceCollection =
        FirebaseFirestore.instance.collection('center-service');
        

    try {
      await serviceCollection.add({
        'serviceName': serviceName,
        'servicePrice': selectedPrice,
        'serviceCapacity': capacityValue,
        'selectedTimeSlot': selectedTimeSlot,
        'serviceDesc': selectedDescription,
        'startDate': selectedStartDate!.toIso8601String(),
        'endDate': selectedEndDate!.toIso8601String(),
        'centerName': userName,// change this to store centername(jo)
        'minAge': minAge,
        'maxAge': maxAge
      });

      // Data has been successfully added to Firestore.
      print('Service added to Firestore');
      _showSuccessDialog();
    } catch (e) {
      print('Error adding service to Firestore: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Service added successfully!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
              //Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(true); // Navigate back to HomeScreen with a success flag
                  
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// create TextField
  Widget buildTextField(
    String label,
    String? Function(String?)? validator, {
    int? maxLength,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          TextFormField(
            keyboardType: label == 'Service Capacity'
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: '',
              filled: true,
              fillColor: Colors.grey[300],
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
            validator:
                label == 'Service Capacity' ? validateCapacity : validator,
            onChanged: (value) {
              setState(() {
                if (label == 'Service Name') {
                  serviceName = value;
                } //else if (label == 'Center Name') {
                  //centerName = value; // Update centerName here
                //} / commented this to store centername(jo)
                else if (label == 'Service Price') {
                  selectedPrice = double.tryParse(value);
                } else if (label == 'Service Capacity') {
                  capacityValue = int.tryParse(value) ?? 0;
                } else if (label == 'Service Description') {
                  selectedDescription = value;
                } else if (label == 'Min Age') {
                  minAge = int.tryParse(value) ?? 0;
                } else if (label == 'Max Age') {
                  maxAge = int.tryParse(value) ?? 0;
                }
              });
            },
            maxLength: maxLength,
          ),
        ],
      ),
    );
  }

  Widget buildIncrementDecrementMinAgeField(
    String label,
    int minAge, // Change from value to minAge
    void Function() onIncrement,
    void Function() onDecrement,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (minAge > 4) {
                      minAge -= 1;
                      onDecrement();
                    }
                  });
                },
              ),
              Container(
                width: 60,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  validator: validateMaxRange,
                  onChanged: (newValue) {},
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  ],
                  controller: TextEditingController(
                    text: minAge.toString(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (minAge < 17) {
                      // Change from minAge < 17 to minAge <= 17
                      minAge += 1;
                      onIncrement();
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildIncrementDecrementMaxAgeField(
    String label,
    int maxAge, // Change from value to maxAge
    void Function() onIncrement,
    void Function() onDecrement,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (maxAge > 4) {
                      // Change from maxAge > 4 to maxAge >= 4
                      maxAge -= 1;
                      onDecrement();
                    }
                  });
                },
              ),
              Container(
                width: 60,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  validator: validateMaxRange,
                  onChanged: (newValue) {},
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  ],
                  controller: TextEditingController(
                    text: maxAge.toString(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (maxAge < 17) {
                      maxAge += 1;
                      onIncrement();
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildIncrementDecrementField(
    String label,
    int value,
    void Function() onIncrement,
    void Function() onDecrement,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: onDecrement,
              ),
              Container(
                width: 100,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  validator: validateCapacity,
                  onChanged: (newValue) {},
                  controller: TextEditingController(
                      text: value == 0 ? '' : value.toString()),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDateField(
    String label,
    DateTime? selectedDate,
    bool isStartDate,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          InkWell(
            onTap: () => _selectDate(context, isStartDate),
            child: Container(
              height: 48.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      selectedDate != null
                          ? selectedDate.toLocal().toString().split(' ')[0]
                          : 'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(255, 101, 101, 101),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/backasf.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 130.0),
                          child: Text(
                            'Add Service',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    buildTextField('Service Name', validateServiceName,
                        maxLength: 20),
                   // buildTextField('Center Name', validateServiceName,
                     //   maxLength: 20),/ commented this to store centername(jo)
                    buildTextField('Service Price', validatePrice),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Adjust this as needed
                      children: [
                        Expanded(
                          child: buildIncrementDecrementMinAgeField(
                            'Min Age',
                            minAge,
                            () {
                              setState(() {
                                minAge += 1;
                              });
                            },
                            () {
                              setState(() {
                                if (minAge >= 4) {
                                  minAge -= 1;
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                            width:
                                1), // Add spacing between the fields (adjust as needed)
                        Expanded(
                          child: buildIncrementDecrementMaxAgeField(
                            'Max Age',
                            maxAge,
                            () {
                              setState(() {
                                maxAge += 1;
                              });
                            },
                            () {
                              setState(() {
                                if (maxAge >= 4) {
                                  maxAge -= 1;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),

// max age

                    buildIncrementDecrementField(
                      'Service Capacity',
                      capacityValue,
                      () {
                        setState(() {
                          capacityValue += 10;
                        });
                      },
                      () {
                        setState(() {
                          if (capacityValue >= 10) {
                            capacityValue -= 10;
                          }
                        });
                      },
                    ), // capacity
                    buildTextField('Service Description', validateDescription,
                        maxLength: 225),
                    SizedBox(height: 2.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: buildDateField(
                              'Start Date', selectedStartDate, true),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: buildDateField(
                              'End Date', selectedEndDate, false),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),
                    Text(
                      'Service Period Time',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedTimeSlot = '8-11 AM';

                              timeSlotSelected = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedTimeSlot == '8-11 AM'
                                ? Color.fromARGB(255, 0, 65, 105)
                                : const Color.fromARGB(255, 111, 176, 234),
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            minimumSize: Size(100, 40),
                          ),
                          child: Text('8-11 AM'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedTimeSlot = '2-5 PM';

                              timeSlotSelected = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedTimeSlot == '2-5 PM'
                                ? Color.fromARGB(255, 0, 65, 105)
                                : Color.fromARGB(255, 111, 176, 234),
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            minimumSize: Size(100, 40),
                          ),
                          child: Text('2-5 PM'),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    ElevatedButton(
                      onPressed: () {
                        if (!dateSelected) {
                          _showDialog('Warning',
                              'You must select both start and end dates!');
                        } else if (selectedTimeSlot == null) {
                          _showDialog(
                              'Warning', 'You must select the service time!');
                        } else {
                          sendDataToFirebase();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 59, 138, 207),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize: Size(100, 40),
                      ),
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? selectedStartDate ?? DateTime.now()
          : selectedEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null &&
        picked != (isStartDate ? selectedStartDate : selectedEndDate)) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }
        dateSelected = selectedStartDate != null && selectedEndDate != null;
      });
    }
  }
}