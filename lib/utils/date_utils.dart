// === utils/date_utils.dart

import 'package:intl/intl.dart';

class DateUtils {
  // 날짜 포맷터
  static final DateFormat _fullDateFormat = DateFormat('yyyy년 MM월 dd일');
  static final DateFormat _monthFormat = DateFormat('yyyy년 MM월');
  static final DateFormat _dayFormat = DateFormat('MM월 dd일 (E)', 'ko_KR');
  static final DateFormat _shortDateFormat = DateFormat('MM/dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  // 날짜를 문자열로 포맷
  static String formatFullDate(DateTime date) => _fullDateFormat.format(date);
  static String formatMonth(DateTime date) => _monthFormat.format(date);
  static String formatDay(DateTime date) => _dayFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);

  // 오늘인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  // 같은 날인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 같은 주인지 확인
  static bool isSameWeek(DateTime date1, DateTime date2) {
    final week1 = weekNumber(date1);
    final week2 = weekNumber(date2);
    return date1.year == date2.year && week1 == week2;
  }

  // 같은 달인지 확인
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  // 주 번호 계산
  static int weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  // 주의 시작일 (월요일)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // 주의 마지막일 (일요일)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  // 월의 시작일
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // 월의 마지막일
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // 날짜 범위 생성 (시작일부터 종료일까지)
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = start;
    
    while (current.isBefore(end) || isSameDay(current, end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  // 최근 7일 날짜 리스트
  static List<DateTime> getLastWeek() {
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 6));
    return getDateRange(weekAgo, today);
  }

  // 이번 달의 모든 날짜
  static List<DateTime> getCurrentMonthDays() {
    final now = DateTime.now();
    final start = startOfMonth(now);
    final end = endOfMonth(now);
    return getDateRange(start, end);
  }

  // 상대적 시간 표시 (예: "방금", "1시간 전", "어제")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return formatShortDate(date);
    }
  }

  // 날짜를 기준으로 정렬용 키 생성
  static String getSortKey(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}