// === screens/review_screen.dart
// 바로 달력 뷰를 보여주도록 수정된 버전

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../components/hex_summary_card.dart';
import '../models/entry_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as app_date_utils;

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late Map<DateTime, DailyEntry> _entries;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DailyEntry? _selectedEntry;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEntries();
    _updateSelectedEntry();
  }

  void _loadEntries() {
    final allDates = LocalStorageService.getAllRecordedDates();
    final entries = <DateTime, DailyEntry>{};
    for (var date in allDates) {
      final entry = LocalStorageService.getDailyEntry(date);
      if (entry != null) {
        // 날짜의 시간 정보를 제거하여 key로 사용
        final dateOnly = DateTime(date.year, date.month, date.day);
        entries[dateOnly] = entry;
      }
    }
    setState(() {
      _entries = entries;
    });
  }
  
  void _updateSelectedEntry() {
    final dateOnly = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    setState(() {
      _selectedEntry = _entries[dateOnly];
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _updateSelectedEntry();
      });
    }
  }

  void _refreshEntries() {
    _loadEntries();
    _updateSelectedEntry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지난 기록 보기'),
        actions: [
          IconButton(
            icon: Icon(_calendarFormat == CalendarFormat.month
                ? Icons.view_week_rounded
                : Icons.calendar_month_rounded),
            tooltip: _calendarFormat == CalendarFormat.month ? '주간 보기' : '월간 보기',
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '새로고침',
            onPressed: _refreshEntries,
          ),
        ],
      ),
      body: Column(
        children: [
          // 달력
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: (day) {
              final dateOnly = DateTime(day.year, day.month, day.day);
              return _entries.containsKey(dateOnly) ? [_entries[dateOnly]!] : [];
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          const Divider(height: 1),
          
          // 선택된 날짜의 상세 정보
          Expanded(
            child: _selectedEntry != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              app_date_utils.DateUtils.formatDay(_selectedDay!),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // 기록 수정 버튼 (추후 구현 가능)
                            IconButton(
                              icon: const Icon(Icons.edit_rounded),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('기록 수정 기능은 준비 중입니다.'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      HexSummaryCard(entry: _selectedEntry!),
                      
                      // 영역별 상세 점수 표시
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildCategoryDetails(_selectedEntry!),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 60,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${app_date_utils.DateUtils.formatShortDate(_selectedDay!)}에는\n기록이 없습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (app_date_utils.DateUtils.isToday(_selectedDay!))
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('오늘 기록하러 가기'),
                            onPressed: () {
                              Navigator.pushNamed(context, '/record')
                                  .then((_) => _refreshEntries());
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetails(DailyEntry entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '영역별 점수',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...entry.categoryScores.entries.map((e) {
              final category = e.key;
              final score = e.value;
              final percentage = (score / 10) * 100;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          score.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: score / 10,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}