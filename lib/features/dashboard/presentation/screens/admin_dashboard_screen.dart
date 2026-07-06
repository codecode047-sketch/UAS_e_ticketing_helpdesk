import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../ticket/domain/models/ticket_model.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticketProvider).tickets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryChart(context, tickets),
            const SizedBox(height: AppSizes.md),
            _buildHelpdeskStats(context, tickets),
            const SizedBox(height: AppSizes.md),
            _buildAvgResolution(context),
            const SizedBox(height: AppSizes.md),
            _buildSlaTable(context, tickets),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, List<Ticket> tickets) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final surfaceColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    final categoryCounts = _categoryCounts(tickets);
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];

    return Card(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A3E) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiket per Kategori',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _maxCount(categoryCounts.values.toList()) * 1.3,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= categoryCounts.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              categoryCounts.keys.elementAt(idx),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textHint,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textHint,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark
                          ? const Color(0xFF2A2A3E)
                          : AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: categoryCounts.entries.toList().asMap().entries.map(
                    (entry) {
                      final idx = entry.key;
                      final count = entry.value.value;
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: count.toDouble(),
                            color: colors[idx % colors.length],
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpdeskStats(BuildContext context, List<Ticket> tickets) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final surfaceColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    final helpdeskCounts = _helpdeskCounts(tickets);

    return Card(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A3E) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiket per Helpdesk',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            ...helpdeskCounts.entries.map((entry) {
              final total = entry.value;
              final maxVal = helpdeskCounts.values
                  .fold<int>(0, (a, b) => a > b ? a : b);
              final ratio = maxVal > 0 ? total / maxVal : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '$total tiket',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor:
                            AppColors.primary.withOpacity(0.15),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAvgResolution(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.grey : AppColors.textSecondary;
    final surfaceColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    return Card(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A3E) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.access_time,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rata-rata Resolusi',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
                Text(
                  '12 Jam 30 Menit',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlaTable(BuildContext context, List<Ticket> tickets) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.grey : AppColors.textSecondary;
    final surfaceColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    final slaBreached = _slaBreachedTickets(tickets);

    return Card(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2A2A3E) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  'SLA Terlambat',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${slaBreached.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            if (slaBreached.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Tidak ada tiket yang melanggar SLA',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ),
              )
            else
              ...slaBreached.map((t) {
                final dayDiff = _daysSince(t.createdAt);
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.sm),
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.ticketNumber,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t.category.label}  |  $dayDiff hari',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${dayDiff}h',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Map<String, int> _categoryCounts(List<Ticket> tickets) {
    final counts = <String, int>{};
    for (final t in tickets) {
      final label = t.category.label;
      counts[label] = (counts[label] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      return {'Hardware': 0, 'Software': 0, 'Jaringan': 0, 'Akun': 0, 'Lainnya': 0};
    }
    return counts;
  }

  Map<String, int> _helpdeskCounts(List<Ticket> tickets) {
    final counts = <String, int>{};
    for (final t in tickets) {
      if (t.assignedTo.isNotEmpty) {
        counts[t.assignedTo] = (counts[t.assignedTo] ?? 0) + 1;
      } else {
        counts['Belum ditugaskan'] = (counts['Belum ditugaskan'] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) {
      return {'Budi Santoso': 0, 'Dewi Lestari': 0, 'Ahmad Fauzi': 0};
    }
    return counts;
  }

  double _maxCount(List<int> values) {
    if (values.isEmpty) return 5;
    return values.reduce((a, b) => a > b ? a : b).toDouble();
  }

  List<Ticket> _slaBreachedTickets(List<Ticket> tickets) {
    final result = <Ticket>[];
    for (final ticket in tickets) {
      if (ticket.status.label != 'Closed' &&
          ticket.status.label != 'Resolved' &&
          _daysSince(ticket.createdAt) > 3) {
        result.add(ticket);
      }
    }
    return result;
  }

  int _daysSince(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateTime.now().difference(dt).inDays;
    } catch (_) {
      return 0;
    }
  }
}
