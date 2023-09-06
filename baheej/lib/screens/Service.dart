import 'package:flutter/material.dart';

class Service {
  final String name;
  final TimeOfDay time;
  final double price;
  final String description;
  final int capacity;
  final int age;
  final DateTime Date;

  Service({
    required this.name,
    required this.time,
    required this.price,
    required this.description,
    required this.capacity,
    required this.age,
    required this.Date,
  });
}
