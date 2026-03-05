// === components/question_card.dart

import 'package:flutter/material.dart';
//import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'rating_slider.dart';

class QuestionCard extends StatelessWidget {
  final String category;
  final List<String> questions;
  final List<double> scores;
  final Function(int, double) onScoreChanged;

  const QuestionCard({
    super.key,
    required this.category,
    required this.questions,
    required this.scores,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppConstants.categoryColors[category] ?? theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColor.withValues(alpha : 0.05),
              categoryColor.withValues(alpha : 0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            // 카테고리 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha : 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha : 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // 평균 점수 표시
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha : 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: categoryColor.withValues(alpha : 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '평균 ',
                          style: TextStyle(
                            fontSize: 12,
                            color: categoryColor,
                          ),
                        ),
                        Text(
                          _calculateAverage().toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 질문 리스트
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(questions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RatingSlider(
                      label: questions[index],
                      value: scores[index],
                      activeColor: categoryColor,
                      onChanged: (value) => onScoreChanged(index, value),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAverage() {
    if (scores.isEmpty) return 0.0;
    final sum = scores.reduce((a, b) => a + b);
    return sum / scores.length;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '건강':
        return Icons.favorite_rounded;
      case '심리':
        return Icons.psychology_rounded;
      case '금융':
        return Icons.account_balance_wallet_rounded;
      case '관계':
        return Icons.people_rounded;
      case '자기계발':
        return Icons.school_rounded;
      case '라이프':
        return Icons.home_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}