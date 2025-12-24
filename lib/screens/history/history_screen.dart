import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/service_provider.dart';
import '../../data/models/service.dart';
import '../../core/l10n/app_localizations.dart';

/// HistoryScreen - Riwayat Service
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  String? _selectedBrand;
  Set<ServiceStatus> _selectedStatuses = {};
  final _searchController = TextEditingController();
  
  // Multi-select state
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }
  
  void _toggleSelectAll(List<Service> services) {
    setState(() {
      final allIds = services.map((s) => s.id).toSet();
      if (_selectedIds.containsAll(allIds)) {
        // All are selected, so deselect all
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        // Select all
        _selectedIds.addAll(allIds);
      }
    });
  }
  
  bool _isAllSelected(List<Service> services) {
    if (services.isEmpty) return false;
    return services.every((s) => _selectedIds.contains(s.id));
  }
  
  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }
  
  void _enterSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(id);
    });
  }
  
  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final count = _selectedIds.length;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus $count Service?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.translate('dialog_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      for (final id in _selectedIds) {
        await ref.read(serviceProvider.notifier).deleteService(id);
      }
      _clearSelection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count service dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceProvider);
    final l10n = AppLocalizations.of(context)!;
    
    // Filter services - hanya tampilkan service yang sudah selesai/batal (riwayat)
    var filteredServices = services.where((s) => 
      s.status == ServiceStatus.completed || 
      s.status == ServiceStatus.cancelled
    ).toList();
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredServices = filteredServices.where((s) =>
        s.customerName.toLowerCase().contains(query) ||
        s.customerPhone.contains(query) ||
        s.deviceBrand.toLowerCase().contains(query) ||
        s.deviceModel.toLowerCase().contains(query)
      ).toList();
    }
    if (_selectedBrand != null && _selectedBrand != 'All') {
      filteredServices = filteredServices
          .where((s) => s.deviceBrand == _selectedBrand)
          .toList();
    }
    if (_selectedStatuses.isNotEmpty) {
      filteredServices = filteredServices
          .where((s) => _selectedStatuses.contains(s.status))
          .toList();
    }
    
    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) {
          _clearSelection();
        }
      },
      child: Scaffold(
      // backgroundColor: AppColors.background,
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
              title: Text('${_selectedIds.length} dipilih'),
              actions: [
                IconButton(
                  icon: Icon(_isAllSelected(filteredServices) 
                      ? Icons.deselect 
                      : Icons.select_all),
                  tooltip: _isAllSelected(filteredServices) ? 'Batal Pilih Semua' : 'Pilih Semua',
                  onPressed: () => _toggleSelectAll(filteredServices),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Hapus',
                  onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
                ),
              ],
            )
          : AppBar(
              title: const Text('Riwayat'),
              // backgroundColor: AppColors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: () => _showFilterSheet(context),
                ),
              ],
            ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: l10n.translate('history_search_placeholder'),
                prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Brand Filter Chips
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedBrand == null || _selectedBrand == 'All',
                  onTap: () => setState(() => _selectedBrand = null),
                ),
                ...['Apple', 'Samsung', 'Xiaomi', 'Oppo', 'Vivo', 'Realme', 'Huawei', 'OnePlus', 'Google', 'Other'].map((brand) => 
                  _FilterChip(
                    label: brand,
                    icon: _getBrandIcon(brand),
                    isSelected: _selectedBrand == brand,
                    onTap: () => setState(() => _selectedBrand = brand),
                  ),
                ),
              ],
            ),
          ),
          
          const Gap(8),
          
          // Service List
          Expanded(
            child: filteredServices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const Gap(16),
                        Text(
                          l10n.translate('history_empty_title'),
                          style: AppTypography.headingXS.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada riwayat ditemukan'
                              : 'Belum ada riwayat service',
                          style: AppTypography.bodyMD.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      final isSelected = _selectedIds.contains(service.id);
                      return _ServiceCard(
                        service: service,
                        number: index + 1,
                        isSelected: isSelected,
                        isSelectionMode: _isSelectionMode,
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleSelection(service.id);
                          } else {
                            context.push('/service/${service.id}');
                          }
                        },
                        onLongPress: () => _enterSelectionMode(service.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }
  
  IconData _getBrandIcon(String brand) {
    switch (brand) {
      case 'Apple':
        return Icons.apple_rounded;
      case 'Samsung':
        return Icons.phone_android_rounded;
      default:
        return Icons.smartphone_rounded;
    }
  }
  
  void _showFilterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Create a local copy for the sheet
    Set<ServiceStatus> tempSelectedStatuses = Set.from(_selectedStatuses);
    
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.translate('history_filter_title'), style: AppTypography.headingXS),
                  if (tempSelectedStatuses.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setSheetState(() => tempSelectedStatuses.clear());
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
              const Gap(20),
              Text(l10n.translate('history_filter_status'), style: AppTypography.labelLG),
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ServiceStatus.values.map((status) {
                  final isSelected = tempSelectedStatuses.contains(status);
                  return FilterChip(
                    label: Text(
                      _getStatusLabel(status, l10n),
                      style: TextStyle(
                        color: isSelected ? AppColors.white : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setSheetState(() {
                        if (selected) {
                          tempSelectedStatuses.add(status);
                        } else {
                          tempSelectedStatuses.remove(status);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatuses = tempSelectedStatuses;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.translate('history_filter_apply')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(ServiceStatus status, AppLocalizations l10n) {
    switch (status) {
      case ServiceStatus.checkIn: return 'Masuk';
      case ServiceStatus.inProgress: return 'Diproses';
      case ServiceStatus.completed: return 'Selesai';
      case ServiceStatus.cancelled: return 'Batal';
    }
  }
}

/// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppColors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const Gap(6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Service Card Widget
class _ServiceCard extends StatelessWidget {
  final Service service;
  final int number;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  
  const _ServiceCard({
    required this.service,
    required this.number,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number Column (like table)
            SizedBox(
              width: 36,
              child: isSelectionMode
                  ? Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: AppColors.white, size: 16)
                          : null,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(
                        '$number.',
                        style: AppTypography.labelMD.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            // Card Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withOpacity(0.1) 
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected 
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                  boxShadow: isSelected ? null : [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Customer Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _getAvatarColor(service.customerName),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(service.customerName),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const Gap(12),
                        // Customer Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.customerName,
                                style: AppTypography.labelLG,
                              ),
                              Text(
                                '${Formatters.formatDateShort(service.createdAt)} • ${Formatters.formatTime(service.createdAt)}',
                                style: AppTypography.bodyXS.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status Badge
                        _StatusBadge(status: service.status),
                      ],
                    ),
                    const Gap(12),
                    const Divider(height: 1),
                    const Gap(12),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_android_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.deviceFullName,
                                style: AppTypography.labelMD,
                              ),
                              Text(
                                service.problemDescription,
                                style: AppTypography.bodySM.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty 
        ? parts[0][0].toUpperCase() 
        : '?';
  }
  
  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.secondary,
    ];
    return colors[name.hashCode % colors.length];
  }
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final ServiceStatus status;
  
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String text;
    
    switch (status) {
      case ServiceStatus.checkIn:
        color = AppColors.primary;
        text = 'Masuk';
        break;
      case ServiceStatus.inProgress:
        color = AppColors.info;
        text = 'Diproses';
        break;
      case ServiceStatus.completed:
        color = AppColors.success;
        text = 'Selesai';
        break;
      case ServiceStatus.cancelled:
        color = AppColors.error;
        text = 'Batal';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
