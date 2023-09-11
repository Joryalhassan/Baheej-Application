import 'package:flutter/material.dart';
import 'package:baheej/screens/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baheej/screens/Service.dart';

class Service {
  final String name;
  final int timeSlot; // 0 for 8-11 AM, 1 for 2-5 PM
  final double price;
  final String description;
  final int capacity;
  final int age;
  final DateTime startDate;
  final DateTime endDate;

  Service({
    required this.name,
    required this.timeSlot,
    required this.price,
    required this.description,
    required this.capacity,
    required this.age,
    required this.startDate,
    required this.endDate,
  });

//   // Convert Service object to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'timeSlot': timeSlot,
//       'price': price,
//       'description': description,
//       'capacity': capacity,
//       'age': age,
//       'startDate': Timestamp.fromDate(startDate),
//       'endDate': Timestamp.fromDate(endDate),
//     };
//   }

//   // Create a Service object from JSON data
//   factory Service.fromJson(Map<String, dynamic> json) {
//     return Service(
//       name: json['name'],
//       timeSlot: json['timeSlot'],
//       price: json['price'],
//       description: json['description'],
//       capacity: json['capacity'],
//       age: json['age'],
//       startDate: (json['startDate'] as Timestamp).toDate(),
//       endDate: (json['endDate'] as Timestamp).toDate(),
//     );
//   }
// }

// class FirestoreService {
//   final CollectionReference servicesCollection =
//       FirebaseFirestore.instance.collection('centers');

//   Future<void> addService(Service newService) async {
//     try {
//       // Convert the Service object to JSON
//       final json = newService.toJson();

//       // Add the JSON data to Firestore
//       await servicesCollection.add(json);
//       print('Service added to Firestore');
//     } catch (e) {
//       print('Error adding service to Firestore: $e');
//     }
//   }
}




// import 'package:flutter/material.dart';
// import 'package:baheej/screens/firebase_service.dart';

// class Service {
//   final String name;
//   final int timeSlot; // 0 for 8-11 AM, 1 for 2-5 PM
//   final double price;
//   final String description;
//   final int capacity;
//   final int age;
//   final DateTime startDate;
//   final DateTime endDate;

//   Service({
//     required this.name,
//     required this.timeSlot,
//     required this.price,
//     required this.description,
//     required this.capacity,
//     required this.age,
//     required this.startDate,
//     required this.endDate,
//   });
// }
