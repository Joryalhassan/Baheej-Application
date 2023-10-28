import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/EditService.dart';

class HomeScreenCenter extends StatefulWidget {
  const HomeScreenCenter({Key? key}) : super(key: key);

  @override
  _HomeScreenCenterState createState() => _HomeScreenCenterState();
}

class _HomeScreenCenterState extends State<HomeScreenCenter> {
  int _currentIndex = 0;
  List<Service> services = [];
  String userName = ''; // Initialize userName
  String searchText = ''; // Initialize searchText

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      navigateToServiceFormScreen();
    }
  }
    // Function to navigate to the EditService page
  void navigateToEditService(String serviceId) async {
    final editedService = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditService(serviceId:serviceId),
      ),
    );

    // Handle updates to the service data if needed
    if (editedService != null) {
      // You can update the service data here if necessary
    }
  }


  @override
  void initState() {
    super.initState();
    // Fetch the user's name from Firestore when the screen initializes
    fetchUserName();
     fetchDataFromFirebase().then((services) {
      setState(() {
        this.services = services;
      });
    });
  }
Future<List<Service>> fetchDataFromFirebase() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('center-service');
  final querySnapshot = await collection
      .where('centerName', isEqualTo: userName) // Filter by centerName
      .get();

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
    final id = doc.id; // Get the document ID

    return Service(
       id: id, // Initialize the ID field
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
    );
  }).toList();
}

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

  void navigateToServiceFormScreen() async {
    final newService = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ServiceFormScreen()),
    );

    if (newService != null) {
      setState(() {
        services.add(newService);
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

  void filterServices(String query) {
    setState(() {
      searchText = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/backG.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Welcome $userName',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: _handleLogout,
                      color: Colors.white,
                    ),
                  ],
                  floating: false,
                  pinned: true,
                  snap: false,

                  // Add space between upper bar and cards
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(120.0), // Adjust the height as needed
                    child: SizedBox(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: filterServices,
                      decoration: InputDecoration(
                        labelText: 'Search Services',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('center-service')
                  .where('centerName', isEqualTo: userName) // Filter services for the current center
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator(); // Display a loading indicator.
                }

                final filteredServices = snapshot.data!.docs.where((service) {
                  final serviceData = service.data() as Map<String, dynamic>;
                  final serviceName = serviceData['serviceName'] ?? '';

                  // Check if the service name contains the search text
                  return serviceName.toLowerCase().contains(searchText.toLowerCase());
                }).toList();

                // Use a ListView.builder to create a card for each service.
                return ListView.builder(
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    final serviceData = service.data() as Map<String, dynamic>;

                    // Check the type before casting Timestamp fields
                    final startDate = serviceData['startDate'] is Timestamp
                        ? (serviceData['startDate'] as Timestamp).toDate()
                        : null;

                    final endDate = serviceData['endDate'] is Timestamp
                        ? (serviceData['endDate'] as Timestamp).toDate()
                        : null;


                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(serviceData['serviceName'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Center Name: ${serviceData['centerName'] ?? 'Unknown'}'),
                            Text(
                                'Service Description: ${serviceData['serviceDesc'] ?? 'No Description'}'),
                            Text(
                                'Start Date: ${startDate != null ? startDate.toString() : 'Unknown'}'),
                            Text(
                                'End Date: ${endDate != null ? endDate.toString() : 'Unknown'}'),
                            Text(
                                'Age Range: ${serviceData['minAge'] ?? 'Unknown'} - ${serviceData['maxAge'] ?? 'Unknown'}'),
                            Text(
                                'Time Slot: ${serviceData['selectedTimeSlot'] ?? 'Unknown'}'),
                            Text(
                                'Service Capacity: ${serviceData['serviceCapacity'] ?? 'Unknown'}'),
                            Text(
                                'Service Price: ${serviceData['servicePrice'] ?? 'Unknown'}'),
                                 ElevatedButton(
                        onPressed: () {
                          
                          navigateToEditService(service.id); // Navigate to EditService
                        },
                        child: Text('Edit Service'),
                      ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
        onPressed: () async {
          navigateToServiceFormScreen();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}