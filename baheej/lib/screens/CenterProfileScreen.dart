import 'package:baheej/screens/HomeScreenCenter.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';

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
          addres: data['addres'] ?? '',
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
      addres: '',
      email: '',
      comReg: '',
      type: '',
      phoneNumber: '',
      description: '',
    );
  }

  //new in code for button ui
  ButtonStyle customButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      primary: Theme.of(context).primaryColor, // Use the primary color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Customize the button shape
      ),
    );
  }

  void _editProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return CProfileEditScreen(_centerProfile);
      }),
    );
  }

  //delete account code
  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(5.0), // Adjust the radius as needed
          ),
          title: Text('Delete Account?'),
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
                  color: Color.fromARGB(255, 59, 138,
                      207), // Use the same color as the buttons below
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Call a function to delete the user and their data
                _deleteUserAndNavigateToSignIn();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red, // Red color for the Delete button
                ),
              ),
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
            SizedBox(height: 150), // Add space between the header and body content
            _buildProfileData('Center Name', _centerProfile?.username),
            _buildProfileData('Email', _centerProfile?.email),
            _buildProfileData('Phone Number', _centerProfile?.phoneNumber),
            _buildProfileData('Commercial Register', _centerProfile?.comReg),
            _buildProfileData('District', _centerProfile?.addres),
            _buildProfileData('Description', _centerProfile?.description),
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
                style: customButtonStyle(context), // Use your custom button style
                child: Text('Edit Profile', style: TextStyle(fontSize: 17)),
              ),
            ),
            SizedBox(width: 16),
            Container(
              width: 160,
              child: ElevatedButton(
                onPressed: _deleteAccount,
                style: customButtonStyle(context), // Use your custom button style
                child: Text('Delete Account',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
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
              icon: Icon(Icons.home_filled),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreenCenter(centerName: _centerProfile?.username ?? ''),
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
            '$value',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
      Divider(), // Add a line below the field
    ],
  );
}



}

class CenterProfile {
  final String username;
  final String addres;
  final String email;
  final String comReg;
  final String type;
  final String phoneNumber;
  final String description;

  CenterProfile({
    required this.username,
    required this.addres,
    required this.email,
    required this.comReg,
    required this.type,
    required this.phoneNumber,
    required this.description,
  });
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
  String? _selectedAddress;
  // List of districts
  final List<String> riyadhDistricts = [
     'Ad Diriyah',
    'Al Batha',
    'Al Dhahraniyah',
    'Al Malaz',
    'Al Manar',
    'Al Maizilah',
    'Al Muruj',
    'Al Olaya',
    'Al Rawdah',
    'Al Sulimaniyah',
    'Al Wadi',
    'Al Wizarat',
    'Al Worood',
    'An Nakheel',
    'As Safarat',
    'Diplomatic Quarter',
    'King Abdullah Financial District',
    'King Fahd District',
    'King Faisal District',
    'King Salman District',
    'King Saud University',
    'Kingdom Centre',
    'Masjid an Nabawi',
    'Medinah District',
    'Murabba',
    'Nemar',
    'Olaya',
    'Qurtubah',
    'Sulaymaniyah',
    'Takhasusi',
    'Umm Al Hamam',
    'Yasmeen',
  ];

  @override
  void initState() {
    super.initState();

    _usernameController =
        TextEditingController(text: widget.initialProfile?.username);
    _addressController =
        TextEditingController(text: widget.initialProfile?.addres);
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

  // Show confirmation dialog before saving changes
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        title: Text('Confirm Changes'),
        content: Text('Are you sure you want to save these changes?'),
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
            onPressed: () async {
              // Save changes to Firestore
              final currentUser = FirebaseAuth.instance.currentUser;

              if (currentUser != null) {
                await FirebaseFirestore.instance
                    .collection('center')
                    .doc(currentUser.uid)
                    .update({
                  'username': _usernameController.text.trim(),
                  'addres': _selectedAddress,
                  'comReg': _comRegController.text.trim(),
                  'phonenumber': _phoneNumberController.text.trim(),
                  'Desc': _descriptionController.text.trim(),
                });

                // Pop the edit screen and return to the profile view
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return CenterProfileViewScreen();
                }));

                // Show a pop-up message
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      title: Text('Success'),
                      content: Text('Profile updated successfully!'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).primaryColor, // Always blue
              ),
            ),
          ),
        ],
      );
    },
  );
}




  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Center Name is required';
    }
    if (value.length < 4 || value.length > 25) {
      return 'Center Name must be between 4 and 25 letters';
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
      return 'District is required';
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return 'District can only contain letters and spaces';
    }
    if (value.trimLeft() != value) {
      return 'District cannot start with a space';
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
   //new in code for button ui
  ButtonStyle customButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      primary: Theme.of(context).primaryColor, // Use the primary color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Customize the button shape
      ),
    );
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
                    return CenterProfileViewScreen();
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

  //district drop down menu
  // List<String> centerAddresses = [
  //   'Ad Diriyah',
  //   'Al Batha',
  //   'Al Dhahraniyah',
  //   'Al Malaz',
  //   'Al Manar',
  //   'Al Maizilah',
  //   'Al Muruj',
  //   'Al Olaya',
  //   'Al Rawdah',
  //   'Al Sulimaniyah',
  //   'Al Wadi',
  //   'Al Wizarat',
  //   'Al Worood',
  //   'An Nakheel',
  //   'As Safarat',
  //   'Diplomatic Quarter',
  //   'King Abdullah Financial District',
  //   'King Fahd District',
  //   'King Faisal District',
  //   'King Salman District',
  //   'King Saud University',
  //   'Kingdom Centre',
  //   'Masjid an Nabawi',
  //   'Medinah District',
  //   'Murabba',
  //   'Nemar',
  //   'Olaya',
  //   'Qurtubah',
  //   'Sulaymaniyah',
  //   'Takhasusi',
  //   'Umm Al Hamam',
  //   'Yasmeen',
  // ];
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
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0), // Add space between the header and body content
            TextField(
              controller: _usernameController,
              maxLength: 25, // Set the maximum length
              decoration: InputDecoration(
                labelText: 'Center Name',
                errorText: _nameError,
              ),
            ),
            //2
            TextField(
              controller: _phoneNumberController,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                errorText: _phoneNumberError, // Display error message
              ),
            ),
            //3
            TextField(
              controller: _comRegController,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Commercial Register',
                errorText: _comRegError, // Display error message
              ),
            ),
            //4
            // District Dropdown ButtonFormField
            DropdownButtonFormField<String>(
              value: widget.initialProfile?.addres,
              decoration: InputDecoration(
                labelText: 'District',
                errorText: _addressError,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text('Select a District'),
                ),
                ...riyadhDistricts.map((district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAddress = newValue;
                });
              },
            ),
            //5
            TextField(
              controller: _descriptionController,
              maxLength: 225,
              decoration: InputDecoration(
                labelText: 'Description',
                errorText: _descriptionError, // Display error message
              ),
            ),
          Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      width: 160,
      child: ElevatedButton(
        onPressed: _cancel,
        style: customButtonStyle(context), // Use your custom button style
        child: Text('Cancel', style: TextStyle(fontSize: 17)),
      ),
    ),
    SizedBox(width: 16),
    Container(
  width: 160,
  child: ElevatedButton(
    onPressed: _saveChanges,
    style: ElevatedButton.styleFrom(
      primary: Theme.of(context).primaryColor, // Always blue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    child: Text(
      'Save Changes',
      style: TextStyle(fontSize: 17, color: Colors.white),
    ),
  ),
),

  ],
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
                   Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CenterProfileViewScreen(),
        ),
      );
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
}