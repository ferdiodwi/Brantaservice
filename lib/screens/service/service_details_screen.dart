import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/service_provider.dart';
import '../../data/models/service.dart';
import '../../core/l10n/app_localizations.dart';

/// ServiceDetailsScreen - Detail dan Edit Service
class ServiceDetailsScreen extends ConsumerWidget {
  final String serviceId;
  
  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(singleServiceProvider(serviceId));
    final l10n = AppLocalizations.of(context)!;
    
    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.translate('detail_title'))),
        body: Center(child: Text(l10n.translate('detail_not_found'))),
      );
    }
    
    return BackButtonListener(
      onBackButtonPressed: () async {
        context.go('/');
        return true;
      },
      child: Scaffold(
        // backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // App Bar with Status
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                onPressed: () => context.go('/'),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.white),
                  onPressed: () => _showEditSheet(context, ref, service),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.white),
                  onSelected: (value) => _handleMenuAction(context, ref, service, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'print', child: Text(l10n.translate('detail_menu_print'))),
                    PopupMenuItem(value: 'share', child: Text(l10n.translate('detail_menu_share'))),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(l10n.translate('detail_menu_delete'), style: const TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          service.deviceFullName,
                          style: AppTypography.headingXS.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'ID: ${service.id.substring(0, 8).toUpperCase()}',
                          style: AppTypography.bodySM.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Status Card
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
                      _StatusBadge(status: service.status),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.translate('detail_sec_status'), style: AppTypography.bodyXS.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            )),
                            Text(_getStatusText(service.status, l10n), style: AppTypography.labelLG),
                          ],
                        ),
                      ),
                      // Only show update button for active services (not completed/cancelled)
                      if (service.status != ServiceStatus.completed && 
                          service.status != ServiceStatus.cancelled)
                        ElevatedButton(
                          onPressed: () => _showStatusSheet(context, ref, service),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(l10n.translate('detail_btn_update'), style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                        ),
                    ],
                  ),
                ),
                
                // Customer Info
                _SectionCard(
                  title: l10n.translate('detail_sec_customer'),
                  icon: Icons.person_rounded,
                  onTap: () => context.push('/customer/${service.customerId}'),
                  children: [
                    _InfoRow(icon: Icons.person_outline, label: l10n.translate('entry_field_name').replaceAll(' *', ''), value: service.customerName),
                    _InfoRow(icon: Icons.phone_outlined, label: l10n.translate('entry_field_phone').replaceAll(' *', ''), value: service.customerPhone),
                  ],
                ),
                
                // Device Info
                _SectionCard(
                  title: l10n.translate('detail_sec_device'),
                  icon: Icons.phone_android_rounded,
                  children: [
                    _InfoRow(icon: Icons.branding_watermark_outlined, label: l10n.translate('entry_label_brand').replaceAll(' *', ''), value: service.deviceBrand),
                    _InfoRow(icon: Icons.phone_android_outlined, label: l10n.translate('entry_field_model').replaceAll(' *', ''), value: service.deviceModel),
                    if (service.deviceColor != null)
                      _InfoRow(icon: Icons.palette_outlined, label: l10n.translate('entry_field_color'), value: service.deviceColor!),
                    if (service.imei != null)
                      _InfoRow(icon: Icons.numbers_rounded, label: l10n.translate('entry_field_imei'), value: service.imei!),
                    if (service.serialNumber != null)
                      _InfoRow(icon: Icons.qr_code_rounded, label: l10n.translate('entry_field_serial'), value: service.serialNumber!),
                  ],
                ),
                
                // Problem & Repair
                _SectionCard(
                  title: l10n.translate('detail_sec_problem'),
                  icon: Icons.build_rounded,
                  children: [
                    _InfoRow(
                      icon: Icons.error_outline_rounded, 
                      label: l10n.translate('detail_label_problem'), 
                      value: service.problemDescription,
                      isMultiLine: true,
                    ),
                    if (service.repairAction != null)
                      _InfoRow(
                        icon: Icons.handyman_outlined, 
                        label: l10n.translate('detail_label_action'), 
                        value: service.repairAction!,
                        isMultiLine: true,
                      ),
                    if (service.notes != null)
                      _InfoRow(
                        icon: Icons.notes_rounded, 
                        label: l10n.translate('detail_label_notes'), 
                        value: service.notes!,
                        isMultiLine: true,
                      ),
                  ],
                ),
                
                // Cost Info
                _SectionCard(
                  title: l10n.translate('detail_sec_cost'),
                  icon: Icons.attach_money_rounded,
                  children: [
                    _InfoRow(
                      icon: Icons.request_quote_outlined, 
                      label: l10n.translate('detail_label_est_cost'), 
                      value: Formatters.formatCurrency(service.estimatedCost),
                    ),
                    if (service.finalCost != null)
                      _InfoRow(
                        icon: Icons.paid_outlined, 
                        label: l10n.translate('detail_label_final_cost'), 
                        value: Formatters.formatCurrency(service.finalCost!),
                        isHighlighted: true,
                      ),
                  ],
                ),
                
                // Timeline
                _SectionCard(
                  title: l10n.translate('detail_sec_timeline'),
                  icon: Icons.schedule_rounded,
                  children: [
                    _TimelineItem(
                      title: l10n.translate('detail_time_checkin'),
                      time: Formatters.formatDateTime(service.createdAt),
                      isFirst: true,
                      isCompleted: true,
                    ),
                    if (service.updatedAt != null)
                      _TimelineItem(
                        title: l10n.translate('detail_time_updated'),
                        time: Formatters.formatDateTime(service.updatedAt!),
                        isCompleted: true,
                      ),
                    if (service.completedAt != null)
                      _TimelineItem(
                        title: l10n.translate('detail_time_completed'),
                        time: Formatters.formatDateTime(service.completedAt!),
                        isLast: true,
                        isCompleted: true,
                      ),
                  ],
                ),
                
                // Warranty Info
                if (service.warranty != null && service.warranty!.isEnabled)
                  _SectionCard(
                    title: l10n.translate('detail_sec_warranty'),
                    icon: Icons.verified_user_rounded,
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_rounded, 
                        label: l10n.translate('detail_label_duration'), 
                        value: '${service.warranty!.durationDays} days',
                      ),
                      _InfoRow(
                        icon: Icons.timer_rounded, 
                        label: l10n.translate('detail_label_status'), 
                        value: service.warranty!.isActive 
                            ? '${service.warranty!.remainingDays} days remaining'
                            : l10n.translate('detail_status_expired'),
                        isHighlighted: service.warranty!.isActive,
                      ),
                    ],
                  ),
                
                const Gap(100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionSheet(context, ref, service),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        icon: const Icon(Icons.flash_on_rounded),
        label: Text(l10n.translate('detail_btn_quick_action')),
      ),
      ),
    );
  }
  
  void _showStatusSheet(BuildContext context, WidgetRef ref, Service service) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('detail_sheet_update'), style: AppTypography.headingXS),
            const Gap(16),
            ...ServiceStatus.values.map((status) {
              final isSelected = service.status == status;
              return ListTile(
                onTap: () async {
                  await ref.read(serviceProvider.notifier).updateStatus(service.id, status);
                  // Invalidate the provider to force refresh
                  ref.invalidate(serviceProvider);
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
                leading: Icon(
                  _getStatusIcon(status),
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
                title: Text(
                  _getStatusText(status, l10n),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected 
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                    : null,
              );
            }),
            const Gap(16),
          ],
        ),
      ),
    );
  }
  
  void _showActionSheet(BuildContext context, WidgetRef ref, Service service) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.translate('detail_sheet_action'), style: AppTypography.headingXS),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.call_rounded,
                  label: l10n.translate('detail_action_call'),
                  color: AppColors.success,
                  onTap: () => Navigator.pop(context),
                ),
                _ActionButton(
                  icon: Icons.message_rounded,
                  label: l10n.translate('detail_action_msg'),
                  color: AppColors.info,
                  onTap: () => Navigator.pop(context),
                ),
                _ActionButton(
                  icon: Icons.print_rounded,
                  label: l10n.translate('detail_action_print'),
                  color: AppColors.warning,
                  onTap: () => Navigator.pop(context),
                ),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: l10n.translate('detail_action_share'),
                  color: AppColors.primary,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
  
  void _showEditSheet(BuildContext context, WidgetRef ref, Service service) {
    final costValue = (service.finalCost ?? service.estimatedCost).round();
    final costController = TextEditingController(
      text: Formatters.formatNumber(costValue)
    );
    final actionController = TextEditingController(text: service.repairAction ?? '');
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('detail_sheet_edit'), style: AppTypography.headingXS),
              const Gap(20),
              TextField(
                controller: actionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.translate('detail_field_action'),
                  hintText: l10n.translate('detail_field_action_hint'),
                ),
              ),
              const Gap(16),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandSeparatorInputFormatter()],
                decoration: InputDecoration(
                  labelText: l10n.translate('detail_label_final_cost'),
                  prefixText: 'Rp ',
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updatedService = service.copyWith(
                      repairAction: actionController.text.isNotEmpty 
                          ? actionController.text 
                          : null,
                      finalCost: Formatters.parseFormattedNumber(costController.text).toDouble(),
                    );
                    ref.read(serviceProvider.notifier).updateService(updatedService);
                    Navigator.pop(context);
                  },
                  child: Text(l10n.translate('detail_btn_save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleMenuAction(BuildContext context, WidgetRef ref, Service service, String action) {
    final l10n = AppLocalizations.of(context)!;
    switch (action) {
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.translate('detail_dialog_delete_title')),
            content: Text(l10n.translate('detail_dialog_delete_content')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.translate('dialog_cancel')),
              ),
              TextButton(
                onPressed: () {
                  ref.read(serviceProvider.notifier).deleteService(service.id);
                  Navigator.pop(context);
                  context.go('/');
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(l10n.translate('detail_menu_delete')),
              ),
            ],
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action ${l10n.translate('detail_toast_coming_soon')}')),
        );
    }
  }
  
  IconData _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.checkIn:
        return Icons.login_rounded;
      case ServiceStatus.inProgress:
        return Icons.build_rounded;
      case ServiceStatus.completed:
        return Icons.done_all_rounded;
      case ServiceStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
  
  String _getStatusText(ServiceStatus status, AppLocalizations l10n) {
    switch (status) {
      case ServiceStatus.checkIn:
        return 'Masuk';
      case ServiceStatus.inProgress:
        return 'Diproses';
      case ServiceStatus.completed:
        return 'Selesai';
      case ServiceStatus.cancelled:
        return 'Batal';
    }
  }
}

/// Status Badge
class _StatusBadge extends StatelessWidget {
  final ServiceStatus status;
  
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_getStatusIcon(status), color: color, size: 24),
    );
  }
  
  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.checkIn:
        return AppColors.primary;
      case ServiceStatus.inProgress:
        return AppColors.info;
      case ServiceStatus.completed:
        return AppColors.success;
      case ServiceStatus.cancelled:
        return AppColors.error;
    }
  }
  
  IconData _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.checkIn:
        return Icons.login_rounded;
      case ServiceStatus.inProgress:
        return Icons.build_rounded;
      case ServiceStatus.completed:
        return Icons.done_all_rounded;
      case ServiceStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

/// Section Card
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final VoidCallback? onTap;
  
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: AppColors.primary),
                  ),
                  const Gap(12),
                  Text(title, style: AppTypography.labelLG),
                  const Spacer(),
                  if (onTap != null)
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

/// Info Row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMultiLine;
  final bool isHighlighted;
  
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMultiLine = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const Gap(12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTypography.bodySM.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isHighlighted
                  ? AppTypography.labelMD.copyWith(color: AppColors.primary)
                  : AppTypography.bodySM.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline Item
class _TimelineItem extends StatelessWidget {
  final String title;
  final String time;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  
  const _TimelineItem({
    required this.title,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: AppColors.surfaceVariant,
              ),
          ],
        ),
        const Gap(16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMD.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                Text(
                  time,
                  style: AppTypography.bodyXS.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Action Button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(8),
          Text(label, style: AppTypography.bodyXS.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
