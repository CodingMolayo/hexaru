// ===components/emotion_selector.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class EmotionSelector extends StatelessWidget {
  final List<String> selectedEmotions;
  final Function(String) onEmotionToggled;

  const EmotionSelector({
    super.key,
    required this.selectedEmotions,
    required this.onEmotionToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_emotions_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '오늘의 감정',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedEmotions.length}/${AppConstants.maxEmotionSelection}',
                    style: TextStyle(
                      color: selectedEmotions.length >= AppConstants.maxEmotionSelection
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '오늘을 표현하는 감정을 최대 ${AppConstants.maxEmotionSelection}개까지 선택해주세요',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ...AppConstants.emotionKeywords.entries.map((entry) {
              final category = entry.key;
              final emotions = entry.value;
              final color = AppConstants.emotionColors[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: emotions.map((emotion) {
                      final isSelected = selectedEmotions.contains(emotion);
                      final canSelect = selectedEmotions.length < AppConstants.maxEmotionSelection;

                      return InkWell(
                        onTap: () {
                          if (isSelected || canSelect) {
                            onEmotionToggled(emotion);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha : 0.2)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            emotion,
                            style: TextStyle(
                              color: isSelected
                                  ? color
                                  : (!canSelect && !isSelected)
                                      ? Colors.grey.shade400
                                      : AppTheme.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}