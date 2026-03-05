// === screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../components/hex_summary_card.dart';
import '../models/entry_model.dart';
import '../services/local_storage_service.dart';
import '../utils/date_utils.dart' as app_date_utils;

class CalendarScreen extends StatefulWidget {
  final DateTime? initialDate;
  const CalendarScreen({super.key, this.initialDate});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Initialize _entries to avoid LateInitializationError
  Map<DateTime, DailyEntry> _entries = {};
  
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  DailyEntry? _selectedEntry;

  @override
  void initState() {
    super.initState();
    // Set the initial focused day from the widget's arguments or today
    _focusedDay = widget.initialDate ?? DateTime.now();
    
    // Load entries synchronously
    _loadEntries();
    
    // Set the selected day and update the corresponding entry
    _selectedDay = _focusedDay;
    _updateSelectedEntry();
  }

  void _loadEntries() {
    final allDates = LocalStorageService.getAllRecordedDates();
    final entries = <DateTime, DailyEntry>{};
    for (var date in allDates) {
      final entry = LocalStorageService.getDailyEntry(date);
      if (entry != null) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        entries[dateOnly] = entry;
      }
    }
    // Assign loaded entries. No need for setState here, as it's in initState.
    _entries = entries;
  }
  
  void _updateSelectedEntry() {
    if (_selectedDay != null) {
      final dateOnly = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      _selectedEntry = _entries[dateOnly];
    } else {
      _selectedEntry = null;
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Check if the selected day has changed
    if (!isSameDay(_selectedDay, selectedDay)) {
      // Use setState to trigger a rebuild with the new state
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _updateSelectedEntry();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('달력으로 보기'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha : 0.7),
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            // Provide events for the calendar
            eventLoader: (day) {
              final dateOnly = DateTime(day.year, day.month, day.day);
              return _entries.containsKey(dateOnly) ? [_entries[dateOnly]!] : [];
            },
            // Update the focused day when the page changes
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedEntry != null && _selectedDay != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          app_date_utils.DateUtils.formatDay(_selectedDay!),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      HexSummaryCard(entry: _selectedEntry!),
                    ],
                  )
                : Center(
                    child: Text(
                      _selectedDay != null 
                          ? '${app_date_utils.DateUtils.formatShortDate(_selectedDay!)}에는 기록이 없습니다.' 
                          : '날짜를 선택해주세요.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha : 0.6)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}