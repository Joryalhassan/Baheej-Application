import 'package:baheej/screens/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GProfileViewScreen extends StatefulWidget {
  @override
  _GProfileViewScreenState createState() => _GProfileViewScreenState();
}
class _GProfileViewScreenState extends State<GProfileViewScreen> {
  GuardianProfile? _guardianProfile;

  @override
  void initState() {
    super.initState();
    fetchGuardianData().then((guardianData) {
      setState(() {
        _guardianProfile = guardianData;
      });
    });
  }

  Future<GuardianProfile> fetchGuardianData() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs[0];
        final data = doc.data() as Map<String, dynamic>;

        return GuardianProfile(
          firstName: data['fname'] ?? '',
          lastName: data['lname'] ?? '',
          email: data['email'] ?? '',
          phoneNumber: data['phonenumber'] ?? '',
          selectedGender: data['selectedGender'] ?? '',
        );
      }
    }

    return GuardianProfile(
      firstName: '',
      lastName: '',
      email: '',
      phoneNumber: '',
      selectedGender: '',
    );
  }

  void _editProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return GProfileEditScreen(_guardianProfile);
      }),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account?'),
          content: Text('Are you sure you want to delete your account? This action is irreversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call a function to delete the user and their data
                _deleteUserAndNavigateToSignIn();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to delete the user and navigate to SignInScreen
  void _deleteUserAndNavigateToSignIn() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // Delete user data from Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).delete();

        // Delete the user's account
        await currentUser.delete();

        // Navigate to SignInScreen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
          return SignInScreen();
        }));
      } catch (e) {
        // Handle errors, e.g., user not found or deletion failed
        print('Error while deleting user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileData('First Name', _guardianProfile?.firstName),
            _buildProfileData('Last Name', _guardianProfile?.lastName),
            _buildProfileData('Email', _guardianProfile?.email),
            _buildProfileData('Phone Number', _guardianProfile?.phoneNumber),
            _buildProfileData('Gender', _guardianProfile?.selectedGender),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            onPressed: _editProfile,
            label: Text('Edit Profile'),
            icon: Icon(Icons.edit),
          ),
          SizedBox(width: 16), // Add spacing between buttons
          FloatingActionButton.extended(
            onPressed: _deleteAccount,
            label: Text('Delete Account'),
            icon: Icon(Icons.delete),
            backgroundColor: Theme.of(context).primaryColor, // Use the primary color
          ),
        ],
      ),
    );
  }

  Widget _buildProfileData(String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Add spacing between items
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            value ?? '', // Use an empty string if the value is null
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}


class GuardianProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String selectedGender;

  GuardianProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.selectedGender,
  });
}





















class GProfileEditScreen extends StatefulWidget {
  final GuardianProfile? initialProfile;

  GProfileEditScreen(this.initialProfile);

  @override
  _GProfileEditScreenState createState() => _GProfileEditScreenState();
}

class _GProfileEditScreenState extends State<GProfileEditScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _selectedGenderController;

  // Add variables to track changes in each field
  bool _hasEdits = false;

  // Define error variables for each field
  String? _firstNameError;
  String? _lastNameError;
  String? _phoneNumberError;
  String? _selectedGenderError;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(text: widget.initialProfile?.firstName);
    _lastNameController = TextEditingController(text: widget.initialProfile?.lastName);
    _phoneNumberController = TextEditingController(text: widget.initialProfile?.phoneNumber);
    _selectedGenderController = TextEditingController(text: widget.initialProfile?.selectedGender);

    // Add listeners to text controllers to track changes
    _firstNameController.addListener(_handleEdits);
    _lastNameController.addListener(_handleEdits);
    _phoneNumberController.addListener(_handleEdits);
    _selectedGenderController.addListener(_handleEdits);
  }

  void _handleEdits() {
    // Set _hasEdits to true if any text field has changed
    setState(() {
      _hasEdits = true;
    });

    // Validate the input and update the error variables
    _firstNameError = _validateFirstName(_firstNameController.text);
    _lastNameError = _validateLastName(_lastNameController.text);
    _phoneNumberError = _validatePhoneNumber(_phoneNumberController.text);
    _selectedGenderError = _validateSelectedGender(_selectedGenderController.text);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _selectedGenderController.dispose();
    super.dispose();
  }

 void _saveChanges() {
  if (_hasEdits) {
    // Check for validation errors
    if (_firstNameError != null ||
        _lastNameError != null ||
        _phoneNumberError != null ||
        _selectedGenderError != null) {
      // Display error messages for each field
      setState(() {});
      return;
    }

    // Show a confirmation dialog before saving changes
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Changes?'),
          content: Text('Are you sure you want to save changes?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save changes to Firestore
                final currentUser = FirebaseAuth.instance.currentUser;

                if (currentUser != null) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .update({
                    'fname': _firstNameController.text.trim(),
                    'lname': _lastNameController.text.trim(),
                    'phonenumber': _phoneNumberController.text.trim(),
                    'selectedGender': _selectedGenderController.text.trim(),
                  });

                  // Pop the edit screen and return to the profile view
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the edit screen
                }
              },
              child: Text('Save'),
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


  String? _validateFirstName(String? value) {
         if (value == null || value.isEmpty) {
           return 'First Name is required';
          }
         if (value.length < 2 || value.length > 12) {
            return 'First Name must be between 2 and 12 letters';
          }
          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
             return 'First Name can only contain letters';
         }
       return null;
      }

  String? _validateLastName(String? value) {
        if (value == null || value.isEmpty) {
            return 'Last Name is required';
           }
         if (value.length < 2 || value.length > 12) {
           return 'Last Name must be between 2 and 12 letters';
         }
          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
         return 'Last Name can only contain letters';
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


  String? _validateSelectedGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selected Gender is required';
    }
    // Add your validation rules for selected gender here.
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
        automaticallyImplyLeading: false  //////////////////////////////////////added this to remove back navigation
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _firstNameController,
              maxLength: 12, ///////////////////////////// Limit the input to 12 characters
              decoration: InputDecoration(
                labelText: 'First Name',
                errorText: _firstNameError, // Display error message
              ),
            ),
            TextField(
              controller: _lastNameController,
                maxLength: 12, // ///////////////////////Limit the input to 12 characters
              decoration: InputDecoration(
                labelText: 'Last Name',
                errorText: _lastNameError, // Display error message
              ),
            ),
            TextField(
              controller: _phoneNumberController,
              maxLength: 10, //////////////////////////// Limit the input to exactly 10 digits
              decoration: InputDecoration(
                labelText: 'Phone Number',
                errorText: _phoneNumberError, // Display error message
              ),
            ),
          
          
            DropdownButtonFormField<String>(
            value: _selectedGenderController.text,
            items: ["Male", "Female"]
               .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ))
            .toList(),
           onChanged: (value) {
           setState(() {
            _selectedGenderController.text = value ?? "";
           });
           },
         decoration: InputDecoration(
         labelText: 'Selected Gender',
          errorText: _selectedGenderError, // Display error message
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