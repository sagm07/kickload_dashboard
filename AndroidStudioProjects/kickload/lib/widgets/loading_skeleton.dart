import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bone(double width, double height, {double radius = 8}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardBorder.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width - 32;
    final cardW = (w - 12) / 2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _bone(180, 22),
          const SizedBox(height: 6),
          _bone(120, 14),
          const SizedBox(height: 20),

          // Status banner
          _bone(double.infinity, 44, radius: 10),
          const SizedBox(height: 24),

          // 2x2 stats cards
          Row(children: [
            _bone(cardW, 100, radius: 14),
            const SizedBox(width: 12),
            _bone(cardW, 100, radius: 14),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _bone(cardW, 100, radius: 14),
            const SizedBox(width: 12),
            _bone(cardW, 100, radius: 14),
          ]),
          const SizedBox(height: 20),

          // CTA
          _bone(double.infinity, 54, radius: 12),
          const SizedBox(height: 20),

          // Charts
          _bone(double.infinity, 180, radius: 14),
          const SizedBox(height: 12),
          _bone(double.infinity, 150, radius: 14),
          const SizedBox(height: 24),

          // List
          _bone(100, 18),
          const SizedBox(height: 12),
          for (int i = 0; i < 3; i++) ...[
            _bone(double.infinity, 68, radius: 12),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
