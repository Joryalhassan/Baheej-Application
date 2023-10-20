/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';

class CenterServices extends StatefulWidget {
  final String centerName;

  CenterServices({required this.centerName});

  @override
  _CenterServicesState createState() => _CenterServicesState();
}

class _CenterServicesState extends State<CenterServices> {
  List<Service> services = [];

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('center-service')
          .where('centerName', isEqualTo: widget.centerName)
          .get();

      final List<Service> loadedServices = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Service(
          serviceName: data['serviceName'] as String? ?? 'Service Name Missing',
          description: data['description'] as String? ?? 'Description Missing',
          centerName: data['centerName'] as String? ?? 'Center Name Missing',
          selectedStartDate: data['selectedStartDate'] != null
              ? (data['selectedStartDate'] as Timestamp).toDate()
              : DateTime.now(),
          selectedEndDate: data['selectedEndDate'] != null
              ? (data['selectedEndDate'] as Timestamp).toDate()
              : DateTime.now(),
          minAge: data['minAge'] as int? ?? 0,
          maxAge: data['maxAge'] as int? ?? 0,
          capacityValue: data['capacityValue'] as int? ?? 0,
          servicePrice: data['servicePrice'] is double
              ? data['servicePrice']
              : (data['servicePrice'] is int
                  ? (data['servicePrice'] as int).toDouble()
                  : 0.0),
          selectedTimeSlot:
              data['selectedTimeSlot'] as String? ?? 'Time Slot Missing',
        );
      }).toList();

      setState(() {
        services = loadedServices;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/backG.png', // Set your background image
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
                  title: Text('Your Center Services'),
                ),
              ];
            },
            body: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(service.serviceName ?? 'No Service Name'),
                    subtitle: Text(
                      'Description: ${service.description ?? 'No Description'}\n'
                      'Time Slot: ${service.selectedTimeSlot ?? 'No Time Slot'}\n'
                      'Capacity: ${service.capacityValue ?? 0}\n'
                      'Price: \$${service.servicePrice.toStringAsFixed(2)}\n'
                      'Age Range: ${service.minAge ?? 0} - ${service.maxAge ?? 0}\n'
                      'Start Date: ${service.selectedStartDate?.toString() ?? 'No Start Date'}\n'
                      'End Date: ${service.selectedEndDate?.toString() ?? 'No End Date'}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/
/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';

class CenterServices extends StatefulWidget {
  final String centerName;

  CenterServices({required this.centerName});

  @override
  _CenterServicesState createState() => _CenterServicesState();
}

class _CenterServicesState extends State<CenterServices> {
  List<Service> services = [];
  List<Service> filteredServices = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('center-service')
          .where('centerName', isEqualTo: widget.centerName)
          .get();

      final List<Service> loadedServices = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Service(
          serviceName: data['serviceName'] as String? ?? 'Service Name Missing',
          description: data['description'] as String? ?? 'Description Missing',
          centerName: data['centerName'] as String? ?? 'Center Name Missing',
          selectedStartDate: data['selectedStartDate'] != null
              ? (data['selectedStartDate'] as Timestamp).toDate()
              : DateTime.now(),
          selectedEndDate: data['selectedEndDate'] != null
              ? (data['selectedEndDate'] as Timestamp).toDate()
              : DateTime.now(),
          minAge: data['minAge'] as int? ?? 0,
          maxAge: data['maxAge'] as int? ?? 0,
          capacityValue: data['capacityValue'] as int? ?? 0,
          servicePrice: data['servicePrice'] is double
              ? data['servicePrice']
              : (data['servicePrice'] is int
                  ? (data['servicePrice'] as int).toDouble()
                  : 0.0),
          selectedTimeSlot:
              data['selectedTimeSlot'] as String? ?? 'Time Slot Missing',
        );
      }).toList();

      setState(() {
        services = loadedServices;
        filteredServices = loadedServices;
      });
    }
  }

  void _handleSearch(String query) {
    query = query.trim();
    setState(() {
      filteredServices = services
          .where((service) =>
              service.serviceName.toLowerCase().contains(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: Text('Your Center Services'),
                        expandedHeight:
                            200, // Adjust the expanded height as needed
                        floating: false,
                        pinned: true,
                      ),
                    ];
                  },
                  body: ListView.builder(
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(service.serviceName ?? 'No Service Name'),
                          subtitle: Text(
                            'Description: ${service.description ?? 'No Description'}\n'
                            'Time Slot: ${service.selectedTimeSlot ?? 'No Time Slot'}\n'
                            'Capacity: ${service.capacityValue ?? 0}\n'
                            'Price: \$${service.servicePrice.toStringAsFixed(2)}\n'
                            'Age Range: ${service.minAge ?? 0} - ${service.maxAge ?? 0}\n'
                            'Start Date: ${service.selectedStartDate?.toString() ?? 'No Start Date'}\n'
                            'End Date: ${service.selectedEndDate?.toString() ?? 'No End Date'}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/ServiceDetailsPage.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';

class CenterServices extends StatefulWidget {
  final String centerName;

  CenterServices({required this.centerName});

  @override
  _CenterServicesState createState() => _CenterServicesState();
}

class _CenterServicesState extends State<CenterServices> {
  List<Service> services = [];
  List<Service> filteredServices = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('center-service')
          .where('centerName', isEqualTo: widget.centerName)
          .get();

      final List<Service> loadedServices = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Service(
          serviceName: data['serviceName'] as String? ?? 'Service Name Missing',
          description: data['description'] as String? ?? 'Description Missing',
          centerName: data['centerName'] as String? ?? 'Center Name Missing',
          selectedStartDate: data['selectedStartDate'] != null
              ? (data['selectedStartDate'] as Timestamp).toDate()
              : DateTime.now(),
          selectedEndDate: data['selectedEndDate'] != null
              ? (data['selectedEndDate'] as Timestamp).toDate()
              : DateTime.now(),
          minAge: data['minAge'] as int? ?? 0,
          maxAge: data['maxAge'] as int? ?? 0,
          capacityValue: data['capacityValue'] as int? ?? 0,
          servicePrice: data['servicePrice'] is double
              ? data['servicePrice']
              : (data['servicePrice'] is int
                  ? (data['servicePrice'] as int).toDouble()
                  : 0.0),
          selectedTimeSlot:
              data['selectedTimeSlot'] as String? ?? 'Time Slot Missing',
        );
      }).toList();

      setState(() {
        services = loadedServices;
        filteredServices = loadedServices;
      });
    }
  }

  void _handleSearch(String query) {
    query = query.trim();
    setState(() {
      filteredServices = services
          .where((service) =>
              service.serviceName.toLowerCase().contains(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Your Center Services'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Add your logout logic here
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
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 30),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return GestureDetector(
                        onTap: () {
                          // Handle tapping on a service
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceDetailsPage(
                                service: service,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
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
                                  //Text(
                                  // 'center name: ${service.centerName}',
                                  // style: TextStyle(
                                  //   fontSize: 16,
                                  // ),
                                  //),
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
                                      Row(
                                        children: [
                                          Text(
                                            'View Details',
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
                                    ],
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
          ServiceFormScreen();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
