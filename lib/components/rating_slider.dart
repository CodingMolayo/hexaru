// components/rating_slider.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final Color? activeColor;

  const RatingSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final color = activeColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(value).withValues(alpha : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getScoreColor(value).withValues(alpha : 0.3),
                ),
              ),
              child: Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(value),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // 배경 트랙
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 채워진 트랙
            FractionallySizedBox(
              widthFactor: value / 10,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getScoreColor(value).withValues(alpha : 0.8),
                      _getScoreColor(value),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbColor: _getScoreColor(value),
            overlayColor: _getScoreColor(value).withValues(alpha : 0.1),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
            ),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: onChanged,
          ),
        ),
        // 눈금 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(11, (index) {
            return Text(
              index.toString(),
              style: TextStyle(
                fontSize: 10,
                color: index == value.round() 
                  ? _getScoreColor(value)
                  : AppTheme.textLight,
              ),
            );
          }),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }
}