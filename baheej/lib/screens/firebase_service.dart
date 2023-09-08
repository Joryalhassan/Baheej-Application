// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:baheej/screens/Service.dart';
// import 'package:flutter/material.dart';
// import 'package:baheej/screens/Service.dart';

// class FirestoreService {
//   final CollectionReference servicesCollection =
//       FirebaseFirestore.instance.collection('centers');

//   Future<void> addService(Service newService) async {
//     final docCenter = FirebaseFirestore.instance.collection('centers').doc();
//     final service = Service(
//        'name': newService.name,
//         'price': newService.price,
//         'description': newService.description,
//         'capacity': newService.capacity,
//         'age': newService.age,
//         'startDate': Timestamp.fromDate(newService.startDate),
//         'endDate': Timestamp.fromDate(newService.endDate),
//         'startTime': Timestamp.fromDate(DateTime(newService.startDate.year,
//             newService.startDate.month, newService.startDate.day)),
//         'endTime': Timestamp.fromDate(DateTime(newService.endDate.year,
//             newService.endDate.month, newService.endDate.day)),

//     );
//     final json = service.toJson();


//     // write in database
//     await docCenter.set(json);
//   }
//   Map<String,dynamic> toJson() =>
//   {
//     'name': newService.name,
//         'price': newService.price,
//         'description': newService.description,
//         'capacity': newService.capacity,
//         'age': newService.age,
//         'startDate': Timestamp.fromDate(newService.startDate),
//         'endDate': Timestamp.fromDate(newService.endDate),
//         'startTime': Timestamp.fromDate(DateTime(newService.startDate.year,
//             newService.startDate.month, newService.startDate.day)),
//         'endTime': Timestamp.fromDate(DateTime(newService.endDate.year,
//             newService.endDate.month, newService.endDate.day)),

//   };
// }



 //   try {
  //     await servicesCollection.add({
  //       'name': newService.name,
  //       'price': newService.price,
  //       'description': newService.description,
  //       'capacity': newService.capacity,
  //       'age': newService.age,
  //       'startDate': Timestamp.fromDate(newService.startDate),
  //       'endDate': Timestamp.fromDate(newService.endDate),
  //       'startTime': Timestamp.fromDate(DateTime(newService.startDate.year,
  //           newService.startDate.month, newService.startDate.day)),
  //       'endTime': Timestamp.fromDate(DateTime(newService.endDate.year,
  //           newService.endDate.month, newService.endDate.day)),
  //     });
  //     print('Service added to Firestore');
  //   } catch (e) {
  //     print('Error adding service to Firestore: $e');
  //   }
  // }
