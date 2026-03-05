//===models/entry_model.dart

import 'dart:convert';

class DailyEntry {
  final DateTime date;
  final Map<String, double> categoryScores; // 6개 영역별 평균 점수
  final Map<String, List<double>> detailScores; // 영역별 세부 질문 점수
  final List<String> selectedEmotions; // 선택한 감정 키워드
  final String? note; // 추가 메모 (옵션)

  DailyEntry({
    required this.date,
    required this.categoryScores,
    required this.detailScores,
    required this.selectedEmotions,
    this.note,
  });

  // JSON 변환을 위한 factory constructor
  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      date: DateTime.parse(json['date']),
      categoryScores: Map<String, double>.from(
        json['categoryScores'].map((k, v) => MapEntry(k, v.toDouble())),
      ),
      detailScores: Map<String, List<double>>.from(
        json['detailScores'].map((k, v) => MapEntry(
          k,
          List<double>.from(v.map((score) => score.toDouble())),
        )),
      ),
      selectedEmotions: List<String>.from(json['selectedEmotions']),
      note: json['note'],
    );
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'categoryScores': categoryScores,
      'detailScores': detailScores,
      'selectedEmotions': selectedEmotions,
      'note': note,
    };
  }

  // JSON 문자열로 변환
  String toJsonString() => jsonEncode(toJson());

  // JSON 문자열에서 생성
  factory DailyEntry.fromJsonString(String jsonString) {
    return DailyEntry.fromJson(jsonDecode(jsonString));
  }

  // 특정 날짜의 키 생성 (저장용)
  static String getDateKey(DateTime date) {
    return 'entry_${date.year}_${date.month}_${date.day}';
  }

  // 전체 점수 계산 (6개 영역 평균)
  double get totalScore {
    if (categoryScores.isEmpty) return 0.0;
    final sum = categoryScores.values.reduce((a, b) => a + b);
    return sum / categoryScores.length;
  }

  // 복사본 생성 (수정용)
  DailyEntry copyWith({
    DateTime? date,
    Map<String, double>? categoryScores,
    Map<String, List<double>>? detailScores,
    List<String>? selectedEmotions,
    String? note,
  }) {
    return DailyEntry(
      date: date ?? this.date,
      categoryScores: categoryScores ?? this.categoryScores,
      detailScores: detailScores ?? this.detailScores,
      selectedEmotions: selectedEmotions ?? this.selectedEmotions,
      note: note ?? this.note,
    );
  }
}