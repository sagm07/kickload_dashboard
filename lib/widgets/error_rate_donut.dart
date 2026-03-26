import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class ErrorRateDonut extends StatefulWidget {
  const ErrorRateDonut({super.key});

  @override
  State<ErrorRateDonut> createState() => _ErrorRateDonutState();
}

class _ErrorRateDonutState extends State<ErrorRateDonut> {
  int _touchedIndex = -1;

  static const _sections = [
    _DonutSection('Completed', 62, AppColors.green),
    _DonutSection('Running', 26, AppColors.blue),
    _DonutSection('Failed', 12, AppColors.danger),
  ];

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
          const Text(
            'Test Distribution',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Last 100 runs',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touchedIndex =
                              response?.touchedSection?.touchedSectionIndex ?? -1;
                        });
                      },
                    ),
                    centerSpaceRadius: 34,
                    sectionsSpace: 2,
                    sections: List.generate(_sections.length, (i) {
                      final s = _sections[i];
                      final isTouched = i == _touchedIndex;
                      return PieChartSectionData(
                        color: s.color,
                        value: s.percentage,
                        radius: isTouched ? 32 : 26,
                        title: '',
                        borderSide: isTouched
                            ? BorderSide(color: s.color, width: 2)
                            : const BorderSide(width: 0),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _sections.map((s) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: s.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.label,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '${s.percentage.toInt()}%',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutSection {
  final String label;
  final double percentage;
  final Color color;
  const _DonutSection(this.label, this.percentage, this.color);
}
