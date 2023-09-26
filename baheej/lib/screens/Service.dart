//import 'package:baheej/screens/firebase_service.dart';

class Service {
  final String serviceName;
  final String description;
  final String centerName;
  final String selectedTimeSlot;
  final int capacityValue;
  final double servicePrice;
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final int minAge;
  final int maxAge;

  Service({
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
  });
}
