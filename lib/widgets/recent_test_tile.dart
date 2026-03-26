import 'package:flutter/material.dart';
import '../models/test_run.dart';
import '../theme/app_theme.dart';

class RecentTestTile extends StatelessWidget {
  final TestRun run;

  const RecentTestTile({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final statusConfig = _statusConfig(run.status);
    final timeAgo = _timeAgo(run.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusConfig.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusConfig.icon, color: statusConfig.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  run.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  run.endpoint,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusConfig.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusConfig.label,
                  style: TextStyle(
                    color: statusConfig.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _TileConfig _statusConfig(TestStatus s) {
    switch (s) {
      case TestStatus.completed:
        return _TileConfig(AppColors.green, 'COMPLETED', Icons.check_circle_outline_rounded);
      case TestStatus.running:
        return _TileConfig(AppColors.blue, 'RUNNING', Icons.play_circle_outline_rounded);
      case TestStatus.failed:
        return _TileConfig(AppColors.danger, 'FAILED', Icons.error_outline_rounded);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _TileConfig {
  final Color color;
  final String label;
  final IconData icon;
  const _TileConfig(this.color, this.label, this.icon);
}

/// Empty state shown when no runs exist
class EmptyTestsState extends StatelessWidget {
  const EmptyTestsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Column(
        children: [
          Text('🚀', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'No tests yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Create your first load test to get started',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
