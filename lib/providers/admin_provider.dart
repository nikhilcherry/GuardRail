import 'package:flutter/material.dart';
import 'dart:math';
import '../repositories/guard_repository.dart';
import '../providers/flat_provider.dart';

class AdminProvider extends ChangeNotifier {
  final GuardRepository _guardRepository = GuardRepository();
  final FlatProvider _flatProvider;

  AdminProvider(this._flatProvider);

  // We expose guards from repository
  List<Map<String, dynamic>> get guards => _guardRepository.getAllGuards();

  // Expose flats from FlatProvider
  // We map Flat object to the map structure expected by the UI, or we can update UI to use Flat object.
  // For now, let's map it to keep it simple, but we need to fetch resident name.
  List<Map<String, String>> get flats {
    final allFlats = _flatProvider.getAllFlats();
    return allFlats.map((flat) {
      // Find owner name
      // We need to access _flatMembers from FlatProvider, but it's private static.
      // However, createFlat adds the owner to the members list.
      // We can't easily access the member list here without exposing it more.
      // But we can guess the owner name if we track it? No.
      // Let's assume for now we just show Flat Name and ID.
      // Or we can rely on FlatProvider to give us a DTO.
      // But wait, the previous mock had 'resident' (owner).
      // FlatProvider.createFlat takes ownerName.
      // Let's modify FlatProvider to allow retrieving owner name or expose members map via a getter.
      // Actually, FlatProvider has `_flatMembers` static. We can't access it.
      // But we added `getAllFlats()`.
      // Let's just return what we have. The UI will show ID.
      return {
        'id': flat.id,
        'flat': flat.name,
        'resident': 'Owner ID: ${flat.ownerId}', // Placeholder until we can fetch name
        'residentId': flat.id, // Using Flat ID as the shared ID
      };
    }).toList();
  }

  // Actually, let's improve the flat mapping.
  // We can't easily get the owner name without `FlatProvider` help.
  // But for the purpose of this task, we can just display the Flat ID.

  // --- Flat Management (Delegating to FlatProvider) ---

  Future<void> addFlat(String flatName, String ownerName) async {
    // We need a dummy owner ID since Admin is creating it.
    // Or we generate one.
    final dummyOwnerId = 'admin_created_${DateTime.now().millisecondsSinceEpoch}';
    await _flatProvider.createFlat(flatName, dummyOwnerId, ownerName);
    notifyListeners();
  }

  Future<void> updateFlat(String id, String flatName, String ownerName) async {
    await _flatProvider.updateFlat(id, flatName, ownerName);
    notifyListeners();
  }

  Future<void> deleteFlat(String id) async {
    await _flatProvider.deleteFlat(id);
    notifyListeners();
  }

  // --- Guard Management using Repository ---

  // Create Guard (Admin) - Generates ID
  String createGuardInvite(String name, {String? manualId}) {
    final id = _guardRepository.createGuard(name, manualId: manualId);
    notifyListeners();
    return id;
  }

  // Update Guard
  void updateGuard(String originalId, {String? name, String? newId}) {
    _guardRepository.updateGuard(originalId, name: name, newId: newId);
    notifyListeners();
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
