import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';

/// User Preference Keys
class UserPreferenceKeys {
  static const String technicianName = 'technician_name';
  static const String technicianId = 'technician_id';
  static const String profileImagePath = 'profile_image_path';
}

/// Settings State
class SettingsState {
  final String technicianName;
  final String technicianId;
  final String? profileImagePath;

  SettingsState({
    required this.technicianName,
    required this.technicianId,
    this.profileImagePath,
  });

  SettingsState copyWith({
    String? technicianName,
    String? technicianId,
    String? profileImagePath,
  }) {
    return SettingsState(
      technicianName: technicianName ?? this.technicianName,
      technicianId: technicianId ?? this.technicianId,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

/// Settings Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(
          technicianName: 'ferdiodwi',
          technicianId: '24',
        )) {
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box(AppConstants.settingsBox);
    state = SettingsState(
      technicianName: box.get(UserPreferenceKeys.technicianName, defaultValue: 'ferdiodwi'),
      technicianId: box.get(UserPreferenceKeys.technicianId, defaultValue: '24'),
      profileImagePath: box.get(UserPreferenceKeys.profileImagePath),
    );
  }

  Future<void> updateProfile({required String name, required String id}) async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(UserPreferenceKeys.technicianName, name);
    await box.put(UserPreferenceKeys.technicianId, id);
    state = state.copyWith(technicianName: name, technicianId: id);
  }

  Future<void> updateProfileImage(String path) async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(UserPreferenceKeys.profileImagePath, path);
    state = state.copyWith(profileImagePath: path);
  }
}

/// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
