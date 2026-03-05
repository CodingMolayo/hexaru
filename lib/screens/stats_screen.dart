// === screens/stats_screen.dart

import 'package:flutter/material.dart';
import '../components/hex_shape_widget.dart';
import '../models/entry_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as app_date_utils;

enum StatsPeriod { week, month }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StatsPeriod _selectedPeriod = StatsPeriod.week;
  List<DailyEntry> _entries = [];
  Map<String, double> _categoryAverages = {};
  Map<String, int> _emotionStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    List<DailyEntry> entries;

    if (_selectedPeriod == StatsPeriod.week) {
      final startOfWeek = app_date_utils.DateUtils.startOfWeek(now);
      entries = LocalStorageService.getWeeklyEntries(startOfWeek);
    } else {
      entries = LocalStorageService.getMonthlyEntries(now.year, now.month);
    }

    final categoryAverages =
        LocalStorageService.calculateCategoryAverages(entries);
    final emotionStats = LocalStorageService.getEmotionStatistics(entries);
    
    // 감정 통계를 빈도순으로 정렬
    final sortedEmotionEntries = emotionStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedEmotionStats = Map.fromEntries(sortedEmotionEntries);


    setState(() {
      _entries = entries;
      _categoryAverages = categoryAverages;
      _emotionStats = sortedEmotionStats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계 보기'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  if (_entries.isEmpty)
                    _buildEmptyState()
                  else ...[
                    _buildAveragesCard(),
                    const SizedBox(height: 24),
                    _buildEmotionStatsCard(),
                  ]
                ],
              ),
          ),
    );
  }
  
  Widget _buildEmptyState() {
    final periodText = _selectedPeriod == StatsPeriod.week ? '이번 주' : '이번 달';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_rounded, size: 60, color: AppTheme.textLight),
            const SizedBox(height: 16),
            Text(
              '$periodText 기록이 없습니다.',
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<StatsPeriod>(
      segments: const <ButtonSegment<StatsPeriod>>[
        ButtonSegment<StatsPeriod>(
          value: StatsPeriod.week,
          label: Text('이번 주'),
          icon: Icon(Icons.view_week_rounded),
        ),
        ButtonSegment<StatsPeriod>(
          value: StatsPeriod.month,
          label: Text('이번 달'),
          icon: Icon(Icons.calendar_view_month_rounded),
        ),
      ],
      selected: <StatsPeriod>{_selectedPeriod},
      onSelectionChanged: (Set<StatsPeriod> newSelection) {
        setState(() {
          _selectedPeriod = newSelection.first;
          _loadData();
        });
      },
      style: SegmentedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildAveragesCard() {
    final periodText = _selectedPeriod == StatsPeriod.week ? '주간' : '월간';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$periodText 영역별 평균', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_categoryAverages.isNotEmpty)
              Center(
                child: HexShapeWidget(
                  categoryScores: _categoryAverages,
                  size: MediaQuery.of(context).size.width * 0.7,
                  showLabels: true,
                  showValues: true,
                ),
              )
            else
              const SizedBox(
                height: 100,
                child: Center(child: Text('데이터가 부족합니다.'))
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionStatsCard() {
    final periodText = _selectedPeriod == StatsPeriod.week ? '이번 주' : '이번 달';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$periodText에 자주 사용한 감정', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_emotionStats.isNotEmpty)
              ..._emotionStats.entries.map((entry) {
                final emotion = entry.key;
                final count = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(emotion, style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text('$count 회', style: const TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              })
            else
              const SizedBox(
                height: 100,
                child: Center(child: Text('선택된 감정이 없습니다.'))
              ),
          ],
        ),
      ),
    );
  }
}
