import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:baheej/screens/Service.dart';

class ServiceFormScreen extends StatefulWidget {
  @override
  _ServiceFormScreenState createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? serviceName;
  int? selectedTimeSlot;
  double? selectedPrice;
  String? selectedDescription;
  int capacityValue = 0; // Initial capacity value

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // Variables to track the state of date and time fields
  bool dateSelected = false;
  bool timeSlotSelected = false;

  // Custom validator functions
  String? validateServiceName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Service name is required';
    }

    // Use a regular expression to check if the service name contains only letters, numbers, and special characters (excluding spaces).
    final RegExp serviceNamePattern = RegExp(r'^[A-Za-z0-9!@#$%^&*()_+{}\[\]:;<>,.?~\\/\-]+$');

    if (!serviceNamePattern.hasMatch(value)) {
      return 'Service name format is wrong';
    }

    return null;
  }

  String? validateCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 0 || intValue > 15000) {
      return 'Please enter a valid capacity between 0 and 15000';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.contains(RegExp(r'[0-9]'))) {
      return 'Description cannot contain numbers';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final double? doubleValue = double.tryParse(value);

    if (doubleValue == null) {
      return 'Please enter a valid number';
    }

    // should change the value !
    if (doubleValue > 1000) {
      return 'Maximum price limit exceeded (1000)';
    }

    if (doubleValue < 0) {
      return 'There is no negative price!!';
    }

    return null;
  }

  void sendDataToFirebase() async {
    // Check the state of the date and time fields
    if (!dateSelected) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text('You must select the service date!'),
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
      return;
    }

    if (!timeSlotSelected) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text('You must select the service time!'),
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
      return;
    }

    // Check if start and end dates are selected
    if (selectedStartDate == null || selectedEndDate == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text('You must select both start and end dates!'),
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
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return; // Do not send data if there are errors in other fields
    }

    final url = Uri.https('baheejdatabase-default-rtdb.firebaseio.com', 'centers-service.json');

    final response = await http.post(
      url,
      body: json.encode({
        'serviceName': serviceName,
        'servicePrice': selectedPrice,
        'serviceCapacity': capacityValue,
        'serviceTime': selectedTimeSlot,
        'serviceDesc': selectedDescription,
        'startDate': selectedStartDate!.toIso8601String(),
        'endDate': selectedEndDate!.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      print('Service added to Firebase Realtime Database');
      // Optionally, you can navigate back to the previous screen or show a success message.
    } else {
      print('Error adding service to Firebase Realtime Database: ${response.reasonPhrase}');
      // Handle the error, show an error message, etc.
    }
  }

  Widget buildTextField(String label, String? Function(String?)? validator) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8), // Add space between label and text field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.grey[300],
            ),
            child: TextFormField(
              keyboardType: label == 'Service Capacity' ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                hintText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Adjust padding
                border: InputBorder.none, // Remove the default border
              ),
              validator: label == 'Service Capacity' ? validateCapacity : validator,
              onChanged: (value) {
                setState(() {
                  if (label == 'Service Name') {
                    serviceName = value;
                  } else if (label == 'Service Price') {
                    selectedPrice = double.tryParse(value);
                  } else if (label == 'Service Capacity') {
                    capacityValue = int.tryParse(value) ?? 0;
                  } else if (label == 'Service Description') {
                    selectedDescription = value;
                  }
                });
              },
              onTap: () {
                if (label == 'Service Capacity') {
                  setState(() {
                    if (capacityValue == 0) {
                      capacityValue = 0;
                    }
                  });
                }
              },
            ),
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
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8), // Add space between label and text field
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: onDecrement,
              ),
              Container(
                width: 100, // Set a fixed width here
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.grey[300],
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ), // Adjust padding
                    border: InputBorder.none, // Remove the default border
                  ),
                  validator: validateCapacity,
                  onChanged: (newValue) {
                    // You can add validation or additional logic here if needed.
                    // For this example, we'll leave it as is.
                  },
                  controller: TextEditingController(text: value == 0 ? '' : value.toString()),
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
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8), // Add space between label and text field
          InkWell(
            onTap: () => _selectDate(context, isStartDate),
            child: Container(
              height: 48.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
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
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/back3.png', // Replace with your background image asset path or network image URL
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, left: 0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Add Service',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  buildTextField('Service Name', validateServiceName),
                  buildTextField('Service Price', validatePrice),
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
                  ),
                  buildTextField('Service Description', validateDescription),
                  SizedBox(height: 10.0), // Reduced space between date fields and options
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: buildDateField('Start Date', selectedStartDate, true),
                      ),
                      SizedBox(width: 16), // Add some horizontal spacing
                      Expanded(
                        child: buildDateField('End Date', selectedEndDate, false),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0), // Reduced space between date fields and options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTimeSlot = 0; // 8-11 AM
                            timeSlotSelected = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: selectedTimeSlot == 0 ? Color.fromARGB(255, 241, 106, 210) : const Color.fromARGB(255, 250, 163, 230),
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          minimumSize: Size(100, 50), // Adjust the width as needed
                        ),
                        child: Text('8-11 AM'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTimeSlot = 1; // 2-5 PM
                            timeSlotSelected = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: selectedTimeSlot == 1 ? Color.fromARGB(255, 241, 106, 210) : Color.fromARGB(255, 250, 163, 230),
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          minimumSize: Size(100, 50), // Adjust the width as needed
                        ),
                        child: Text('2-5 PM'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0), // Reduced space between "Done" button and options
                  ElevatedButton(
                    onPressed: () {
                      // Check the state of the date and time fields
                      if (!dateSelected) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Warning'),
                              content: Text('You must select the service date'),
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
                        return;
                      }

                      if (!timeSlotSelected) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Warning'),
                              content: Text('You must select the service time'),
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
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, send the data to Firebase.
                        sendDataToFirebase();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 111, 176, 234),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: Size(120, 50), // Adjust the width as needed
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? selectedStartDate ?? DateTime.now() : selectedEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = pickedDate;
        } else {
          selectedEndDate = pickedDate;
        }

        // Update the date field state
        dateSelected = true;
      });
    }
  }
}
