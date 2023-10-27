import 'package:baheej/screens/HistoryScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/EditServicepopUp.dart';

class HomeScreenCenter extends StatefulWidget {
  const HomeScreenCenter({Key? key}) : super(key: key);

  @override
  _HomeScreenCenterState createState() => _HomeScreenCenterState();
}

class _HomeScreenCenterState extends State<HomeScreenCenter> {
  String userName = ''; // Initialize userName
  late List<Service> _allServices;
  List<Service> _filteredServices = [];
  TextEditingController _searchController = TextEditingController();

  void initState() {
    super.initState();
          fetchUserName();// Call fetchName to fetch the user's first name
    fetchDataFromFirebase().then((services) {
      setState(() {
        _allServices = services;
        _filteredServices = services
          .where((service) => service.centerName == userName)
          .toList(); // Filter services by center name;
      });
    });
 
  }

  Future<List<Service>> fetchDataFromFirebase() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('center-service');
    final querySnapshot = await collection.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final serviceName = data['serviceName'] ?? 'Title';
      final description = data['serviceDesc'] ?? 'Description';
      final startDate = data['startDate'] != null
          ? DateTime.parse(data['startDate'])
          : DateTime.now();
      final endDate = data['endDate'] != null
          ? DateTime.parse(data['endDate'])
          : DateTime.now();
      final centerName = data['centerName'] ?? 'Center Name';
      final selectedTimeSlot = data['selectedTimeSlot'] ?? 'time slot';
      final capacityValue = data['capacityValue'] ?? 0;
      final servicePrice = data['servicePrice'] ?? 0.0;
      final minAge = data['minAge'] ?? 4;
      final maxAge = data['maxAge'] ?? 17;
      

      return Service(
        serviceName: serviceName,
        description: description,
        centerName: centerName,
        selectedTimeSlot: selectedTimeSlot,
        capacityValue: capacityValue,
        servicePrice: servicePrice,
        selectedStartDate: startDate,
        selectedEndDate: endDate,
        minAge: minAge,
        maxAge: maxAge,
        //documentId:doc.id,
      );
    }).toList();
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

  void _handleSearch(String query) {
    query = query.trim();
    setState(() {
      _filteredServices = _allServices
          .where((service) =>
              service.serviceName
                  .toLowerCase()
                  .startsWith(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

 //Future<void> deleteService(Service service) async {
 // try {
  //  final firestore = FirebaseFirestore.instance;
  //  final collection = firestore.collection('center-service');
  //  await collection.service.delete();
  //  print('Service deleted successfully.');
 // } catch (e) {
  //  print('Error deleting service: $e');
    // Handle any error or display an error message to the user
 // }
//}


  // @override
  // void initState() {
  //   super.initState();
  //   // Fetch the user's name from Firestore when the screen initializes
  //   fetchName();
  // }

   void fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('center')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final firstName =
            userData['username'] ?? ''; // Get the first name from Firestore
        setState(() {
          userName = firstName;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Welcome $userName'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
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
          Padding(
            padding: EdgeInsets.only(top: 160, left: 16, right: 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _handleSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  toolbarOptions: null, // Remove paste button
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 30),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return GestureDetector(
                        onTap: () {
                          // Handle tapping on a service
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            color: Color.fromARGB(255, 239, 249, 254),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.serviceName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'center name: ${service.centerName}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                   SizedBox(height: 8),
                                  Text(
                                    'Service Price: ${service.servicePrice}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                   
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Service Time: ${service.selectedTimeSlot}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                     Text(
                                        'Service Date: ${service.selectedStartDate}-${service.selectedEndDate}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                   SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Service Min age: ${service. minAge}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                     Text(
                                        'Service Max age: ${service. maxAge}',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                   SizedBox(height: 8),
                                  Text(
                                    'Service Capacity: ${service.capacityValue}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                   InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditServicePopup(
                                                      service: service),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Edit Service',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this service?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                // Perform the deletion here
               // await deleteService(service); // You need to implement this function
                Navigator.of(context).pop(); // Close the dialog
                // After deletion, you may want to refresh the service list
                fetchDataFromFirebase().then((services) {
                  setState(() {
                    _allServices = services;
                    _filteredServices = services
                      .where((service) => service.centerName == userName)
                      .toList();
                  });
                });
              },
            ),
          ],
        );
      },
    );
  },
  child: Row(
    children: [
      Text(
        'Delete Service',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.red, // You can change the color as desired
        ),
      ),
      Icon(
        Icons.delete,
        size: 14,
        color: Colors.red, // You can change the color as desired
      ),
    ],
  ),
),

                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
                  icon: Icon(Icons.history), // Home Icon

                  color: Colors.white, // Set icon color to white

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5), // Add margin to the top

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
                  padding: EdgeInsets.fromLTRB(
                      1, 50, 17, 1), // Add margin to the top

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
                  icon: Icon(Icons.person), // Profile Icon

                  color: Colors.white, // Set icon color to white

                  onPressed: () {
                    // _handleAddKids();
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
                      MaterialPageRoute(builder: (context) => ServiceFormScreen()),
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