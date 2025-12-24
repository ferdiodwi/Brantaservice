import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/service_provider.dart';
import '../../data/models/service.dart';
import '../../core/l10n/app_localizations.dart';

/// WeeklyOverviewScreen - Dashboard Statistik Mingguan
class WeeklyOverviewScreen extends ConsumerWidget {
  const WeeklyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(serviceProvider);
    final weeklyData = _calculateWeeklyData(services);
    final l10n = AppLocalizations.of(context)!;
    
    return BackButtonListener(
      onBackButtonPressed: () async {
        context.go('/');
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.translate('stats_title')),
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today_rounded),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.build_rounded,
                      label: l10n.translate('stats_services'),
                      value: '${weeklyData.totalServices}',
                      trend: weeklyData.servicesTrend,
                      color: AppColors.primary,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.attach_money_rounded,
                      label: l10n.translate('stats_revenue'),
                      value: Formatters.formatCurrency(weeklyData.totalRevenue),
                      trend: weeklyData.revenueTrend,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.check_circle_rounded,
                      label: l10n.translate('stats_completed'),
                      value: '${weeklyData.completedServices}',
                      color: AppColors.success,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.timer_rounded,
                      label: l10n.translate('stats_avg_time'),
                      value: '${weeklyData.avgRepairTime}h',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
            
            const Gap(24),
            
            // Daily Services Chart
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('stats_daily_title'), style: AppTypography.labelLG),
                  const Gap(4),
                  Text(
                    l10n.translate('stats_daily_desc'),
                    style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
                  ),
                  const Gap(24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (weeklyData.dailyServices.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: AppColors.primary,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = [
                                  l10n.translate('stats_day_mon'),
                                  l10n.translate('stats_day_tue'),
                                  l10n.translate('stats_day_wed'),
                                  l10n.translate('stats_day_thu'),
                                  l10n.translate('stats_day_fri'),
                                  l10n.translate('stats_day_sat'),
                                  l10n.translate('stats_day_sun'),
                                ];
                                return Text(
                                  days[value.toInt()],
                                  style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: List.generate(7, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: weeklyData.dailyServices[index].toDouble(),
                                color: AppColors.primary,
                                width: 24,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Gap(20),
            
            // Status Distribution
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('stats_status_title'), style: AppTypography.labelLG),
                  const Gap(4),
                  Text(
                    l10n.translate('stats_status_desc'),
                    style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                            sections: _buildPieSections(weeklyData.statusDistribution),
                          ),
                        ),
                      ),
                      const Gap(24),
                      Expanded(
                        child: Column(
                          children: [
                            _LegendItem(
                              color: AppColors.primary,
                              label: 'Masuk',
                              value: weeklyData.statusDistribution[ServiceStatus.checkIn] ?? 0,
                            ),
                            _LegendItem(
                              color: AppColors.info,
                              label: 'Diproses',
                              value: weeklyData.statusDistribution[ServiceStatus.inProgress] ?? 0,
                            ),
                            _LegendItem(
                              color: AppColors.success,
                              label: 'Selesai',
                              value: weeklyData.statusDistribution[ServiceStatus.completed] ?? 0,
                            ),
                            _LegendItem(
                              color: AppColors.error,
                              label: 'Batal',
                              value: weeklyData.statusDistribution[ServiceStatus.cancelled] ?? 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Gap(20),
            
            // Top Brands
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.translate('stats_brands_title'), style: AppTypography.labelLG),
                  const Gap(4),
                  Text(
                    l10n.translate('stats_brands_desc'),
                    style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
                  ),
                  const Gap(16),
                  ...weeklyData.topBrands.take(5).map((brand) => _BrandRow(
                    brand: brand.name,
                    count: brand.count,
                    percentage: brand.percentage,
                  )),
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
  
  List<PieChartSectionData> _buildPieSections(Map<ServiceStatus, int> distribution) {
    final total = distribution.values.fold<int>(0, (sum, v) => sum + v);
    if (total == 0) {
      return [
        PieChartSectionData(
          color: AppColors.surfaceVariant,
          value: 1,
          title: '',
          radius: 25,
        ),
      ];
    }
    
    final colorMap = {
      ServiceStatus.checkIn: AppColors.primary,
      ServiceStatus.inProgress: AppColors.info,
      ServiceStatus.completed: AppColors.success,
      ServiceStatus.cancelled: AppColors.error,
    };
    
    return distribution.entries
        .where((e) => e.value > 0)
        .map((entry) => PieChartSectionData(
              color: colorMap[entry.key] ?? AppColors.textTertiary,
              value: entry.value.toDouble(),
              title: '',
              radius: 25,
            ))
        .toList();
  }
  
  _WeeklyData _calculateWeeklyData(List<Service> services) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    // Filter this week's services
    final weeklyServices = services.where((s) => s.createdAt.isAfter(startOfWeek)).toList();
    
    // Daily services count
    final dailyServices = List<int>.filled(7, 0);
    for (final service in weeklyServices) {
      final dayIndex = service.createdAt.weekday - 1;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyServices[dayIndex]++;
      }
    }
    
    // Status distribution
    final statusDistribution = <ServiceStatus, int>{};
    for (final status in ServiceStatus.values) {
      statusDistribution[status] = services.where((s) => s.status == status).length;
    }
    
    // Completed services
    final completedServices = weeklyServices.where((s) => s.status == ServiceStatus.completed).toList();
    
    // Total revenue
    final totalRevenue = completedServices.fold<double>(
      0, (sum, s) => sum + (s.finalCost ?? s.estimatedCost),
    );
    
    // Top brands
    final brandCounts = <String, int>{};
    for (final service in services) {
      brandCounts[service.deviceBrand] = (brandCounts[service.deviceBrand] ?? 0) + 1;
    }
    final totalBrands = brandCounts.values.fold<int>(0, (sum, v) => sum + v);
    final topBrands = brandCounts.entries
        .map((e) => _BrandData(
              name: e.key,
              count: e.value,
              percentage: totalBrands > 0 ? (e.value / totalBrands * 100).round() : 0,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    
    return _WeeklyData(
      totalServices: weeklyServices.length,
      completedServices: completedServices.length,
      totalRevenue: totalRevenue,
      avgRepairTime: 24, // Placeholder for now
      dailyServices: dailyServices,
      statusDistribution: statusDistribution,
      topBrands: topBrands,
      servicesTrend: '+12%',
      revenueTrend: '+8%',
    );
  }
}

class _WeeklyData {
  final int totalServices;
  final int completedServices;
  final double totalRevenue;
  final int avgRepairTime;
  final List<int> dailyServices;
  final Map<ServiceStatus, int> statusDistribution;
  final List<_BrandData> topBrands;
  final String servicesTrend;
  final String revenueTrend;
  
  _WeeklyData({
    required this.totalServices,
    required this.completedServices,
    required this.totalRevenue,
    required this.avgRepairTime,
    required this.dailyServices,
    required this.statusDistribution,
    required this.topBrands,
    required this.servicesTrend,
    required this.revenueTrend,
  });
}

class _BrandData {
  final String name;
  final int count;
  final int percentage;
  
  _BrandData({required this.name, required this.count, required this.percentage});
}

/// Summary Card
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final Color color;
  
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              if (trend != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Gap(12),
          Text(
            value,
            style: AppTypography.headingXS.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: AppTypography.bodyXS.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Legend Item
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const Gap(8),
          Expanded(child: Text(label, style: AppTypography.bodySM)),
          Text(
            '$value',
            style: AppTypography.labelMD.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Brand Row
class _BrandRow extends StatelessWidget {
  final String brand;
  final int count;
  final int percentage;
  
  const _BrandRow({
    required this.brand,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(brand, style: AppTypography.labelMD),
              Text(
                '$count ($percentage%)',
                style: AppTypography.bodySM.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Gap(6),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
