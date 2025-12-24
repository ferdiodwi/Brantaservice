import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/service_provider.dart';
import '../../data/models/service.dart';

/// ActiveServiceScreen - Menampilkan service yang sedang aktif (Masuk + Diproses)
class ActiveServiceScreen extends ConsumerStatefulWidget {
  const ActiveServiceScreen({super.key});

  @override
  ConsumerState<ActiveServiceScreen> createState() => _ActiveServiceScreenState();
}

class _ActiveServiceScreenState extends ConsumerState<ActiveServiceScreen> {
  String _searchQuery = '';
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
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
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
  
  Future<void> _markSelectedAsCompleted() async {
    final count = _selectedIds.length;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selesaikan $count Service?'),
        content: const Text('Service akan dipindahkan ke riwayat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.success),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      for (final id in _selectedIds) {
        await ref.read(serviceProvider.notifier).updateStatus(id, ServiceStatus.completed);
      }
      _clearSelection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count service diselesaikan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(serviceProvider);
    // final l10n = AppLocalizations.of(context)!;
    
    // Filter hanya service aktif (checkIn + inProgress)
    var activeServices = services.where((s) => 
      s.status == ServiceStatus.checkIn || 
      s.status == ServiceStatus.inProgress
    ).toList();
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      activeServices = activeServices.where((s) =>
        s.customerName.toLowerCase().contains(query) ||
        s.customerPhone.contains(query) ||
        s.deviceBrand.toLowerCase().contains(query) ||
        s.deviceModel.toLowerCase().contains(query)
      ).toList();
    }
    
    // Count by status
    final checkInCount = activeServices.where((s) => s.status == ServiceStatus.checkIn).length;
    final inProgressCount = activeServices.where((s) => s.status == ServiceStatus.inProgress).length;
    
    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) {
          _clearSelection();
        }
      },
      child: Scaffold(
        appBar: _isSelectionMode
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSelection,
                ),
                title: Text('${_selectedIds.length} dipilih'),
                actions: [
                  IconButton(
                    icon: Icon(_isAllSelected(activeServices) 
                        ? Icons.deselect 
                        : Icons.select_all),
                    tooltip: _isAllSelected(activeServices) ? 'Batal Pilih Semua' : 'Pilih Semua',
                    onPressed: () => _toggleSelectAll(activeServices),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                    tooltip: 'Selesaikan',
                    onPressed: _selectedIds.isNotEmpty ? _markSelectedAsCompleted : null,
                  ),
                ],
              )
            : AppBar(
                title: const Text('Service Aktif'),
                elevation: 0,
              ),
        body: Column(
          children: [
            // Stats Cards
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.login_rounded,
                      label: 'Masuk',
                      count: checkInCount,
                      color: AppColors.primary,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.build_rounded,
                      label: 'Diproses',
                      count: inProgressCount,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari service...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            
            const Gap(16),
            
            // Service List
            Expanded(
              child: activeServices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const Gap(16),
                          Text(
                            'Tidak ada service aktif',
                            style: AppTypography.bodyMD.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            'Tambahkan service baru untuk memulai',
                            style: AppTypography.bodySM.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: activeServices.length,
                      itemBuilder: (context, index) {
                        final service = activeServices[index];
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/service/add'),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: AppColors.white),
        ),
      ),
    );
  }
}

/// Stat Chip Widget
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  
  const _StatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(8),
          Text(
            label,
            style: AppTypography.labelMD.copyWith(color: color),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
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
            // Number Column
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
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
  
  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];
    return colors[name.length % colors.length];
  }
}

/// Status Badge
class _StatusBadge extends StatelessWidget {
  final ServiceStatus status;
  
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
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
