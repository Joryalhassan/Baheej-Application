import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/Addkids.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/HomeScreenCenter.dart';

class CenterProfileViewScreen extends StatefulWidget {
  const CenterProfileViewScreen({Key? key}) : super(key: key);

  @override
  _CenterProfileViewScreenState createState() =>
      _CenterProfileViewScreenState();
}

class _CenterProfileViewScreenState extends State<CenterProfileViewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Initialize controllers directly instead of using 'late'
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _ComRegTextController = TextEditingController();
  TextEditingController _PhoneNumTextController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _DescriptionTextController = TextEditingController();

  String? _selectedDistrict;
  bool _isLoading = true; // New field to track loading state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    var userData = await FirebaseFirestore.instance
        .collection('center')
        .doc(user!.uid)
        .get();

    // Check if the userData exists before setting the state
    if (userData.data() != null) {
      setState(() {
        _userNameTextController.text = userData.data()!['username'] ?? '';
        _ComRegTextController.text = userData.data()!['comReg'] ?? '';
        _PhoneNumTextController.text = userData.data()!['phonenumber'] ?? '';
        _DescriptionTextController.text = userData.data()!['Desc'] ?? '';
        _emailController.text = user.email ?? ''; // Set email in the controller
        _selectedDistrict = userData.data()!['addres'];
        _isLoading = false; // Update loading state
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Update data in Firestore
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('center')
          .doc(user!.uid)
          .update({
        'username': _userNameTextController.text,
        'comReg': _ComRegTextController.text,
        'phonenumber': _PhoneNumTextController.text,
        'addres': _selectedDistrict,
        'Desc': _DescriptionTextController.text,
        // ... Add other fields
      });
      // Show success popup
      await _showSuccessDialog();

      setState(() {
        _isEditing = false; // Turn off editing mode
      });
    }
  }

  Future<void> _deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('center')
          .doc(user!.uid)
          .delete();

      // Delete user from FirebaseAuth
      await user.delete();

      // Navigate to the login or welcome screen after deletion
      // Replace with your app's navigation logic
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      // Handle errors, e.g., show an error message
      print("Error deleting account: $e");
    }
  }

  Future<void> _confirmDeleteAccount() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete your account?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteAccount();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmSaveChanges() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Changes'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to save these changes?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _updateProfile(); // Call the update profile method
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Profile Updated Successfully'),
              ],
            ),
          ),
          actions: <Widget>[
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

  void _handleAddKids() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddKidsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      appBar: AppBar(
        title: Text('Center Profile'), // Title for the AppBar
        backgroundColor: Colors.transparent, // Transparent AppBar background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Navigate back
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout, // Call the logout function
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image or content
          Image.asset(
            'assets/images/backG.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Your SingleChildScrollView content
          SingleChildScrollView(
            padding: EdgeInsets.only(
                top: kToolbarHeight +
                    20), // Adjust the padding to account for the AppBar
            child: _isLoading
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : (_isEditing
                    ? _buildEditableView()
                    : _buildEditableView()), // Show actual content
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
                  'Booking Program',
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreenCenter(
                            centerName: _userNameTextController.text),
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
          Navigator.pushReplacement(
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

  Widget _buildEditableView() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 70,
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                //   labelText: "Enter Email Id",
                prefixIcon: Icon(Icons.email),
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
              enabled: false, // This makes the TextFormField non-editable
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Center Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _userNameTextController,
              maxLength: 25, // Limit the input to 25 characters
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
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
              enabled: false,
              onChanged: (text) {
                // Remove spaces from the input
                final newText = text.replaceAll(RegExp(r'\s+'), '');
                if (newText != text) {
                  _userNameTextController.value =
                      _userNameTextController.value.copyWith(
                    text: newText,
                    selection: TextSelection(
                        baseOffset: newText.length,
                        extentOffset: newText.length),
                    composing: TextRange.empty,
                  );
                }
              },
              validator: (value) {
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
              },
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Commercial Register Number",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _ComRegTextController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.format_list_numbered),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Commercial Register Number is required';
                } else if (value.length != 10) {
                  return 'Commercial Register Number must be\nexactly 10 digits';
                } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Invalid Commercial Register Number';
                }
                return null;
              },
              maxLength: 10, // Maximum length set to 10
              keyboardType: TextInputType.number, // Allow numeric keyboard
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ], // Allow only numeric input
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Phone Number",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _PhoneNumTextController,
              maxLength: 10, // Limit the input to exactly 10 digits
              keyboardType: TextInputType.phone, // Show numeric keyboard
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
              decoration: InputDecoration(
                // labelText: "Enter Phone Number",
                prefixIcon: Icon(Icons.phone),
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
              validator: (value) {
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
              },
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "District",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedDistrict ?? '',
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDistrict = newValue;
                });
              },
              items: <String>[
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
              ] // rest of your items
                  .map<DropdownMenuItem<String>>((String? value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value ??
                      'Select District'), // Display 'Select District' for null value
                );
              }).toList(),
              decoration: InputDecoration(
                // labelText: "Select Gender",
                prefixIcon: Icon(Icons.person),
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
              validator: (value) {
                if (value == null || value.isEmpty || value == '') {
                  return 'Please select a valid district';
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _DescriptionTextController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.description),
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
              validator: (value) {
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
              },
              maxLength: 225,
            ),
            SizedBox(height: 20), // Spacing before the buttons
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly, // Adjusts spacing between buttons
              children: <Widget>[
                ElevatedButton(
                  onPressed: _confirmSaveChanges,
                  style: ElevatedButton.styleFrom(
                    primary:
                        Color.fromARGB(255, 59, 138, 207), // Your desired color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirmDeleteAccount,
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 242, 12,
                        12), // Same color as the "Save Changes" button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Delete Account",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
