import 'package:flutter/material.dart';
import 'dart:math';

class AdminProvider extends ChangeNotifier {
  final List<Map<String, String>> _flats = [
    {'flat': '101', 'resident': 'Alice Smith', 'residentId': ''},
    {'flat': '102', 'resident': 'Bob Johnson', 'residentId': ''},
  ];

  final List<Map<String, String>> _guards = [
    {'name': 'Ramesh', 'id': 'G001', 'status': 'Active'},
    {'name': 'Suresh', 'id': 'G002', 'status': 'Inactive'},
  ];

  List<Map<String, String>> get flats => _flats;
  List<Map<String, String>> get guards => _guards;

  String _generateRandomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void generateResidentId(int index) {
    final flat = _flats[index];
    _flats[index] = {
      ...flat,
      'residentId': _generateRandomId(),
    };
    notifyListeners();
  }

  void deleteFlat(int index) {
    _flats.removeAt(index);
    notifyListeners();
  }

  void deleteGuard(int index) {
    _guards.removeAt(index);
    notifyListeners();
  }

  // Add Flat
  void addFlat(String flat, String resident) {
    _flats.add({'flat': flat, 'resident': resident, 'residentId': ''});
    notifyListeners();
  }

  // Update Flat
  void updateFlat(int index, String flat, String resident) {
    final oldId = _flats[index]['residentId'] ?? '';
    _flats[index] = {'flat': flat, 'resident': resident, 'residentId': oldId};
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
