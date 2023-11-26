//import 'package:baheej/screens/firebase_service.dart';

class Service {
  final String id;
  final String serviceName; // done
  final String description; // done
  final String centerName;
  final String selectedTimeSlot; //done
  final int capacityValue;
  final double servicePrice; //done
  final DateTime selectedStartDate; // Make it nullable // done
  final DateTime selectedEndDate; //done
  final int minAge;
  final int maxAge;
  // final Map<String, String> selectedKidsNames; // Define the property
  final int participateNo;
  final int starsrate; // Define the starsrate property

  Service({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.centerName,
    required this.selectedEndDate,
    required this.selectedStartDate,
    required this.minAge,
    required this.maxAge,
    required this.capacityValue,
    required this.servicePrice,
    required this.selectedTimeSlot,
    // required this.selectedKidsNames,
    required this.participateNo,
    required this.starsrate,
  });

  // Define constants for the timeslots
  static const String timeslotMorning = '8-11 AM';
  static const String timeslotAfternoon = '2-5 PM';
}
