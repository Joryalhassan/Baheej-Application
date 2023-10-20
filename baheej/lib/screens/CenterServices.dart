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
import 'package:firebase_auth/firebase_auth.dart';
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
}
