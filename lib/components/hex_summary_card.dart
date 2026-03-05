// === components/hex_summary_card.dart

import 'package:flutter/material.dart';
import '../models/entry_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'hex_shape_widget.dart';
import '../theme/app_theme.dart';

class HexSummaryCard extends StatelessWidget {
  final DailyEntry entry;
  final VoidCallback? onTap;

  const HexSummaryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Left side: Hexagon chart
              SizedBox(
                width: 100,
                height: 100,
                child: HexShapeWidget(
                  categoryScores: entry.categoryScores,
                  size: 100,
                  showLabels: false,
                  filled: true,
                ),
              ),
              const SizedBox(width: 16),
              // Right side: Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and score
                    Text(
                      app_date_utils.DateUtils.formatDay(entry.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: theme.colorScheme.primary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '종합 점수: ${entry.totalScore.toStringAsFixed(1)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // Emotion keywords
                    if (entry.selectedEmotions.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.selectedEmotions
                            .map((emotion) => _buildEmotionChip(emotion))
                            .toList(),
                      )
                    else
                      Text(
                        '선택된 감정이 없습니다.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.textLight),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionChip(String emotion) {
    String category = '';
    Color color = Colors.grey;

    // Find the category and color for the emotion
    AppConstants.emotionKeywords.forEach((cat, emotions) {
      if (emotions.contains(emotion)) {
        category = cat;
        color = AppConstants.emotionColors[category] ?? Colors.grey;
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha : 0.3)),
      ),
      child: Text(
        emotion,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
