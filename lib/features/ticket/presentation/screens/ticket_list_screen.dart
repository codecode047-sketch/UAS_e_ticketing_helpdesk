import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/ticket_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/ticket_provider.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  static const _filters = [
    'Semua',
    'Open',
    'In Progress',
    'Closed',
    'Cancelled',
  ];

  String? _selectedAssignee;
  String _sortBy = 'Terbaru';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(ticketProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = ref.watch(roleProvider);
    final isStaff = role == 'admin' || role == 'helpdesk';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        actions: [
          Semantics(
            label: 'Filter dan urutkan',
            child: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => _showFilterOptions(),
              tooltip: 'Filter dan urutkan',
            ),
          ),
          if (isStaff)
            IconButton(
              icon: const Icon(Icons.dashboard),
              onPressed: () => context.push(AppRouter.adminDashboard),
              tooltip: 'Admin Dashboard',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.sm, AppSizes.md, 0,
            ),
            child: Semantics(
              label: 'Cari tiket',
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari tiket...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(ticketProvider.notifier).search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2A2A3E)
                      : AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isActive = state.selectedFilter == filter;
                return Semantics(
                  label: 'Filter $filter',
                  child: FilterChip(
                    label: Text(filter),
                    selected: isActive,
                    onSelected: (_) {
                      ref.read(ticketProvider.notifier).filterByStatus(filter);
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontSize: AppSizes.fontSm,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: isActive
                        ? BorderSide.none
                        : BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isStaff) ...[
            const SizedBox(height: AppSizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                children: [
                  Expanded(
                    child: _buildAssigneeDropdown(isDark),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _buildSortDropdown(isDark),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: state.isLoading
                  ? const TicketCardShimmer()
                  : state.filteredTickets.isEmpty
                      ? EmptyState(
                          key: const ValueKey('empty'),
                          title: 'Tidak ada tiket',
                          subtitle: state.searchQuery.isNotEmpty
                              ? 'Tidak ada hasil untuk "${state.searchQuery}"'
                              : 'Belum ada tiket yang masuk',
                        )
                      : LayoutBuilder(
                          key: ValueKey(state.filteredTickets.length),
                          builder: (context, constraints) {
                            final isTablet = constraints.maxWidth >= 768;
                            return RefreshIndicator(
                              onRefresh: () async {
                                ref.read(ticketProvider.notifier).loadTickets();
                              },
                              child: isTablet
                                  ? GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.md,
                                      ),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.8,
                                        crossAxisSpacing: AppSizes.sm,
                                        mainAxisSpacing: AppSizes.sm,
                                      ),
                                      itemCount: state.filteredTickets.length,
                                      itemBuilder: (context, index) {
                                        final ticket = state.filteredTickets[index];
                                        return TicketCard(
                                          ticketId: ticket.ticketNumber,
                                          title: ticket.title,
                                          status: ticket.status.label,
                                          priority: ticket.priority.label,
                                          createdAt: ticket.createdAt,
                                          assignedTo: isStaff ? ticket.assignedTo : null,
                                          onTap: () {
                                            context.push(
                                              '${AppRouter.tickets}/${ticket.id}',
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.md,
                                      ),
                                      itemCount: state.filteredTickets.length,
                                      itemBuilder: (context, index) {
                                        final ticket = state.filteredTickets[index];
                                        return TicketCard(
                                          ticketId: ticket.ticketNumber,
                                          title: ticket.title,
                                          status: ticket.status.label,
                                          priority: ticket.priority.label,
                                          createdAt: ticket.createdAt,
                                          assignedTo: isStaff ? ticket.assignedTo : null,
                                          onTap: () {
                                            context.push(
                                              '${AppRouter.tickets}/${ticket.id}',
                                            );
                                          },
                                        );
                                      },
                                    ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: 'Buat tiket baru',
        child: FloatingActionButton(
          onPressed: () => context.push(AppRouter.ticketCreate),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter & Urutkan',
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'Urutkan',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                _buildSortDropdown(isDark),
                const SizedBox(height: AppSizes.md),
                Text(
                  'Filter Prioritas',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  children: ['Semua', 'Low', 'Medium', 'High', 'Critical']
                      .map((p) => FilterChip(
                            label: Text(p),
                            selected: p == 'Semua',
                            onSelected: (_) {},
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSizes.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssigneeDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedAssignee,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A3E) : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(
        'Helpdesk',
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          color: isDark ? Colors.grey : AppColors.textHint,
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Semua Helpdesk')),
        DropdownMenuItem(value: 'Budi Santoso', child: Text('Budi Santoso')),
        DropdownMenuItem(value: 'Dewi Lestari', child: Text('Dewi Lestari')),
        DropdownMenuItem(value: 'Ahmad Fauzi', child: Text('Ahmad Fauzi')),
      ],
      onChanged: (value) {
        setState(() => _selectedAssignee = value);
        ref.read(ticketProvider.notifier).filterByAssignee(value ?? '');
      },
    );
  }

  Widget _buildSortDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _sortBy,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A3E) : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(
        'Urutkan',
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          color: isDark ? Colors.grey : AppColors.textHint,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Terbaru', child: Text('Terbaru')),
        DropdownMenuItem(value: 'Terlama', child: Text('Terlama')),
        DropdownMenuItem(value: 'Prioritas Tinggi', child: Text('Prioritas')),
        DropdownMenuItem(value: 'SLA Deadline', child: Text('SLA Deadline')),
      ],
      onChanged: (value) {
        setState(() => _sortBy = value!);
      },
    );
  }
}
