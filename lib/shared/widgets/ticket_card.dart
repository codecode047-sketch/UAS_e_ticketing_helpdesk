import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class TicketCard extends StatelessWidget {
  final String ticketId;
  final String title;
  final String status;
  final String priority;
  final String createdAt;
  final String? assignedTo;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.ticketId,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.assignedTo,
    this.onTap,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.warning;
      case 'in progress':
        return AppColors.info;
      case 'closed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  Color _priorityColor() {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.error;
      case 'critical':
        return Colors.red;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Tiket $ticketId: $title, Status: $status, Prioritas: $priority',
      button: true,
      child: Hero(
        tag: 'ticket-$ticketId',
        child: Card(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  Semantics(
                    label: 'Status $status',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _statusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        color: _statusColor(),
                        size: AppSizes.iconMd,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticketId,
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: AppSizes.fontXs,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              createdAt,
                              style: TextStyle(
                                fontSize: AppSizes.fontXs,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                        if (assignedTo != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: AppSizes.fontXs,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                assignedTo!,
                                style: const TextStyle(
                                  fontSize: AppSizes.fontXs,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor().withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusXs),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            color: _statusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _priorityColor().withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusXs),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            fontSize: AppSizes.fontXs,
                            color: _priorityColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
