import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/service_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/service.dart';
import '../../core/l10n/app_localizations.dart';

/// HomeScreen - Dashboard utama teknisi
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(serviceProvider);
    final todayServices = ref.watch(todayServicesProvider);
    final activeCount = ref.watch(activeCountProvider);
    final overdueCount = ref.watch(overdueCountProvider);
    final settingsState = ref.watch(settingsProvider);
    
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(serviceProvider);
            ref.invalidate(settingsProvider);
            // Small delay for better UX
            await Future.delayed(const Duration(milliseconds: 800));
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
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
                                size: 28,
                              )
                            : null,
                      ),
                      const Gap(12),
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.translate('home_role_technician'),
                              style: AppTypography.overline.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${_getGreeting(context)}, ${settingsState.technicianName}',
                              style: AppTypography.headingXS.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined, size: 28),
                            if (overdueCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      overdueCount > 9 ? '9+' : '$overdueCount',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Stats Cards
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _StatCard(
                        icon: Icons.build_rounded,
                        label: l10n.translate('home_stat_today'),
                        value: '${todayServices.length}',
                        trend: '+20%',
                        color: AppColors.primary,
                      ),
                      const Gap(12),
                      _StatCard(
                        icon: Icons.pending_actions_rounded,
                        label: l10n.translate('home_stat_active'),
                        value: '$activeCount',
                        color: AppColors.warning,
                      ),
                      const Gap(12),
                      _StatCard(
                        icon: Icons.attach_money_rounded,
                        label: l10n.translate('home_stat_revenue'),
                        value: Formatters.formatCurrency(
                          ref.watch(serviceProvider.notifier).totalRevenue,
                        ),
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: Gap(24)),
              
              // Quick Actions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.translate('home_sec_quick'), style: AppTypography.headingXS.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          l10n.translate('home_btn_edit_shortcut'),
                          style: AppTypography.labelMD.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Add New Service Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => context.push('/service/add'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.translate('home_btn_add_service'),
                                  style: AppTypography.headingXS.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  l10n.translate('home_desc_add_service'),
                                  style: AppTypography.bodySM.copyWith(
                                    color: AppColors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppColors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: Gap(16)),
              
              // Quick Action Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.history_rounded,
                          label: l10n.translate('home_quick_history'),
                          subtitle: l10n.translate('home_quick_history_desc'),
                          onTap: () => context.go('/history'),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.people_rounded,
                          label: l10n.translate('home_quick_customers'),
                          subtitle: l10n.translate('home_quick_customers_desc'),
                          onTap: () => context.go('/service'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: Gap(12)),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.inventory_2_rounded,
                          label: l10n.translate('home_quick_inventory'),
                          subtitle: l10n.translate('home_quick_inventory_desc'),
                          onTap: () => context.go('/inventory'),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.analytics_rounded,
                          label: l10n.translate('home_quick_stats'),
                          subtitle: l10n.translate('home_quick_stats_desc'),
                          onTap: () => context.push('/stats/weekly'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: Gap(24)),
              
              // Recent Activity Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.translate('home_sec_recent'), style: AppTypography.headingXS.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                      TextButton(
                        onPressed: () {
                          // Use pushReplacement to ensure navigation works even when already on MainScreen
                          context.pushReplacement('/service');
                        },
                        child: Text(
                          l10n.translate('home_btn_see_all'),
                          style: AppTypography.labelMD.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Recent Activity List
              if (services.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const Gap(12),
                          Text(
                            l10n.translate('home_empty_activity'),
                            style: AppTypography.bodyMD.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            l10n.translate('home_empty_activity_desc'),
                            style: AppTypography.bodySM.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= 5) return null;
                      final service = services[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: _ActivityCard(service: service),
                      );
                    },
                    childCount: services.length > 5 ? 5 : services.length,
                  ),
                ),
              
              const SliverToBoxAdapter(child: Gap(100)),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.translate('home_greeting_morning');
    if (hour < 17) return l10n.translate('home_greeting_afternoon');
    return l10n.translate('home_greeting_evening');
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final Color color;
  
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              if (trend != null) ...[
                const Spacer(),
                Text(
                  trend!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.headingXS.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTypography.bodyXS.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final int? badge;
  final VoidCallback onTap;
  
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                if (badge != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Gap(12),
            Text(label, style: AppTypography.labelLG),
            Text(
              subtitle,
              style: AppTypography.bodyXS.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity Card Widget
class _ActivityCard extends StatelessWidget {
  final Service service;
  
  const _ActivityCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/service/${service.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Device Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const Gap(12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.deviceFullName,
                    style: AppTypography.labelLG,
                  ),
                  Text(
                    '${service.problemDescription} • ${service.customerName}',
                    style: AppTypography.bodyXS.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Gap(12),
            // Status & Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: service.status),
                const Gap(4),
                Text(
                  Formatters.formatRelativeTime(service.createdAt, l10n: AppLocalizations.of(context)),
                  style: AppTypography.bodyXS.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
