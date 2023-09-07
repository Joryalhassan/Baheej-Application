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

  // Custom validator functions
  String? validateString(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
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

  void sendDataToFirebase() async {
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
        'startDate': selectedStartDate?.toIso8601String(),
        'endDate': selectedEndDate?.toIso8601String(),
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
        title: Text('Add Service'),
        backgroundColor: Color.fromARGB(255, 98, 144, 224),
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
                validator: validateString,
                onChanged: (value) {
                  setState(() {
                    serviceName = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Price'),
                validator: validateInt,
                onChanged: (value) {
                  setState(() {
                    selectedPrice = double.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Age Range'),
                validator: validateInt,
                onChanged: (value) {
                  setState(() {
                    selectedAge = int.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Capacity'),
                validator: validateInt,
                onChanged: (value) {
                  setState(() {
                    selectedCapacity = int.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Description'),
                validator: validateString,
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
                      color: Color.fromARGB(255, 98, 144, 224),
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
                      color: Color.fromARGB(255, 98, 144, 224),
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
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          selectedTimeSlot == 0 ? Colors.green : Colors.grey,
                      onPrimary: Colors.white,
                    ),
                    child: Text('8-11 AM'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTimeSlot = 1; // 2-5 PM
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          selectedTimeSlot == 1 ? Colors.green : Colors.grey,
                      onPrimary: Colors.white,
                    ),
                    child: Text('2-5 PM'),
                  ),
                ],
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, the data will be sent to Firebase.
                    sendDataToFirebase();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
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
      });
    }
  }
}
