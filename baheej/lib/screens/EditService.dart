import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/screens/SignInScreen.dart';
class EditService extends StatefulWidget {
  final Service service;
  final Function(Service) onUpdateService;

  EditService({required this.service, required this.onUpdateService});

  @override
  _EditServiceState createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final _formKey = GlobalKey<FormState>(); // Define _formKey here
  TextEditingController _serviceNameController = TextEditingController();
  TextEditingController _serviceDescriptionController = TextEditingController();
  TextEditingController _capacityValueController = TextEditingController();
  TextEditingController _servicePriceController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  int _minAge = 4;
  int _maxAge = 17;

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
      
        appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _handleLogout();
            },
          ),
        ],
        title: Text('Edit Service'), // You can set the title here
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
            ),
            _buildEditableField(
              label: 'Service Description',
              controller: _serviceDescriptionController,
            ),
            _buildCapacityValueField(
              label: 'Capacity Value',
            ),
            _buildEditableField(
              label: 'Service Price',
              controller: _servicePriceController,
            ),
            _buildDateTimePicker(
              label: 'Start Date',
              selectedDate: _selectedStartDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedStartDate = date;
                });
              },
            ),
            _buildDateTimePicker(
              label: 'End Date',
              selectedDate: _selectedEndDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedEndDate = date;
                });
              },
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
            ),
            // Add the Save button at the bottom
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
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        controller: controller,
      ),
    );
  }

  Widget _buildCapacityValueField({
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateChanged,
  }) {
    return ListTile(
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
    );
  }

  Widget _buildAgeSelector({
    required String label,
    required int value,
    required Function() onIncrement,
    required Function() onDecrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
    );
  }

  void _saveChangesToFirestore() {
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
      selectedTimeSlot: widget.service.selectedTimeSlot, // Keep the same selectedTimeSlot
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
    }).then((_) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Service updated successfully!'),
      ));
      Navigator.of(context).pop(); // Close the edit screen

      // Invoke the callback to update the service in HomeScreenCenter
      widget.onUpdateService(updatedService);
    }).catchError((error) {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating service: $error'),
      ));
    });
  }
}