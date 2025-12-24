import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../providers/settings_provider.dart';

/// SettingsScreen - Pengaturan Aplikasi
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final settingsState = ref.watch(settingsProvider);
    // final settingsNotifier = ref.read(settingsProvider.notifier);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.translate('settings_title')),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () => _showProfileOptions(context, ref, settingsState.profileImagePath),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          image: settingsState.profileImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(settingsState.profileImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: settingsState.profileImagePath == null
                            ? const Icon(
                                Icons.person_rounded,
                                color: AppColors.white,
                                size: 32,
                              )
                            : null,
                      ),
                    ),
                    const Gap(16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(settingsState.technicianName, style: AppTypography.headingXS.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                          const Gap(4),
                          Text(
                            'Technician ID: ${settingsState.technicianId}',
                            style: AppTypography.bodySM.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                l10n.translate('settings_profile_active'),
                                style: AppTypography.bodyXS.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Edit button
                    IconButton(
                      onPressed: () => _showEditProfileDialog(context, settingsState.technicianName, settingsState.technicianId),
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Security Section
              _SectionHeader(title: l10n.translate('settings_sec_security')),
              _SettingsTile(
                icon: Icons.lock_rounded,
                iconColor: AppColors.primary,
                title: l10n.translate('settings_item_pin'),
                trailing: Switch(
                  value: false, // Feature not implemented yet
                  onChanged: (value) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.translate('common_coming_soon')),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              
              const Gap(16),
              
              // Data Management Section
              _SectionHeader(title: l10n.translate('settings_sec_data')),
              _SettingsTile(
                icon: Icons.cloud_upload_rounded,
                iconColor: AppColors.primary,
                title: l10n.translate('settings_item_backup'),
                subtitle: 'Offline Backup', 
                onTap: () => _showBackupDialog(context),
              ),
              _SettingsTile(
                icon: Icons.restore_rounded,
                iconColor: AppColors.primary,
                title: l10n.translate('settings_item_restore'),
                onTap: () => _showRestoreDialog(context),
              ),
              
              const Gap(16),
              
              // General Section
              _SectionHeader(title: l10n.translate('settings_sec_general')),
              _SettingsTile(
                icon: Icons.info_rounded,
                iconColor: AppColors.primary,
                title: l10n.translate('settings_item_app_info'),
                onTap: () => _showAppInfo(context),
              ),
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.secondary,
                title: l10n.translate('settings_item_dark_mode'),
                trailing: Switch(
                  value: ref.watch(themeProvider) == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.info,
                title: l10n.translate('settings_item_language'),
                subtitle: currentLocale.languageCode == 'id' ? 'Bahasa Indonesia' : 'English',
                onTap: () => _showLanguageSelector(context),
              ),
              
              const Gap(16),
              


              
              const Gap(24),
              
              // Logout Button

              
              const Gap(24),
              
              // App Version
              Center(
                child: Column(
                  children: [
                    Text(
                      '${AppConstants.appName} v${AppConstants.appVersion}',
                      style: AppTypography.bodySM.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '© ${DateTime.now().year} Repair Tech Solutions',
                      style: AppTypography.bodyXS.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showEditProfileDialog(BuildContext context, String currentName, String currentId) {
    final nameController = TextEditingController(text: currentName);
    final idController = TextEditingController(text: currentId);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('common_edit_profile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.translate('common_name')),
            ),
            const Gap(16),
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: l10n.translate('common_technician_id')),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('common_cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateProfile(
                name: nameController.text.trim().isEmpty ? currentName : nameController.text.trim(),
                id: idController.text.trim().isEmpty ? currentId : idController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text(l10n.translate('common_save')),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('dialog_backup_title')),
        content: Text(
          l10n.translate('dialog_backup_content'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('common_understand')),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('dialog_restore_title')),
        content: Text(
          l10n.translate('dialog_restore_content'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('common_cancel')),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppConstants.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConstants.appVersion}'),
            const Gap(8),
            Text(l10n.translate('dialog_app_info_desc')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('dialog_ok')),
          ),
        ],
      ),
    );
  }
  


  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _cropImage(ref, pickedFile.path);
    }
  }

  Future<void> _cropImage(WidgetRef ref, String sourcePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 1080,
      maxHeight: 1080,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppLocalizations.of(ref.context)!.translate('common_crop_photo'),
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true, 
        ),
        IOSUiSettings(
          title: AppLocalizations.of(ref.context)!.translate('common_crop_photo'),
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      ref.read(settingsProvider.notifier).updateProfileImage(croppedFile.path);
    }
  }

  void _showProfileOptions(BuildContext context, WidgetRef ref, String? imagePath) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              ListTile(
                leading: const Icon(Icons.visibility_rounded, color: AppColors.primary),
                title: Text(l10n.translate('common_view_photo')),
                onTap: () {
                  Navigator.pop(context);
                  _viewProfilePhoto(context, imagePath);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text(imagePath == null ? l10n.translate('common_pick_photo') : l10n.translate('common_change_photo')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewProfilePhoto(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.contain,
                ),
              ),
              child: Image.file(File(imagePath)),
            ),
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentLocale = ref.watch(localeProvider);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('settings_item_language'),
                style: AppTypography.headingSM,
              ),
              const Gap(16),
              _LanguageOption(
                label: 'English',
                code: 'en',
                isSelected: currentLocale.languageCode == 'en',
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              _LanguageOption(
                label: 'Bahasa Indonesia',
                code: 'id',
                isSelected: currentLocale.languageCode == 'id',
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('id'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          code.toUpperCase(),
          style: AppTypography.labelMD.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
      title: Text(
        label,
        style: isSelected 
            ? AppTypography.labelLG.copyWith(color: AppColors.primary) 
            : AppTypography.bodyMD.copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}

/// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        title,
        style: AppTypography.overline.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

/// Settings Tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: AppTypography.labelLG.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        )),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: AppTypography.bodySM.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: trailing ?? (onTap != null 
            ? Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant)
            : null),
      ),
    );
  }
}
