import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/notification_provider.dart';
import '../../data/models/service.dart';

/// NotificationsScreen - Menampilkan notifikasi service overdue
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueServices = ref.watch(overdueServicesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: overdueServices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const Gap(16),
                  Text(
                    'Tidak ada notifikasi',
                    style: AppTypography.headingXS.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Semua service berjalan lancar!',
                    style: AppTypography.bodyMD.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: overdueServices.length,
              itemBuilder: (context, index) {
                final service = overdueServices[index];
                return _NotificationCard(
                  service: service,
                  onTap: () => context.push('/service/${service.id}'),
                );
              },
            ),
    );
  }
}

/// Notification Card Widget
class _NotificationCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;
  
  const _NotificationCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final overdueDuration = getOverdueDuration(service.createdAt);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.timer_off_rounded,
                color: AppColors.warning,
                size: 24,
              ),
            ),
            const Gap(12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Tertunda',
                    style: AppTypography.labelLG.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${service.customerName} - ${service.deviceFullName}',
                    style: AppTypography.labelMD,
                  ),
                  const Gap(4),
                  Text(
                    service.problemDescription,
                    style: AppTypography.bodySM.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const Gap(4),
                      Text(
                        'Sudah $overdueDuration belum selesai',
                        style: AppTypography.bodyXS.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
