import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/ServiceForm.dart';

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  int? selectedCapacity;
  int? selectedAge;
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
    final RegExp serviceNamePattern =
        RegExp(r'^[A-Za-z0-9!@#$%^&*()_+{}\[\]:;<>,.?~\\/\-]+$');

    if (!serviceNamePattern.hasMatch(value)) {
      return 'service-name format wrong';
    }

    return null;
  }

  String? validateInt(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid integer';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.contains(new RegExp(r'[0-9]'))) {
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
      return 'there is no negative price!!';
    }

    return null;
  }

  String? validateCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final double? doubleValue = double.tryParse(value);

    if (doubleValue == null) {
      return 'Please enter a valid number';
    }
    // should change the value !
    if (doubleValue > 30) {
      return 'maximum capacity limit exceeded:30';
    }
    if (doubleValue < 10) {
      return 'minimum capacity limit exceeded:10';
    }

    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final double? doubleValue = double.tryParse(value);

    if (doubleValue == null) {
      return 'Please enter a valid number';
    }
    // should change the value !
    if (doubleValue > 17) {
      return 'maximum age is : 17';
    }
    if (doubleValue < 4) {
      return 'minimum age is : 4';
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

    final url = Uri.https(
        'baheejdatabase-default-rtdb.firebaseio.com', 'centers-service.json');

    final response = await http.post(
      url,
      body: json.encode({
        'serviceName': serviceName,
        'servicePrice': selectedPrice,
        'serviceCapacity': selectedCapacity,
        'serviceAge': selectedAge,
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
      print(
          'Error adding service to Firebase Realtime Database: ${response.reasonPhrase}');
      // Handle the error, show an error message, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Service',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255), // Change the color here
          ),
        ),
        backgroundColor: Color.fromARGB(255, 57, 196, 234),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Name'),
                validator: validateServiceName,
                onChanged: (value) {
                  setState(() {
                    serviceName = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Price'),
                validator: validatePrice,
                onChanged: (value) {
                  setState(() {
                    selectedPrice = double.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Age Range'),
                validator: validateAge,
                onChanged: (value) {
                  setState(() {
                    selectedAge = int.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Capacity'),
                validator: validateCapacity,
                onChanged: (value) {
                  setState(() {
                    selectedCapacity = int.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Description'),
                validator: validateDescription,
                onChanged: (value) {
                  setState(() {
                    selectedDescription = value;
                  });
                },
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Start Date: ${selectedStartDate?.toLocal().toString().split(' ')[0] ?? 'Not Selected'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Icon(
                      Icons.calendar_today,
                      color: Color.fromARGB(255, 57, 196, 234),
                      size: 30.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'End Date: ${selectedEndDate?.toLocal().toString().split(' ')[0] ?? 'Not Selected'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Icon(
                      Icons.calendar_today,
                      color: Color.fromARGB(255, 57, 196, 234),
                      size: 30.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.0),
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
                      primary: selectedTimeSlot == 0
                          ? Color.fromARGB(255, 32, 118, 180)
                          : Color.fromARGB(255, 57, 196, 234),
                      onPrimary: Colors.white,
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
                      primary: selectedTimeSlot == 1
                          ? Color.fromARGB(255, 32, 118, 180)
                          : Color.fromARGB(255, 57, 196, 234),
                      onPrimary: Colors.white,
                    ),
                    child: Text('2-5 PM'),
                  ),
                ],
              ),
              SizedBox(height: 40.0),
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
                  primary: Color.fromARGB(255, 32, 118, 180),
                  onPrimary: Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  minimumSize: Size(120, 50),
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
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? selectedStartDate ?? DateTime.now()
          : selectedEndDate ?? DateTime.now(),
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
