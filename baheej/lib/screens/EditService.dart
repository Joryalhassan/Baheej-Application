import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
class EditService extends StatefulWidget {
  final Service service;
  final Function(Service) onUpdateService;

  EditService({required this.service, required this.onUpdateService});

  @override
  _EditServiceState createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _serviceNameController = TextEditingController();
  TextEditingController _serviceDescriptionController = TextEditingController();
  TextEditingController _capacityValueController = TextEditingController();
  TextEditingController _servicePriceController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  int _minAge = 4;
  int _maxAge = 17;
 String _selectedTimeSlot = ''; // Store the selected time slot
  bool _isEditingTimeSlot = false;



  @override
  void initState() {
    super.initState();
    _serviceNameController.text = widget.service.serviceName;
    _serviceDescriptionController.text = widget.service.description;
    _capacityValueController.text = widget.service.capacityValue.toString();
    _servicePriceController.text = widget.service.servicePrice.toString();
    _selectedStartDate = widget.service.selectedStartDate;
    _selectedEndDate = widget.service.selectedEndDate;
    _minAge = widget.service.minAge;
    _maxAge = widget.service.maxAge;
   _selectedTimeSlot = widget.service.selectedTimeSlot;
  }
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are You Sure?'),
          content: Text('Do you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseAuth.instance.signOut();
                  showLogoutSuccessDialog();
                } catch (e) {
                  print("Error signing out: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }
  void showLogoutSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Successful'),
          content: Text('You have successfully logged out.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                navigateToSignInScreen();
              },
            ),
          ],
        );
      },
    );
  }
void navigateToSignInScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    title: null,
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: Icon(Icons.logout),
        onPressed: () {
          _handleLogout();
        },
      ),
    ],
  ),
  body: Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/backG.png',
          fit: BoxFit.cover,
        ),
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
                   // IconButton(
                     // icon: Icon(
                       // Icons.arrow_back_ios,
                       // color: Colors.white,
                     // ),
                    //  onPressed: () {
                     //   Navigator.of(context).pop();
                    //  },
                   // ),
                    Padding(
                      padding: EdgeInsets.only(right: 130.0),
                      child: Text(
                        'Edit Service',
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
            _buildEditableField(
              label: 'Service Name',
              controller: _serviceNameController,
              validator: validateServiceName,
            ),
            _buildEditableField(
              label: 'Service Description',
              controller: _serviceDescriptionController,
              validator: validateServiceDescription, // Add validator
            ),
            _buildCapacityValueField(
              label: 'Capacity Value',
              validator: validateCapacityValue, // Add validator
            ),
            _buildEditableField(
              label: 'Service Price',
              controller: _servicePriceController,
              validator: validateServicePrice, // Add validator
            ),
            _buildDateTimePicker(
              label: 'Start Date',
              selectedDate: _selectedStartDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedStartDate = date;
                });
              },
              validator: (value) =>
                          validateDate(_selectedStartDate, _selectedEndDate), // Add validator
            ),
            _buildDateTimePicker(
              label: 'End Date',
              selectedDate: _selectedEndDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedEndDate = date;
                });
              },
              validator: (value) =>
                          validateDate(_selectedStartDate, _selectedEndDate), // Add validator
            ),
            _buildAgeSelector(
              label: 'Min Age',
              value: _minAge,
              onIncrement: () {
                setState(() {
                  _minAge++;
                });
              },
              onDecrement: () {
                setState(() {
                  if (_minAge > 0) {
                    _minAge--;
                  }
                });
              },
              validator: (value) => validateMinAge(_minAge, _maxAge), // Add validator
            ),
            _buildAgeSelector(
              label: 'Max Age',
              value: _maxAge,
              onIncrement: () {
                setState(() {
                  _maxAge++;
                });
              },
              onDecrement: () {
                setState(() {
                  if (_maxAge > 0) {
                    _maxAge--;
                  }
                });
              },
              validator: (value) => validateMinAge(_minAge, _maxAge), // Add validator
            ),
             _buildTimeSlotField(
              validator: validateTimeSlot, // Add validator
             ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    _saveChangesToFirestore();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 59, 138, 207),
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    minimumSize: Size(100, 40),
                  ),
                  child: Text('Save'), // Button text
                ),
              ),
            ),
          ],
                ),
                ),
                ),
        ),
      ],
      ),
      bottomNavigationBar: BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: Color.fromARGB(255, 245, 198, 239),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 24),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.history),
                color: Colors.white,
                onPressed: () {
                  // Handle booking history button tap
                },
              ),
              Text(
                'Booking Service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  'Add Service',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 25),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.person),
                color: Colors.white,
                onPressed: () {
                  // Handle profile button tap
                },
              ),
              Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(width: 32),
        ],
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    floatingActionButton: FloatingActionButton(
      backgroundColor: Color.fromARGB(255, 174, 207, 250),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceFormScreen(),
          ),
        );
      },
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    ),
  );
    
  }
  String? validateServiceName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Service name cannot be empty';
  }
  if (value.trim().isEmpty) {
    return 'Service name cannot consist of only spaces';
  }
  if (value.length < 5 || value.length > 20) {
    return 'Service name should be between 5 and 20 characters';
  }
  if (!RegExp(r'^[a-zA-Z0-9\s]*$').hasMatch(value)) {
    return 'Service name should only contain letters, numbers, and spaces';
  }
  return null;
}

String? validateServiceDescription(String? value) {
  if (value == null || value.isEmpty) {
    return 'Service description cannot be empty';
  }
  if (value.trim().isEmpty) {
    return 'Service description cannot consist of only spaces';
  }
  if (value.length < 5 || value.length > 225) {
    return 'Service description should be between 5 and 225 characters';
  }
  if (!value.contains(RegExp(r'[a-zA-Z]'))) {
    return 'Service description should contain at least one non-numeric character';
  }
  return null;
}

String? validateCapacityValue(String? value) {
  if (value == null || value.isEmpty) {
    return 'Capacity value cannot be empty';
  }
  int? intValue = int.tryParse(value);
  if (intValue == null || intValue < 10) {
    return 'Capacity should be a positive number and more than or equal 10';
  }
  if (intValue > 1000) {
    return 'Capacity cannot exceed 1000';
  }
  return null;
}

String? validateServicePrice(String? value) {
  if (value == null || value.isEmpty) {
    return 'Service price cannot be empty';
  }
  double? doubleValue = double.tryParse(value);
  if (doubleValue == null) {
    return 'Only numbers are allowed for price';
  }
  if (doubleValue > 10000) {
    return 'Maximum price limit exceeded (10000)';
  }
  if (doubleValue < 0) {
    return 'Negative prices are not allowed';
  }
  return null;
}

String? validateDate(DateTime? startDate, DateTime? endDate) {
  if (startDate == null) {
    return 'Start date cannot be null';
  }
  if (endDate == null) {
    return 'End date cannot be null';
  }
  if (endDate.isBefore(startDate)) {
    return 'End date cannot be before the start date';
  }
  return null;
}

String? validateMinAge(int? minAge, int? maxAge) {
  if (minAge == null) {
    return 'Minimum age cannot be null';
  }
  if (maxAge == null) {
    return 'Maximum age cannot be null';
  }
  if (minAge > maxAge) {
    return 'Minimum age cannot be greater than maximum age';
  }
  return null;
}

String? validateTimeSlot(String? value) {
  if (value == null || value.isEmpty) {
    return 'Time slot cannot be null';
  }
  return null;
}


 Widget _buildEditableField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator, // Add "?" here
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          decoration: InputDecoration(labelText: label),
          controller: controller,
          validator: validator, // Keep the "?" here
        ),
        // Display error message if validation fails
        if (validator != null)
          Text(
            validator(controller.text) ?? '', // Show the error message from the validator
            style: TextStyle(color: Colors.red),
          ),
      ],
    ),
  );
}





  Widget _buildCapacityValueField({
  required String label,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            Expanded(
              child: Text(label),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  int value = int.tryParse(_capacityValueController.text) ?? 0;
                  value = (value > 0) ? value - 1 : 0;
                  _capacityValueController.text = value.toString();
                });
              },
              icon: Icon(Icons.remove),
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Capacity Value',
                  border: OutlineInputBorder(),
                ),
                controller: _capacityValueController,
                validator: validator,
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  int value = int.tryParse(_capacityValueController.text) ?? 0;
                  value++;
                  _capacityValueController.text = value.toString();
                });
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        if (validator != null)
          Text(
            validator(_capacityValueController.text) ?? '',
            style: TextStyle(color: Colors.red),
          ),
      ],
    ),
  );
}


  Widget _buildDateTimePicker({
  required String label,
  required DateTime? selectedDate,
  required Function(DateTime?) onDateChanged,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      ListTile(
        title: Text(label),
        trailing: GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != selectedDate) {
              onDateChanged(picked);
            }
          },
          child: Text(
            selectedDate != null
                ? "${selectedDate.toLocal()}".split(' ')[0]
                : 'Select Date',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      if (validator != null)
        Text(
          validator(selectedDate?.toIso8601String() ?? '') ?? '',
          style: TextStyle(color: Colors.red),
        ),
    ],
  );
}

  Widget _buildAgeSelector({
  required String label,
  required int value,
  required Function() onIncrement,
  required Function() onDecrement,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            Expanded(
              child: Text(label),
            ),
            IconButton(
              onPressed: onDecrement,
              icon: Icon(Icons.remove),
            ),
            Text(value.toString()),
            IconButton(
              onPressed: onIncrement,
              icon: Icon(Icons.add),
            ),
          ],
        ),
        if (validator != null)
          Text(
            validator(value.toString()) ?? '',
            style: TextStyle(color: Colors.red),
          ),
      ],
    ),
  );
}

  Widget _buildTimeSlotField({
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Period Time'),
        Row(
          children: [
            Text(_selectedTimeSlot), // Display selected time slot
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditingTimeSlot = true;
                });
              },
              child: Text('Edit'),
            ),
          ],
        ),
        if (validator != null)
          Text(
            validator(_selectedTimeSlot) ?? '',
            style: TextStyle(color: Colors.red),
          ),
        if (_isEditingTimeSlot)
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTimeSlot = '8-11 AM';
                  });
                },
                child: Text('8-11 AM'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTimeSlot = '2-5 PM';
                  });
                },
                child: Text('2-5 PM'),
              ),
            ],
          ),
      ],
    ),
  );
}



  void _saveChangesToFirestore() {
    if (_formKey.currentState!.validate()) {
    // Get updated values from controllers and selected dates
    final String updatedServiceName = _serviceNameController.text;
    final String updatedServiceDescription = _serviceDescriptionController.text;
    final int updatedCapacityValue =
        int.tryParse(_capacityValueController.text) ?? 0;
    final double updatedServicePrice =
        double.tryParse(_servicePriceController.text) ?? 0.0;
    final String updatedStartDate =
        _selectedStartDate != null ? _selectedStartDate!.toIso8601String() : '';
    final String updatedEndDate =
        _selectedEndDate != null ? _selectedEndDate!.toIso8601String() : '';
        

    // Create an updated Service object with the new values
    final updatedService = Service(
      id: widget.service.id, // Use the same ID as the original service
      serviceName: updatedServiceName,
      description: updatedServiceDescription,
      centerName: widget.service.centerName, // Keep the same centerName
      selectedStartDate: _selectedStartDate ?? DateTime.now(),
      selectedEndDate: _selectedEndDate ?? DateTime.now(),
      minAge: _minAge,
      maxAge: _maxAge,
      capacityValue: updatedCapacityValue,
      servicePrice: updatedServicePrice,
      selectedTimeSlot: _selectedTimeSlot, // Add this line to include selectedTimeSlot  
    );

    // Update the service in Firestore using the provided Service object's ID
    FirebaseFirestore.instance
        .collection('center-service')
        .doc(widget.service.id)
        .update({
      'serviceName': updatedServiceName,
      'description': updatedServiceDescription,
      'centerName': widget.service.centerName,
      'serviceCapacity': updatedCapacityValue,
      'servicePrice': updatedServicePrice,
      'selectedStartDate': updatedStartDate,
      'selectedEndDate': updatedEndDate,
      'minAge': _minAge,
      'maxAge': _maxAge,
      'selectedTimeSlot': _selectedTimeSlot, // Update the selected time slot
    }).then((_) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Service updated successfully!'),
      ));
      Navigator.of(context).pop(); // Close the edit screen

      // Invoke the callback to update the service in HomeScreenCenter
      widget.onUpdateService(updatedService);
    });}
    else {
    // The form is not valid; show a snackbar message.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Please correct the form errors.'),
    ));}
  }
}