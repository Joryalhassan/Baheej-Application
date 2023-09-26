import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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

//TextField
  String? serviceName;
  String? serviceCenter;
  String? centerName;
  String? selectedTimeSlot;
  double? selectedPrice;
  String? selectedDescription;
  int capacityValue = 0;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool dateSelected = false;
  bool timeSlotSelected = false;
  int minAge = 4;
  int maxAge = 17;
  //String? ageRange;

  //validation

//name
  String? validateServiceName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Service name is required';
    }

    if (value.length < 5 || value.length > 20) {
      return 'Service name should be between 5 and 20 characters';
    }

    final RegExp serviceNamePattern = RegExp(r'^[a-zA-Z0-9\s]+$');

    if (!serviceNamePattern.hasMatch(value)) {
      return 'Service name should only contain letters, numbers, and spaces';
    }

    return null;
  }

  //capacity

  String? validateCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field required';
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

// description
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

//price
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

  //age range

  String? validateMinRange(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final RegExp ageRangePattern = RegExp(r'^(\d+)-(\d+)$');
    final match = ageRangePattern.firstMatch(value);

    // final minAge = int.tryParse(match.group(1) ?? '');
    // final maxAge = int.tryParse(match.group(2) ?? '');

    if (minAge == null) {
      return 'fill min age.';
    }

    if (minAge < 4) {
      return 'min age = 4';
    }
    if (minAge > 17) {
      return 'max age = 17';
    }

    return null;
  }

  String? validateMaxRange(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final RegExp ageRangePattern = RegExp(r'^(\d+)-(\d+)$');
    final match = ageRangePattern.firstMatch(value);

    // final minAge = int.tryParse(match.group(1) ?? '');
    // final maxAge = int.tryParse(match.group(2) ?? '');

    if (maxAge == null) {
      return 'fill max age.';
    }

    if (maxAge < 4) {
      return 'min age = 4';
    }
    if (maxAge > 17) {
      return 'min age = 4';
    }

    return null;
  }

//store in firebase database

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
        'serviceTime': selectedTimeSlot,
        'serviceDesc': selectedDescription,
        'startDate': selectedStartDate!.toIso8601String(),
        'endDate': selectedEndDate!.toIso8601String(),
        // 'ageRange': ageRange,
        'minAge': minAge,
        'maxAge': maxAge
      });

      // Data has been successfully added to Firestore.
      print('Service added to Firestore');
      // show msg
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
                Navigator.of(context).pop(); // Close the dialog
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
                } else if (label == 'Service Price') {
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
                onPressed: () {
                  setState(() {
                    if (maxAge > 4) {
                      maxAge -= 1;
                      onDecrement();
                    }
                  });
                },
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
                    buildTextField('Center Name', validateServiceName,
                        maxLength: 20),
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
                                4), // Add spacing between the fields (adjust as needed)
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
                    SizedBox(height: 4.0),
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

  // Widget buildIncrementDecrementField(
  //   String label,
  //   int value,
  //   VoidCallback increment,
  //   VoidCallback decrement,
  // ) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 8),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),
  //         SizedBox(height: 4),
  //         Row(
  //           children: [
  //             IconButton(
  //               icon: Icon(Icons.remove),
  //               onPressed: decrement,
  //             ),
  //             Text(
  //               value.toString(),
  //               style: TextStyle(
  //                 fontSize: 16,
  //               ),
  //             ),
  //             IconButton(
  //               icon: Icon(Icons.add),
  //               onPressed: increment,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
