import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/customer_provider.dart';
import '../../providers/service_provider.dart';
import '../../data/models/customer.dart';
import '../../data/models/service.dart';

/// CustomerProfileScreen - Profil Customer dengan Service History
class CustomerProfileScreen extends ConsumerWidget {
  final String customerId;
  
  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(singleCustomerProvider(customerId));
    final allServices = ref.watch(serviceProvider);
    
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Profile')),
        body: const Center(child: Text('Customer not found')),
      );
    }
    
    // Filter services for this customer
    final customerServices = allServices.where((s) => s.customerId == customerId).toList();
    final totalSpent = customerServices.fold<double>(
      0, (sum, s) => sum + (s.finalCost ?? s.estimatedCost),
    );
    
    return BackButtonListener(
      onBackButtonPressed: () async {
        context.go('/');
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // App Bar with Profile Header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                onPressed: () => context.go('/'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.white),
                onPressed: () => _showEditSheet(context, ref, customer),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.white),
                onSelected: (value) => _handleMenuAction(context, ref, customer, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'loyal',
                    child: Text(customer.isLoyal ? 'Remove Loyal Status' : 'Mark as Loyal'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(40),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            customer.initials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),
                      // Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            customer.name,
                            style: AppTypography.headingXS.copyWith(color: AppColors.white),
                          ),
                          if (customer.isLoyal) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 14, color: AppColors.white),
                                  Gap(4),
                                  Text(
                                    'LOYAL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Gap(4),
                      Text(
                        'Customer since ${Formatters.formatDateShort(customer.createdAt)}',
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
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.build_rounded,
                          label: 'Total Services',
                          value: '${customerServices.length}',
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.attach_money_rounded,
                          label: 'Total Spent',
                          value: Formatters.formatCurrency(totalSpent),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contact Info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
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
                      _ContactRow(
                        icon: Icons.phone_rounded,
                        label: 'Phone',
                        value: customer.phoneNumber,
                        onTap: () {},
                      ),
                      if (customer.hasEmail) ...[
                        const Divider(),
                        _ContactRow(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: customer.email!,
                          onTap: () {},
                        ),
                      ],
                      if (customer.hasAddress) ...[
                        const Divider(),
                        _ContactRow(
                          icon: Icons.location_on_rounded,
                          label: 'Address',
                          value: customer.address!,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const Gap(24),
                
                // Service History Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service History', style: AppTypography.headingXS),
                      Text(
                        '${customerServices.length} services',
                        style: AppTypography.bodySM.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                
                // Service History List
                if (customerServices.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.build_circle_outlined,
                            size: 64,
                            color: AppColors.textTertiary.withOpacity(0.5),
                          ),
                          const Gap(16),
                          Text(
                            'No services yet',
                            style: AppTypography.bodyMD.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: customerServices.length,
                    itemBuilder: (context, index) {
                      final service = customerServices[index];
                      return _ServiceHistoryCard(
                        service: service,
                        onTap: () => context.push('/service/${service.id}'),
                      );
                    },
                  ),
                
                const Gap(100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/service/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: const Text('New Service', style: TextStyle(color: AppColors.white)),
      ),
      ),
    );
  }
  
  void _showEditSheet(BuildContext context, WidgetRef ref, Customer customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phoneNumber);
    final emailController = TextEditingController(text: customer.email ?? '');
    final addressController = TextEditingController(text: customer.address ?? '');
    
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
              Text('Edit Customer', style: AppTypography.headingXS),
              const Gap(20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const Gap(16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const Gap(16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email (optional)'),
              ),
              const Gap(16),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updatedCustomer = customer.copyWith(
                      name: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      email: emailController.text.isNotEmpty ? emailController.text.trim() : null,
                      address: addressController.text.isNotEmpty ? addressController.text.trim() : null,
                    );
                    ref.read(customerProvider.notifier).updateCustomer(updatedCustomer);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleMenuAction(BuildContext context, WidgetRef ref, Customer customer, String action) {
    switch (action) {
      case 'loyal':
        ref.read(customerProvider.notifier).toggleLoyalStatus(customer.id);
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Customer?'),
            content: const Text('This will not delete associated services.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(customerProvider.notifier).deleteCustomer(customer.id);
                  Navigator.pop(context);
                  context.go('/');
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
}

/// Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.labelLG.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Contact Row
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
                  ),
                  Text(value, style: AppTypography.labelMD),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Service History Card
class _ServiceHistoryCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;
  
  const _ServiceHistoryCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                color: AppColors.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.deviceFullName, style: AppTypography.labelMD),
                  Text(
                    service.problemDescription,
                    style: AppTypography.bodyXS.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusChip(status: service.status),
                const Gap(4),
                Text(
                  Formatters.formatDateShort(service.createdAt),
                  style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Status Chip
class _StatusChip extends StatelessWidget {
  final ServiceStatus status;
  
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
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
  
  String _getStatusText(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.checkIn:
        return 'MASUK';
      case ServiceStatus.inProgress:
        return 'DIPROSES';
      case ServiceStatus.completed:
        return 'SELESAI';
      case ServiceStatus.cancelled:
        return 'BATAL';
    }
  }
}
