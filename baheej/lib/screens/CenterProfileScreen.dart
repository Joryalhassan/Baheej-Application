import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CenterProfileViewScreen extends StatefulWidget {
  @override
  _CenterProfileViewScreenState createState() =>
      _CenterProfileViewScreenState();
}

class _CenterProfileViewScreenState extends State<CenterProfileViewScreen> {
  CenterProfile? _centerProfile;

  @override
  void initState() {
    super.initState();
    fetchCenterData().then((centerData) {
      setState(() {
        _centerProfile = centerData;
      });
    });
  }

  Future<CenterProfile> fetchCenterData() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('center')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs[0];
        final data = doc.data() as Map<String, dynamic>;

        return CenterProfile(
          username: data['username'] ?? '',
          address: data['addres'] ?? '',
          email: data['email'] ?? '',
          comReg: data['comReg'] ?? '',
          type: data['type'] ?? '',
          phoneNumber: data['phonenumber'] ?? '',
          description: data['Desc'] ?? '',
        );
      }
    }

    // Handle the case where the center's data doesn't exist or the user is not authenticated.
    return CenterProfile(
      username: '',
      address: '',
      email: '',
      comReg: '',
      type: '',
      phoneNumber: '',
      description: '',
    );
  }

  void _editProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return CProfileEditScreen(_centerProfile);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Center Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: Center(
        child: _centerProfile != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Username: ${_centerProfile?.username}'),
                  Text('Address: ${_centerProfile?.address}'),
                  Text('Email: ${_centerProfile?.email}'),
                  Text('ComReg: ${_centerProfile?.comReg}'),
                  Text('Phone Number: ${_centerProfile?.phoneNumber}'),
                  Text('Description: ${_centerProfile?.description}'),
                ],
              )
            : CircularProgressIndicator(), // You can use a loading indicator while data is being fetched.
      ),
    );
  }
}

class CProfileEditScreen extends StatefulWidget {
  final CenterProfile? initialProfile;

  CProfileEditScreen(this.initialProfile);

  @override
  _CProfileEditScreenState createState() => _CProfileEditScreenState();
}

class _CProfileEditScreenState extends State<CProfileEditScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _addressController;
  late TextEditingController _comRegController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _descriptionController;

  // Add variables to track changes in each field
  bool _hasEdits = false;

  // Define error variables for each field
  String? _nameError;
  String? _addressError;
  String? _comRegError;
  String? _phoneNumberError;
  String? _descriptionError;

  @override
  void initState() {
    super.initState();

    _usernameController =
        TextEditingController(text: widget.initialProfile?.username);
    _addressController =
        TextEditingController(text: widget.initialProfile?.address);
    _comRegController =
        TextEditingController(text: widget.initialProfile?.comReg);
    _phoneNumberController =
        TextEditingController(text: widget.initialProfile?.phoneNumber);
    _descriptionController =
        TextEditingController(text: widget.initialProfile?.description);

    // Add listeners to text controllers to track changes
    _usernameController.addListener(_handleEdits);
    _addressController.addListener(_handleEdits);
    _comRegController.addListener(_handleEdits);
    _phoneNumberController.addListener(_handleEdits);
    _descriptionController.addListener(_handleEdits);
  }

  void _handleEdits() {
    // Set _hasEdits to true if any text field has changed
    setState(() {
      _hasEdits = true;
    });

    // Validate the input and update the error variables
    _nameError = _validateName(_usernameController.text);
    _addressError = _validateAddress(_addressController.text);
    _comRegError = _validateCommercialRegister(_comRegController.text);
    _phoneNumberError = _validatePhoneNumber(_phoneNumberController.text);
    _descriptionError = _validateDescription(_descriptionController.text);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _addressController.dispose();
    _comRegController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_hasEdits) {
      // Check for validation errors
      if (_nameError != null ||
          _addressError != null ||
          _comRegError != null ||
          _phoneNumberError != null ||
          _descriptionError != null) {
        // Display error messages for each field
        setState(() {});
        return;
      }

      // Save changes to Firestore
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        FirebaseFirestore.instance
            .collection('center')
            .doc(currentUser.uid)
            .update({
          'username': _usernameController.text.trim(),
          'addres': _addressController.text.trim(),
          'comReg': _comRegController.text.trim(),
          'phonenumber': _phoneNumberController.text.trim(),
          'Desc': _descriptionController.text.trim(),
        });

        // Pop the edit screen and return to the profile view
        Navigator.of(context).pop();
      }
    } else {
      // No edits were made, so simply return to the profile view
      Navigator.of(context).pop();
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Center Name is required';
    }
    if (value.length < 4 || value.length > 25) {
      return 'Center Name must be between 4 and 25 characters';
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return 'Center Name can only contain letters and spaces';
    }
    if (value.trimLeft() != value) {
      return 'Center Name cannot start with a space';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Invalid Email format';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone Number is required';
    }
    if (value.length != 10) {
      return 'Phone Number must be exactly 10 digits';
    }
    final phoneRegex = RegExp(r'^05[0-9]{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Invalid Phone Number';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  String? _validateCommercialRegister(String? value) {
    if (value == null || value.isEmpty) {
      return 'Commercial Register Number is required';
    } else if (value.length != 10) {
      return 'Commercial Register Number must be\nexactly 10 digits';
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Invalid Commercial Register Number';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    // Check if there is at least one alphabetic character in the description
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Description must contain at least one alphabetic\n character';
    }

    // Check if the description contains only letters, numbers, spaces, and special characters
    if (!RegExp(r'^[a-zA-Z0-9\s!@#\$%^&*()_+{}\[\]:;<>,.?~\\/-]+$')
        .hasMatch(value)) {
      return 'Description should contain only letters, numbers,\n spaces, or special characters';
    }

    if (value.length < 10 || value.length > 225) {
      return 'Description must be between 10 and 225 characters';
    }

    return null;
  }

  void _cancel() {
    if (_hasEdits) {
      // Show a confirmation dialog before discarding changes
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Discard Changes?'),
            content: Text('Are you sure you want to discard changes?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Discard changes and return to the profile view
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Discard'),
              ),
            ],
          );
        },
      );
    } else {
      // No edits were made, so simply return to the profile view
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: _nameError, // Display error message
              ),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                errorText: _addressError, // Display error message
              ),
            ),
            TextField(
              controller: _comRegController,
              decoration: InputDecoration(
                labelText: 'ComReg',
                errorText: _comRegError, // Display error message
              ),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                errorText: _phoneNumberError, // Display error message
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                errorText: _descriptionError, // Display error message
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _cancel,
                  child: Text('Cancel'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _hasEdits
                      ? _saveChanges
                      : null, // Enable only if there are edits
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CenterProfile {
  final String username;
  final String address;
  final String email;
  final String comReg;
  final String type;
  final String phoneNumber;
  final String description;

  CenterProfile({
    required this.username,
    required this.address,
    required this.email,
    required this.comReg,
    required this.type,
    required this.phoneNumber,
    required this.description,
  });
}