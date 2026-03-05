// ===utils/constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  // 영역별 카테고리
  static const List<String> categories = [
    '건강',
    '심리',
    '금융',
    '관계',
    '자기계발',
    '라이프',
  ];

  // 영역별 색상
  static const Map<String, Color> categoryColors = {
    '건강': Color(0xFF4CAF50),
    '심리': Color(0xFF2196F3),
    '금융': Color(0xFFFF9800),
    '관계': Color(0xFFE91E63),
    '자기계발': Color(0xFF9C27B0),
    '라이프': Color(0xFF00BCD4),
  };

  // 영역별 질문
  static const Map<String, List<String>> questions = {
    '건강': [
      '오늘의 운동량은 충분했나요?',
      '오늘의 식사는 건강했나요?',
      '신체 컨디션은 좋았나요?',
    ],
    '심리': [
      '오늘 기분은 좋았나요?',
      '만족스러운 하루였나요?',
      '필요할 때 충분히 몰입했나요?',
    ],
    '금융': [
      '지출 관리는 잘 되었나요?',
      '가계부도 잘 작성했나요?',
      '미래 준비도 잘 되었나요?',
    ],
    '관계': [
      '가족/연인과의 관계는 좋았나요?',
      '동료/친구와의 관계는 좋았나요?',
      '사람들과 소통하는 건 만족스러웠나요?',
    ],
    '자기계발': [
      '독서가 충분했나요?',
      '학습 활동이 있었나요?',
      '창의적인 활동이 있었나요?(글쓰기, 그림 등)',
    ],
    '라이프': [
      '정리, 청소 등 공간 관리는 잘 되었나요?',
      '취미 활동은 충분했나요?',
      '디지털 디톡스도 충분했나요?',
    ],
  };

  // 감정 키워드
  static const Map<String, List<String>> emotionKeywords = {
    '긍정/활력': ['맑음', '향기로움', '활짝', '선명', '충만', '상쾌', '반짝'],
    '차분/중립': ['잔잔', '고요', '포근', '담담', '균형', '느긋', '평온'],
    '부정/저조': ['흐림', '울적', '무기력', '피로', '번잡', '답답', '무거움'],
  };

  // 감정 카테고리별 색상
  static const Map<String, Color> emotionColors = {
    '긍정/활력': Color(0xFF4CAF50),
    '차분/중립': Color(0xFF9E9E9E),
    '부정/저조': Color(0xFFF44336),
  };

  // 최대 감정 선택 개수
  static const int maxEmotionSelection = 5;

  // 육각형 차트 관련
  static const double hexagonRadius = 100.0;
  static const double hexagonStrokeWidth = 2.0;

  // 날짜 포맷
  static const String dateFormat = 'yyyy년 MM월 dd일';
  static const String monthFormat = 'yyyy년 MM월';
  static const String dayFormat = 'MM월 dd일 (E)';

  // 저장소 키
  static const String entriesStorageKey = 'daily_entries';
  static const String lastRecordDateKey = 'last_record_date';
}