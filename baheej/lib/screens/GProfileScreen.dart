import 'package:baheej/screens/HomeScreenGaurdian.dart';
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
 
 @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return HomeScreenGaurdian();
        }),
      );
      return false; // Return false to prevent default back behavior
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text('Guardian Profile'),
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
    // Background image or content
    Image.asset(
      'assets/images/back3.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ),
    SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20), // Add space between the header and body content
          _buildProfileData('First Name', _guardianProfile?.firstName),
          _buildProfileData('Last Name', _guardianProfile?.lastName),
          _buildProfileData('Email', _guardianProfile?.email),
          _buildProfileData('Phone Number', _guardianProfile?.phoneNumber),
          _buildProfileData('Gender', _guardianProfile?.selectedGender),
        ],
      ),
    ),
    Positioned(
      bottom: 200, // Adjust the position as needed
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            child: ElevatedButton(
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 59, 138, 207),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Edit Profile',
                  style: TextStyle(fontSize: 17, color: Colors.white)),
            ),
          ),
          SizedBox(width: 16),
          Container(
            width: 160,
            child: ElevatedButton(
              onPressed: _deleteAccount,
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 59, 138, 207),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Delete Account',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),


      // Add the bottom navigation bar and floating action button
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
                    //Navigator.push(
                    //context,
                    //  MaterialPageRoute(builder: (context) => HistoryScreen()),
                    // );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Booked Service ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(1, 50, 17, 1),
                  child: Text(
                    'View Kids',
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
                  icon: Icon(Icons.home),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreenGaurdian(),
                      ),
                    );
                  },
                ),
                Text(
                  'Home',
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
          // onPressed:
          // _handleAddKids();
        },
        child: Icon(
          Icons.add_reaction_outlined,
          color: Colors.white,
        ),
      ),
    ),
  );
}


  Widget _buildProfileData(String label, String? value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              value ?? '',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        Divider(),
      ],
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          title: Text('Delete Account'),
          content: Text(
              'Are you sure you want to delete your account? This action is irreversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 17,
                  color: Color.fromARGB(255, 59, 138, 207),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteUserAndNavigateToSignIn();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteUserAndNavigateToSignIn() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .delete();

        // Delete the user's account
        await currentUser.delete();

        // Navigate to SignInScreen
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return SignInScreen();
        }));
      } catch (e) {
        // Handle errors, e.g., user not found or deletion failed
        print('Error while deleting user: $e');
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(5.0), // Adjust the radius as needed
          ),
          title: Text('Are You Sure?'),
          content: Text('Do you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Color.fromARGB(255, 59, 138, 207)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Color.fromARGB(255, 59, 138, 207)),
              ),
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

    _firstNameController =
        TextEditingController(text: widget.initialProfile?.firstName);
    _lastNameController =
        TextEditingController(text: widget.initialProfile?.lastName);
    _phoneNumberController =
        TextEditingController(text: widget.initialProfile?.phoneNumber);
    _selectedGenderController =
        TextEditingController(text: widget.initialProfile?.selectedGender);

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
    _selectedGenderError =
        _validateSelectedGender(_selectedGenderController.text);
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
            backgroundColor: Colors.white, // Set background color to white
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(5.0), // Adjust the radius as needed
            ),
            title: Text('Confirm Changes'),
            content: Text('Are you sure you want to save changes?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 59, 138,
                        207), // Use the same color as the buttons below
                  ),
                ),
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
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return GProfileViewScreen();
                    }));
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 59, 138,
                        207), // Use the same color as the buttons below
                  ),
                ),
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
            backgroundColor: Colors.white, // Set background color to white
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(5.0), // Adjust the radius as needed
            ),
            title: Text('Discard Changes'),
            content: Text('Are you sure you want to discard changes?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 59, 138,
                        207), // Use the same color as the buttons below
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Discard changes and return to the profile view
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return GProfileViewScreen();
                  }));
                },
                child: Text(
                  'Discard',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 59, 138,
                        207), // Use the same color as the buttons below
                  ),
                ),
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
        automaticallyImplyLeading:
            false, // Add this line to remove the back button
      ),
      body: SingleChildScrollView(
    
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _firstNameController,
              maxLength: 12,
              decoration: InputDecoration(
                labelText: 'First Name',
                errorText: _firstNameError,
              ),
              style: TextStyle(fontSize: 18), // Adjust the font size as needed
            ),
            TextField(
              controller: _lastNameController,
              maxLength: 12,
              decoration: InputDecoration(
                labelText: 'Last Name',
                errorText: _lastNameError,
              ),
              style: TextStyle(fontSize: 18), // Adjust the font size as needed
            ),
            TextField(
              controller: _phoneNumberController,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                errorText: _phoneNumberError,
              ),
              style: TextStyle(fontSize: 18), // Adjust the font size as needed
            ),
            DropdownButtonFormField<String>(
              value: _selectedGenderController.text,
              items: ["Male", "Female"]
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: TextStyle(
                                fontSize:
                                    18)), // Adjust the font size as needed
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGenderController.text = value ?? "";
                });
              },
              decoration: InputDecoration(
                labelText: 'Selected Gender',
                errorText: _selectedGenderError,
              ),
              style: TextStyle(fontSize: 18), // Adjust the font size as needed
            ),
          ],
        ),
      ),
      
      
    );
  }
}