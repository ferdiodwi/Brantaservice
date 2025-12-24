import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/bangkai.dart';
import '../core/constants/app_constants.dart';

/// Provider for InventoryNote box
final inventoryNoteBoxProvider = Provider<Box<InventoryNote>>((ref) {
  return Hive.box<InventoryNote>(AppConstants.bangkaiBox);
});

/// Provider for list of all inventory notes
final inventoryNoteListProvider = StateNotifierProvider<InventoryNoteNotifier, List<InventoryNote>>((ref) {
  final box = ref.watch(inventoryNoteBoxProvider);
  return InventoryNoteNotifier(box);
});

/// Search query provider
final inventorySearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered inventory notes based on search
final filteredInventoryNotesProvider = Provider<List<InventoryNote>>((ref) {
  final notes = ref.watch(inventoryNoteListProvider);
  final query = ref.watch(inventorySearchQueryProvider).toLowerCase();
  
  if (query.isEmpty) return notes;
  
  return notes.where((note) {
    if (note.title.toLowerCase().contains(query)) return true;
    if (note.description?.toLowerCase().contains(query) ?? false) return true;
    return false;
  }).toList();
});

/// InventoryNote state notifier
class InventoryNoteNotifier extends StateNotifier<List<InventoryNote>> {
  final Box<InventoryNote> _box;
  
  InventoryNoteNotifier(this._box) : super([]) {
    _loadFromBox();
  }
  
  void _loadFromBox() {
    state = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Add new note
  Future<void> addNote(InventoryNote note) async {
    await _box.put(note.id, note);
    _loadFromBox();
  }
  
  /// Update note
  Future<void> updateNote(InventoryNote note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _box.put(updated.id, updated);
    _loadFromBox();
  }
  
  /// Delete note
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    _loadFromBox();
  }
}
