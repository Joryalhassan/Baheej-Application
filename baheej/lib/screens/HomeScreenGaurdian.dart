import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:baheej/screens/ServiceDetailsPage.dart';
import 'package:baheej/screens/Addkids.dart';

class Service {
  final String serviceName;
  final String description;
  final String centerName;
  final int selectedTimeSlot;
  final int capacityValue;
  final double servicePrice;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final String ageRange;

  Service({
    required this.serviceName,
    required this.description,
    required this.centerName,
    required this.selectedEndDate,
    required this.selectedStartDate,
    required this.ageRange,
    required this.capacityValue,
    required this.servicePrice,
    required this.selectedTimeSlot,
  });
}

class HomeScreenGaurdian extends StatefulWidget {
  const HomeScreenGaurdian({Key? key}) : super(key: key);

  @override
  _HomeScreenGaurdianState createState() => _HomeScreenGaurdianState();
}

class _HomeScreenGaurdianState extends State<HomeScreenGaurdian> {
  int _currentIndex = 0;
  Future<List<Service>>? _services;

  @override
  void initState() {
    super.initState();
    _services = fetchDataFromFirebase();
  }

  Future<List<Service>> fetchDataFromFirebase() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('center-service');

    final querySnapshot = await collection.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final serviceName = data['serviceName'] ?? 'Default Title';
      final description = data['serviceDesc'] ?? 'Default Description';
      final centerName = data['centerName'] ?? 'Default Center Name';
      final selectedTimeSlot = data['selectedTimeSlot'] ?? 0;
      final capacityValue = data['capacityValue'] ?? 0;
      final servicePrice = data['servicePrice'] ?? 0.0;
      final selectedStartDate =
          (data['selectedStartDate'] as Timestamp?)?.toDate() ?? DateTime.now();
      final selectedEndDate =
          (data['selectedEndDate'] as Timestamp?)?.toDate() ?? DateTime.now();
      final ageRange = data['ageRange'] ?? 'Default Age Range';

      return Service(
        serviceName: serviceName,
        description: description,
        centerName: centerName,
        selectedTimeSlot: selectedTimeSlot,
        capacityValue: capacityValue,
        servicePrice: servicePrice,
        selectedStartDate: selectedStartDate,
        selectedEndDate: selectedEndDate,
        ageRange: ageRange,
      );
    }).toList();
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("Signed Out");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _navigateToServiceDetails(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailsPage(
          serviceName: service.serviceName,
          serviceDescription: service.description,
          centerName: service.centerName,
          selectedTimeSlot: service.selectedTimeSlot,
          capacityValue: service.capacityValue,
          servicePrice: service.servicePrice,
          selectedStartDate: service.selectedStartDate,
          selectedEndDate: service.selectedEndDate,
          ageRange: service.ageRange,
        ),
      ),
    );
  }

  void _handleAddKids() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddKidsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Home"),
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backG.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Your content goes here
          FutureBuilder<List<Service>>(
            future: _services,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No services available.'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final service = snapshot.data![index];
                    return GestureDetector(
                      onTap: () {
                        _navigateToServiceDetails(service);
                      },
                      child: Card(
                        margin: EdgeInsets.only(top: 20),
                        child: ListTile(
                          title: Text(service.serviceName),
                          subtitle: Text(service.description),
                        ),
                      ),
                    );
                  },
                );
              }
            },
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
                    // Handle history button tap
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'History',
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
                IconButton(
                  icon: Icon(Icons.person_add),
                  color: Colors.white,
                  onPressed: _handleAddKids,
                ),
                Text(
                  'Add Kids',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
        onPressed: () {
          // Handle the floating action button tap (Home)
        },
        child: Icon(
          Icons.add_reaction_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}
