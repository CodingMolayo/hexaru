// ===components/hex_shape_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

class HexShapeWidget extends StatelessWidget {
  final Map<String, double> categoryScores;
  final double size;
  final bool showLabels;
  final bool showValues;
  final bool filled;

  const HexShapeWidget({
    super.key,
    required this.categoryScores,
    this.size = 200,
    this.showLabels = true,
    this.showValues = false,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HexagonPainter(
        categoryScores: categoryScores,
        showLabels: showLabels,
        showValues: showValues,
        filled: filled,
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Map<String, double> categoryScores;
  final bool showLabels;
  final bool showValues;
  final bool filled;

  HexagonPainter({
    required this.categoryScores,
    required this.showLabels,
    required this.showValues,
    required this.filled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7;
    final categories = AppConstants.categories;
    final angleStep = (2 * math.pi) / categories.length;

    // 배경 육각형 그리기
    _drawBackgroundHexagon(canvas, center, radius);

    // 그리드 라인 그리기
    _drawGridLines(canvas, center, radius);

    // 데이터 육각형 그리기
    _drawDataHexagon(canvas, center, radius, categories, angleStep);

    // 라벨 그리기
    if (showLabels) {
      _drawLabels(canvas, size, center, radius, categories, angleStep);
    }
  }

  void _drawBackgroundHexagon(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawGridLines(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 동심원 그리기
    for (int level = 1; level <= 5; level++) {
      final levelRadius = radius * (level / 5);
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (math.pi / 3) * i - math.pi / 2;
        final x = center.dx + levelRadius * math.cos(angle);
        final y = center.dy + levelRadius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // 중심에서 꼭지점으로의 선 그리기
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  void _drawDataHexagon(Canvas canvas, Offset center, double radius, 
      List<String> categories, double angleStep) {
    final dataPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final score = categoryScores[category] ?? 0.0;
      final normalizedScore = score / 10; // 0-10 점수를 0-1로 정규화
      final angle = angleStep * i - math.pi / 2;
      final distance = radius * normalizedScore;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      points.add(Offset(x, y));
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // 채우기
    if (filled) {
      final fillPaint = Paint()
        ..color = AppConstants.categoryColors.values.first.withValues(alpha : 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawPath(dataPath, fillPaint);
    }

    // 테두리
    final strokePaint = Paint()
      ..color = AppConstants.categoryColors.values.first
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(dataPath, strokePaint);

    // 점 그리기
    for (final point in points) {
      final pointPaint = Paint()
        ..color = AppConstants.categoryColors.values.first
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 5, pointPaint);
      
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(point, 5, borderPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, Offset center, double radius,
      List<String> categories, double angleStep) {
    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final angle = angleStep * i - math.pi / 2;
      final labelRadius = radius + 30;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final textSpan = TextSpan(
        text: category,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();

      final offset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);

      // 값 표시
      if (showValues && categoryScores.containsKey(category)) {
        final score = categoryScores[category]!;
        final valueSpan = TextSpan(
          text: score.toStringAsFixed(1),
          style: textStyle.copyWith(
            fontSize: 10,
            color: AppConstants.categoryColors[category],
          ),
        );

        final valuePainter = TextPainter(
          text: valueSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        valuePainter.layout();

        final valueOffset = Offset(
          x - valuePainter.width / 2,
          y - valuePainter.height / 2 + textPainter.height / 2 + 5,
        );
        valuePainter.paint(canvas, valueOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}