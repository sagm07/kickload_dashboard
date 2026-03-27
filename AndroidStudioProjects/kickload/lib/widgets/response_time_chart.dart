import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ResponseTimeChart extends StatelessWidget {
  static const List<double> _dataPoints = [
    310, 285, 340, 290, 370, 320, 410, 355, 330, 320,
  ];

  const ResponseTimeChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Response Time',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last 10 minutes',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'avg 320ms',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 156,
            child: CustomPaint(
              painter: _ResponseTimePainter(points: _dataPoints),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AxisLabel('10m'),
              _AxisLabel('8m'),
              _AxisLabel('6m'),
              _AxisLabel('4m'),
              _AxisLabel('2m'),
              _AxisLabel('now'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String label;
  const _AxisLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 9,
      ),
    );
  }
}

class _ResponseTimePainter extends CustomPainter {
  final List<double> points;

  const _ResponseTimePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.blue.withOpacity(0.24),
          AppColors.blue.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final gridPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const leftPad = 10.0;
    const topPad = 8.0;
    const rightPad = 6.0;
    const bottomPad = 18.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    final minY = 200.0;
    final maxY = 480.0;
    final stepX = chartWidth / (points.length - 1);

    for (int i = 0; i < 3; i++) {
      final y = topPad + (chartHeight / 2) * i;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y),
          gridPaint..strokeWidth = i == 1 ? 1.2 : 1);
    }

    double toY(double value) {
      final t = ((value - minY) / (maxY - minY)).clamp(0.0, 1.0);
      return topPad + chartHeight - (t * chartHeight);
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = leftPad + stepX * i;
      final y = toY(points[i]);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight + topPad);
        fillPath.lineTo(x, y);
      } else {
        final prevX = leftPad + stepX * (i - 1);
        final prevY = toY(points[i - 1]);
        final c1 = Offset(prevX + (stepX * 0.35), prevY);
        final c2 = Offset(x - (stepX * 0.35), y);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, x, y);
        fillPath.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, x, y);
      }
    }

    fillPath
      ..lineTo(leftPad + stepX * (points.length - 1), chartHeight + topPad)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    for (int i = 0; i < points.length; i++) {
      final x = leftPad + stepX * i;
      final y = toY(points[i]);
      canvas.drawCircle(
        Offset(x, y),
        3.2,
        Paint()..color = AppColors.blue,
      );
      canvas.drawCircle(
        Offset(x, y),
        1.4,
        Paint()..color = AppColors.card,
      );
    }

    final labels = [480.0, 380.0, 280.0];
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    for (final label in labels) {
      textPainter.text = TextSpan(
        text: label.toInt().toString(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 9,
        ),
      );
      textPainter.layout();
      final y = toY(label) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(0, math.max(0, y)));
    }
  }

  @override
  bool shouldRepaint(covariant _ResponseTimePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
