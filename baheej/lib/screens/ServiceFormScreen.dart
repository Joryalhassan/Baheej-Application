import 'package:baheej/screens/HomeScreenCenter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String? serviceName;
  int? selectedTimeSlot;
  double? selectedPrice;
  String? selectedDescription;
  int capacityValue = 0;
  String? ageRange;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  bool dateSelected = false;
  bool timeSlotSelected = false;

  // Custom validator functions
  String? validateServiceName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Service name is required';
    }

    final RegExp serviceNamePattern =
        RegExp(r'^(?=.*[A-Za-z])[A-Za-z0-9!@#$%^&*()_+{}\[\]:;<>,.?~\\/\-]+$');

    if (!serviceNamePattern.hasMatch(value)) {
      return 'Service name format is wrong';
    }

    return null;
  }

  String? validateCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'field required';
    }
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'fill a number';
    }
    if (intValue < 0) {
      return 'positive';
    }
    if (intValue == 0) {
      return 'more than 0';
    }
    if (intValue > 30) {
      return 'max 30';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (RegExp(r'[0-9]').hasMatch(value) &&
        RegExp(r'[!@#\$%^&*()_+{}\[\]:;<>,.?~\\/\-]').hasMatch(value)) {
      return 'Description cannot contain a combination of numbers and special characters';
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

    if (doubleValue > 10000) {
      return 'Maximum price limit exceeded (10000)';
    }
    if (doubleValue < 0) {
      return 'There is no negative price!!';
    }

    return null;
  }

  String? validateAgeRange(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final RegExp ageRangePattern = RegExp(r'^(\d+)-(\d+)$');
    final match = ageRangePattern.firstMatch(value);

    if (match == null) {
      return 'Invalid age range format. Please enter a valid numeric range like "8-10".';
    }

    final minAge = int.tryParse(match.group(1) ?? '');
    final maxAge = int.tryParse(match.group(2) ?? '');

    if (minAge == null || maxAge == null || minAge < 4 || maxAge > 17) {
      return 'Age range must be between 4 and 17.';
    }

    return null;
  }

  void sendDataToFirebase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!dateSelected) {
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

    int? endDate = selectedEndDate?.millisecondsSinceEpoch;
    int? startDate = selectedStartDate?.millisecondsSinceEpoch;

    if (endDate != null && startDate != null && endDate < startDate) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text('End date cannot be before the start date!'),
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

    CollectionReference serviceCollection =
        FirebaseFirestore.instance.collection('center-service');

    try {
      await serviceCollection.add({
        'serviceName': serviceName,
        'servicePrice': selectedPrice,
        'serviceCapacity': capacityValue,
        'serviceTime': selectedTimeSlot,
        'serviceDesc': selectedDescription,
        'startDate': selectedStartDate!.toIso8601String(),
        'endDate': selectedEndDate!.toIso8601String(),
        'ageRange': ageRange,
      });

      // Data has been successfully added to Firestore.
      print('Service added to Firestore');
      _showSnackBar('Service added successfully!');

      // Navigate to the HomeCenterScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreenCenter(),
        ),
      );

      // Optionally, you can navigate back to the previous screen or show a success message.
      // ...
    } catch (e) {
      print('Error adding service to Firestore: $e');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration:
          Duration(seconds: 3), // Duration for which the SnackBar is displayed
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildTextField(String label, String? Function(String?)? validator) {
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
                } else if (label == 'Service Price') {
                  selectedPrice = double.tryParse(value);
                } else if (label == 'Service Capacity') {
                  capacityValue = int.tryParse(value) ?? 0;
                } else if (label == 'Service Description') {
                  selectedDescription = value;
                } else if (label == 'Age Range') {
                  ageRange = value;
                }
              });
            },
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
      body: Stack(
        children: [
          Image.asset(
            'assets/images/back3.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 37),
                          child: Column(
                            children: [
                              Text(
                                'Add Service',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                    ],
                  ),
                  buildTextField('Service Name', validateServiceName),
                  buildTextField('Service Price', validatePrice),
                  buildTextField('Age Range', validateAgeRange),
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
                  SizedBox(height: 4.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: buildDateField(
                            'Start Date', selectedStartDate, true),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child:
                            buildDateField('End Date', selectedEndDate, false),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTimeSlot = 0;
                            timeSlotSelected = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: selectedTimeSlot == 0
                              ? Color.fromARGB(255, 59, 138, 207)
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
                            selectedTimeSlot = 1;
                            timeSlotSelected = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: selectedTimeSlot == 1
                              ? Color.fromARGB(255, 59, 138, 207)
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
                  SizedBox(height: 4.0),
                  ElevatedButton(
                    onPressed: () {
                      if (!dateSelected) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Warning'),
                              content: Text(
                                  'You must select both start and end dates!'),
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
                      } else if (!timeSlotSelected) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Warning'),
                              content:
                                  Text('You must select the service time!'),
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
