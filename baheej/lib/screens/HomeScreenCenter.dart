import 'package:baheej/screens/EditService.dart';
import 'package:baheej/screens/compSerList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:baheej/screens/Service.dart';
//import 'package:baheej/screens/ServiceDetailsPage.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/CenterProfileScreen.dart';

class HomeScreenCenter extends StatefulWidget {
  final String centerName;

  HomeScreenCenter({required this.centerName});

  @override
  _HomeScreenCenterState createState() => _HomeScreenCenterState();
}

class _HomeScreenCenterState extends State<HomeScreenCenter> {
  List<Service> services = [];
  List<Service> filteredServices = [];
  TextEditingController _searchController = TextEditingController();
  String centerName = ''; // Declare centerName here

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      // Fetch user center data
      final centerDoc = await FirebaseFirestore.instance
          .collection('center')
          .doc(userId)
          .get();
      if (centerDoc.exists) {
        // Now you can use centerDoc.data() to access the data
        centerName = centerDoc.data()!['username'];
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('center-service')
          .where('centerName', isEqualTo: widget.centerName)
          .get();
      final currentDate = DateTime.now(); // Get the current date
      final List<Service> loadedServices = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime selectedStartDate;
            DateTime selectedEndDate;

            // Check if the 'startDate' and 'endDate' are stored as strings or timestamps
            if (data['startDate'] is String) {
              selectedStartDate = DateTime.parse(data['startDate'] as String);
            } else if (data['startDate'] is Timestamp) {
              selectedStartDate = (data['startDate'] as Timestamp).toDate();
            } else {
              selectedStartDate = DateTime.now();
            }

            if (data['endDate'] is String) {
              selectedEndDate = DateTime.parse(data['endDate'] as String);
            } else if (data['endDate'] is Timestamp) {
              selectedEndDate = (data['endDate'] as Timestamp).toDate();
            } else {
              selectedEndDate = DateTime.now();
            }

            // Check if the start date is today or earlier
            if (!selectedStartDate.isBefore(currentDate)) {
              return Service(
                id: doc.id,
                serviceName:
                    data['serviceName'] as String? ?? 'Service Name Missing',
                description:
                    data['serviceDesc'] as String? ?? 'Description Missing',
                centerName:
                    data['centerName'] as String? ?? 'Center Name Missing',
                selectedStartDate: selectedStartDate,
                selectedEndDate: selectedEndDate,
                minAge: data['minAge'] as int? ?? 0,
                maxAge: data['maxAge'] as int? ?? 0,
                capacityValue: data['serviceCapacity'] as int? ?? 0,
                servicePrice: data['servicePrice'] is double
                    ? data['servicePrice']
                    : (data['servicePrice'] is int
                        ? (data['servicePrice'] as int).toDouble()
                        : 0.0),
                selectedTimeSlot:
                    data['selectedTimeSlot'] as String? ?? 'Time Slot Missing',
              );
            } else {
              // Return null for services with start dates in the past or today
              return null;
            }
          })
          .where((service) => service != null) // Filter out null values
          .cast<Service>() // Cast the list to Service
          .toList();

      setState(() {
        services = loadedServices;
        filteredServices = loadedServices;
      });
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

  void updateService(Service updatedService) {
    final index =
        services.indexWhere((service) => service.id == updatedService.id);
    if (index != -1) {
      setState(() {
        services[index] = updatedService;
      });
    }
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
    final now = DateTime.now();
    setState(() {
      filteredServices = services
          .where((service) =>
              service.serviceName.toLowerCase().contains(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<bool?> showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Service'),
          content: Text('Are you sure you want to delete this service?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteService(Service service) async {
    // Show a confirmation dialog to confirm the deletion
    bool? confirmDelete =
        await showDeleteConfirmationDialog(); // Removed the default value

    if (confirmDelete == true) {
      try {
        // Get the reference to the document you want to delete
        final DocumentReference serviceRef = FirebaseFirestore.instance
            .collection('center-service')
            .doc(service.id);

        // Delete the document from Firestore
        await serviceRef.delete();

        // Remove the service from the UI
        removeServiceFromUI(service);
      } catch (e) {
        print('Error deleting service: $e');
        // Handle the error, e.g., show an error dialog
      }
    }
  }

  void removeServiceFromUI(Service service) {
    setState(() {
      filteredServices.remove(service);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Welcome ${widget.centerName}'),
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
                  toolbarOptions: null,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: filteredServices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "You don't have any services yet.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                SizedBox(height: 20), // Add some spacing
                              ],
                            ),
                          )
                        : Column(
                            children: filteredServices.map((service) {
                              return GestureDetector(
                                onTap: () {
                                  // Handle tapping on a service
                                },
                                child: Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  color: Color.fromARGB(255, 239, 249, 254),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Service Name: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              service.serviceName,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Start Date: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('MM/dd/yyyy').format(
                                                  service.selectedStartDate),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'End Date: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('MM/dd/yyyy').format(
                                                  service.selectedEndDate),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Service Time: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              service.selectedTimeSlot,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Description: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          service.description,
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Minimum Age: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              service.minAge.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Maximum Age: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              service.maxAge.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Capacity : ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              service.capacityValue.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Service Price: ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${service.servicePrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditService(
                                                      service: service,
                                                      onUpdateService:
                                                          updateService,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Edit Service',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              158,
                                                              158,
                                                              158),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                deleteService(service);
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Delete Service',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            compSerListScreen(centerName: centerName),
                      ),
                    );
                    // Handle profile button tap
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
}
