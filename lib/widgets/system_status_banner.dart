import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SystemStatus { stable, highLoad, errorsDetected }

class SystemStatusBanner extends StatelessWidget {
  final SystemStatus status;

  const SystemStatusBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: config.color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: config.color),
          const SizedBox(width: 10),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(SystemStatus s) {
    switch (s) {
      case SystemStatus.stable:
        return _StatusConfig(AppColors.green, 'System Stable', '· All systems operational');
      case SystemStatus.highLoad:
        return _StatusConfig(AppColors.warning, 'High Load', '· Degraded performance');
      case SystemStatus.errorsDetected:
        return _StatusConfig(AppColors.danger, 'Errors Detected', '· Immediate attention needed');
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  final String subtitle;
  const _StatusConfig(this.color, this.label, this.subtitle);
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_anim.value),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.4 * _anim.value),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
