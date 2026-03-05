// ===services/local_storeage_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry_model.dart';
import '../utils/constants.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;
  
  // 초기화
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 일일 기록 저장
  static Future<bool> saveDailyEntry(DailyEntry entry) async {
    try {
      final key = DailyEntry.getDateKey(entry.date);
      final json = entry.toJsonString();
      await _prefs.setString(key, json);
      
      // 전체 엔트리 목록 업데이트
      await _updateEntryList(entry.date);
      
      // 마지막 기록 날짜 저장
      await _prefs.setString(
        AppConstants.lastRecordDateKey,
        entry.date.toIso8601String(),
      );
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving daily entry: $e');
      }
      return false;
    }
  }

  // 특정 날짜의 기록 조회
  static DailyEntry? getDailyEntry(DateTime date) {
    try {
      final key = DailyEntry.getDateKey(date);
      final json = _prefs.getString(key);
      
      if (json != null) {
        return DailyEntry.fromJsonString(json);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting daily entry: $e');
      }
      return null;
    }
  }

  // 날짜 범위로 기록 조회
  static List<DailyEntry> getEntriesByDateRange(DateTime start, DateTime end) {
    final entries = <DailyEntry>[];
    
    var current = start;
    while (current.isBefore(end) || _isSameDay(current, end)) {
      final entry = getDailyEntry(current);
      if (entry != null) {
        entries.add(entry);
      }
      current = current.add(const Duration(days: 1));
    }
    
    return entries;
  }

  // 모든 기록된 날짜 목록 가져오기
  static List<DateTime> getAllRecordedDates() {
    try {
      final datesJson = _prefs.getString(AppConstants.entriesStorageKey);
      if (datesJson != null) {
        final dates = List<String>.from(jsonDecode(datesJson));
        return dates
            .map((dateStr) => DateTime.parse(dateStr))
            .toList()
          ..sort((a, b) => b.compareTo(a)); // 최신순 정렬
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recorded dates: $e');
      }
    }
    return [];
  }

  // 최근 기록 가져오기 (개수 지정)
  static List<DailyEntry> getRecentEntries(int count) {
    final dates = getAllRecordedDates();
    final entries = <DailyEntry>[];
    
    for (var i = 0; i < dates.length && i < count; i++) {
      final entry = getDailyEntry(dates[i]);
      if (entry != null) {
        entries.add(entry);
      }
    }
    
    return entries;
  }

  // 월별 기록 가져오기
  static List<DailyEntry> getMonthlyEntries(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return getEntriesByDateRange(start, end);
  }

  // 주별 기록 가져오기
  static List<DailyEntry> getWeeklyEntries(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return getEntriesByDateRange(weekStart, weekEnd);
  }

  // 마지막 기록 날짜 가져오기
  static DateTime? getLastRecordDate() {
    try {
      final dateStr = _prefs.getString(AppConstants.lastRecordDateKey);
      if (dateStr != null) {
        return DateTime.parse(dateStr);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last record date: $e');
      }
    }
    return null;
  }

  // 기록 삭제
  static Future<bool> deleteDailyEntry(DateTime date) async {
    try {
      final key = DailyEntry.getDateKey(date);
      await _prefs.remove(key);
      await _updateEntryList(date, remove: true);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting daily entry: $e');
      }
      return false;
    }
  }

  // 통계 데이터 계산을 위한 헬퍼 메서드
  static Map<String, double> calculateCategoryAverages(List<DailyEntry> entries) {
    if (entries.isEmpty) return {};
    
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};
    
    for (final entry in entries) {
      entry.categoryScores.forEach((category, score) {
        categoryTotals[category] = (categoryTotals[category] ?? 0) + score;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      });
    }
    
    return categoryTotals.map((category, total) => 
      MapEntry(category, total / categoryCounts[category]!));
  }

  // 감정 키워드 통계
  static Map<String, int> getEmotionStatistics(List<DailyEntry> entries) {
    final emotionCounts = <String, int>{};
    
    for (final entry in entries) {
      for (final emotion in entry.selectedEmotions) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }
    
    return emotionCounts;
  }

  // Private 헬퍼 메서드들
  static Future<void> _updateEntryList(DateTime date, {bool remove = false}) async {
    final dates = getAllRecordedDates();
    final dateStr = date.toIso8601String();
    
    if (remove) {
      dates.removeWhere((d) => d.toIso8601String() == dateStr);
    } else if (!dates.any((d) => _isSameDay(d, date))) {
      dates.add(date);
    }
    
    dates.sort((a, b) => b.compareTo(a)); // 최신순 정렬
    final datesJson = jsonEncode(dates.map((d) => d.toIso8601String()).toList());
    await _prefs.setString(AppConstants.entriesStorageKey, datesJson);
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 모든 데이터 초기화 (디버그용)
  static Future<bool> clearAllData() async {
    try {
      await _prefs.clear();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all data: $e');
      }
      return false;
    }
  }
}