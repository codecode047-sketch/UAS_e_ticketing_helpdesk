import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/ticket_card.dart';

import '../providers/bottom_nav_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 0,
            title: Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push(AppRouter.notifications),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.fontXs,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.sm),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.secondary,
                  child: Text(
                    MockData.userName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.fontMd,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.lg,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, ${MockData.userName.split(' ')[0]}!',
                    style: TextStyle(
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(
                      DateTime.now(),
                    ),
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSizes.sm,
                crossAxisSpacing: AppSizes.sm,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    icon: Icons.confirmation_number_rounded,
                    value: MockData.stats['total']!,
                    label: 'Total Tiket',
                    accentColor: AppColors.info,
                  ),
                  StatCard(
                    icon: Icons.radio_button_unchecked,
                    value: MockData.stats['open']!,
                    label: 'Tiket Open',
                    accentColor: AppColors.warning,
                  ),
                  StatCard(
                    icon: Icons.autorenew,
                    value: MockData.stats['inProgress']!,
                    label: 'In Progress',
                    accentColor: AppColors.secondary,
                  ),
                  StatCard(
                    icon: Icons.check_circle_outline,
                    value: MockData.stats['closed']!,
                    label: 'Tiket Closed',
                    accentColor: AppColors.success,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.lg,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Text(
                'Statistik Mingguan',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SizedBox(
                height: size.height * 0.25,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 12,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY} tiket',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final days = MockData.chartData.keys.toList();
                            final index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  days[index],
                                  style: TextStyle(
                                    fontSize: AppSizes.fontSm,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
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
                              style: TextStyle(
                                fontSize: AppSizes.fontSm,
                                color: AppColors.textSecondary,
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
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.border.withOpacity(0.5),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    barGroups: MockData.chartData.entries.map(
                      (entry) {
                        final index = MockData.chartData.keys.toList().indexOf(
                          entry.key,
                        );
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: AppColors.primary,
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.lg,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiket Terbaru',
                    style: TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRouter.tickets),
                    child: const Text('Lihat Semua'),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRouter.ticketHistory),
                    child: const Text('Riwayat'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                children: MockData.recentTickets.map(
                  (ticket) => TicketCard(
                    ticketId: ticket.id,
                    title: ticket.title,
                    status: ticket.status,
                    priority: ticket.priority,
                    createdAt: ticket.createdAt,
                    onTap: () => context.push(
                      '${AppRouter.tickets}/${ticket.id}',
                    ),
                  ),
                ).toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: size.height * 0.1),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          switch (index) {
            case 0:
              break;
            case 1:
              context.push(AppRouter.tickets);
              break;
            case 2:
              context.push(AppRouter.notifications);
              break;
            case 3:
              context.push(AppRouter.profile);
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(
            icon: _buildNotifBadge(
              ref.watch(unreadCountProvider),
              Icons.notifications_outlined,
            ),
            activeIcon: _buildNotifBadge(
              ref.watch(unreadCountProvider),
              Icons.notifications,
            ),
            label: 'Notifikasi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildNotifBadge(int count, IconData icon) {
    if (count > 0) {
      return Badge(
        label: Text('$count'),
        child: Icon(icon),
      );
    }
    return Icon(icon);
  }
}
