import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditService extends StatefulWidget {
  final String serviceId;

  EditService({required this.serviceId});

  @override
  _EditServiceState createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _serviceNameController = TextEditingController();
   TextEditingController _serviccPriceController = TextEditingController();
    TextEditingController _minAgeController = TextEditingController();
    TextEditingController _maxAgeController = TextEditingController();
    TextEditingController _serviceCapacityController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
   TextEditingController _StartdateController = TextEditingController();
    TextEditingController _EnddateController = TextEditingController();
     TextEditingController _TimeslotController = TextEditingController();
  // Add controllers for other fields as needed

  @override
  void initState() {
    super.initState();
    // Load the service data using the provided serviceId
    loadServiceData();
  }

  Future<void> loadServiceData() async {
    final doc = await FirebaseFirestore.instance
        .collection('center-service')
        .doc(widget.serviceId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _serviceNameController.text = data['serviceName'] ?? '';
         _serviccPriceController = data['servicePrice']??'';
         _minAgeController = data['minAge']??'';
         _maxAgeController = data['maxAge']??'';
         _serviceCapacityController = data['serviceCapacity']??'';
         _descriptionController.text = data['serviceDesc'] ?? '';
         _StartdateController = data['startDate'] ?? '';
         _EnddateController = data['endDate'] ?? '';
         _TimeslotController = data['selectedTimeSlot'] ?? '';

        // Initialize other controllers for the remaining fields
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Update the service data in Firestore
      final updatedData = {
        'serviceName': _serviceNameController.text,
        'servicePrice':_serviccPriceController.text,
        'minAge':_minAgeController.hashCode,
        'maxAge':_maxAgeController.hashCode,
        'serviceCapacity':_serviceCapacityController.hashCode,
        'serviceDesc': _descriptionController.text,
        'startDate':_StartdateController.hashCode,
        'endDate':_EnddateController.hashCode,
        'selectedTimeSlot':_TimeslotController.selection,

        // Add other fields here
      };

      FirebaseFirestore.instance
          .collection('center-service')
          .doc(widget.serviceId)
          .update(updatedData)
          .then((_) {
        Navigator.pop(context, updatedData); // Return updated data to the previous screen
      }).catchError((error) {
        print("Error updating service: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _serviceNameController,
                decoration: InputDecoration(labelText: 'Service Name'),
                validator: (value) {
                  if (_serviceNameController.text?.isEmpty ?? true) {
                         return 'Service Name is required';
                                 }

                  return null;
                },
              ),
              TextFormField(
                controller: _serviccPriceController,
                decoration: InputDecoration(labelText: 'Service price'),
                validator: (value) {
                  // Add validation as needed
                  return null;
                },
              ),
               TextFormField(
                controller: _minAgeController,
                decoration: InputDecoration(labelText: 'Min Age'),
                validator: (value) {
                  // Add validation as needed
                  return null;
                },
              ),
                TextFormField(
                controller: _maxAgeController,
                decoration: InputDecoration(labelText: 'Max Age'),
                validator: (value) {
                  // Add validation as needed
                  return null;
                },
              ),
                TextFormField(
                controller: _serviceCapacityController,
                decoration: InputDecoration(labelText: 'Service Capacity'),
                validator: (value) {
                  // Add validation as needed
                  return null;
                },
              ),
               TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  // Add validation as needed
                  return null;
                },
              ),
               TextFormField(
                controller: _StartdateController,
                decoration: InputDecoration(labelText: 'Start Date'),
                validator: (value) {
                  // Add validation as needed
                  return null;
                },
              ),
               TextFormField(
                controller: _EnddateController,
                decoration: InputDecoration(labelText: 'End Date'),
                validator: (value) {
                  // Add validation as needed
                  return null;
                },
              ),
               TextFormField(
                controller: _TimeslotController,
                decoration: InputDecoration(labelText: 'Service Period Time'),
                validator: (value) {
                  // Add validation as needed
                  return null;
                },
              ),
              // Add other form fields for the remaining service properties
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _serviccPriceController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _serviceCapacityController.dispose();
    _descriptionController.dispose();
    _StartdateController.dispose();
    _EnddateController.dispose();
    _TimeslotController.dispose();
    // Dispose other controllers as needed
    super.dispose();
  }
}

