import 'package:flutter/material.dart';
import 'dart:math';
import '../repositories/guard_repository.dart';

class AdminProvider extends ChangeNotifier {
  final GuardRepository _guardRepository = GuardRepository();

  final List<Map<String, String>> _flats = [
    {'flat': '101', 'resident': 'Alice Smith', 'residentId': ''},
    {'flat': '102', 'resident': 'Bob Johnson', 'residentId': ''},
  ];

  // We expose guards from repository, converting to the map structure UI expects if needed,
  // or better, just exposing the list from repository.
  List<Map<String, dynamic>> get guards => _guardRepository.getAllGuards();

  List<Map<String, String>> get flats => _flats;

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

  // --- Guard Management using Repository ---

  // Create Guard (Admin) - Generates ID
  String createGuardInvite(String name) {
    final id = _guardRepository.createGuard(name);
    notifyListeners();
    return id;
  }

  // Approve Guard
  void approveGuard(String id) {
    _guardRepository.updateGuardStatus(id, 'active');
    notifyListeners();
  }

  // Reject Guard
  void rejectGuard(String id) {
    _guardRepository.updateGuardStatus(id, 'rejected');
    notifyListeners();
  }

  // Delete Guard
  void deleteGuard(String id) {
    _guardRepository.deleteGuard(id);
    notifyListeners();
  }
}
