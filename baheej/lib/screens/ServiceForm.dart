import 'package:flutter/material.dart';
import 'package:baheej/screens/Service.dart';

class ServiceFormScreen extends StatefulWidget {
  @override
  _ServiceFormScreenState createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? serviceName;
  TimeOfDay selectedTime = TimeOfDay.now();
  double? selectedPrice;
  String? selectedDescription;
  int? selectedCapacity;
  int? selectedAge;
  DateTime selectedDate = DateTime.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101), // You can adjust the range of selectable dates
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    serviceName = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service price';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    selectedPrice = double.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Age Range'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service age range';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    selectedAge = int.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Capacity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service capacity';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    selectedCapacity = int.tryParse(value);
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Service Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service description';
                  }
                  return null;
                },
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
                  Text('Time: ${selectedTime.format(context)}'),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 98, 144,
                          224), // Change the background color of the "Select Date" button
                      onPrimary: Colors
                          .white, // Change the text color of the "Select Date" button
                    ),
                    child: Text('Select Time'),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Date: ${selectedTime.format(context)}'),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 98, 144,
                          224), // Change the background color of the "Select Date" button
                      onPrimary: Colors
                          .white, // Change the text color of the "Select Date" button
                    ),
                    child: Text('Select Date'),
                  ),
                ],
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newService = Service(
                      name: serviceName!,
                      time: selectedTime,
                      Date: selectedDate,
                      price: selectedPrice ?? 0.0,
                      age: selectedAge ?? 0,
                      description: selectedDescription ?? '',
                      capacity: selectedCapacity ?? 0,
                    );
                    Navigator.pop(context, newService);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors
                      .green, // Change the background color of the "Done" button
                  onPrimary: Colors
                      .white, // Change the text color of the "Done" button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20.0), // Adjust the radius to change the roundness
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
}
