import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  final List<Map<String, String>> _flats = [
    {'flat': '101', 'resident': 'Alice Smith'},
    {'flat': '102', 'resident': 'Bob Johnson'},
  ];

  final List<Map<String, String>> _guards = [
    {'name': 'Ramesh', 'id': 'G001', 'status': 'Active'},
    {'name': 'Suresh', 'id': 'G002', 'status': 'Inactive'},
  ];

  List<Map<String, String>> get flats => _flats;
  List<Map<String, String>> get guards => _guards;

  // Add Flat
  void addFlat(String flat, String resident) {
    _flats.add({'flat': flat, 'resident': resident});
    notifyListeners();
  }

  // Update Flat
  void updateFlat(int index, String flat, String resident) {
    _flats[index] = {'flat': flat, 'resident': resident};
    notifyListeners();
  }

  // Add Guard
  void addGuard(String name, String id) {
    _guards.add({'name': name, 'id': id, 'status': 'Active'});
    notifyListeners();
  }

  // Update Guard
  void updateGuard(int index, String name, String id) {
    final oldStatus = _guards[index]['status']!;
    _guards[index] = {'name': name, 'id': id, 'status': oldStatus};
    notifyListeners();
  }
}
