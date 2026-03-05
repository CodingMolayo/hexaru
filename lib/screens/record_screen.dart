// === screens/record_screen.dart

import 'package:flutter/material.dart';
import '../components/emotion_selector.dart';
import '../components/question_card.dart';
import '../models/entry_model.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  // 각 카테고리별 세부 질문 점수를 저장합니다. (기본값 5.0)
  late Map<String, List<double>> _detailScores;
  // 선택된 감정 키워드를 저장합니다.
  final List<String> _selectedEmotions = [];
  // 저장 중인지 여부를 나타냅니다.
  bool _isSaving = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 질문 점수를 초기화합니다.
    _detailScores = {
      for (var category in AppConstants.categories)
        category: List.generate(
          AppConstants.questions[category]?.length ?? 0,
          (_) => 5.0,
        ),
    };
  }

  // 점수 변경 시 호출되는 콜백 함수
  void _onScoreChanged(String category, int questionIndex, double value) {
    setState(() {
      _detailScores[category]![questionIndex] = value;
    });
  }

  // 감정 토글 시 호출되는 콜백 함수
  void _onEmotionToggled(String emotion) {
    setState(() {
      if (_selectedEmotions.contains(emotion)) {
        _selectedEmotions.remove(emotion);
      } else if (_selectedEmotions.length < AppConstants.maxEmotionSelection) {
        _selectedEmotions.add(emotion);
      }
    });
  }

  // 기록을 저장하는 함수
  Future<void> _saveEntry() async {
    if (_selectedEmotions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘의 감정을 하나 이상 선택해주세요.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      // EmotionSelector 위치로 스크롤
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // 카테고리별 평균 점수 계산
    final categoryScores = <String, double>{};
    _detailScores.forEach((category, scores) {
      if (scores.isNotEmpty) {
        categoryScores[category] = scores.reduce((a, b) => a + b) / scores.length;
      } else {
        categoryScores[category] = 0.0;
      }
    });

    // DailyEntry 객체 생성
    final newEntry = DailyEntry(
      date: DateTime.now(),
      categoryScores: categoryScores,
      detailScores: _detailScores,
      selectedEmotions: _selectedEmotions,
    );

    // 로컬 저장소에 저장
    final success = await LocalStorageService.saveDailyEntry(newEntry);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오늘의 기록이 저장되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // true를 반환하여 데이터가 변경되었음을 알림
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 하루 기록'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100), // FAB 공간 확보
        child: Column(
          children: [
            // 각 카테고리별 질문 카드
            ...AppConstants.categories.map((category) {
              final questions = AppConstants.questions[category]!;
              final scores = _detailScores[category]!;
              return QuestionCard(
                category: category,
                questions: questions,
                scores: scores,
                onScoreChanged: (index, value) {
                  _onScoreChanged(category, index, value);
                },
              );
            }),
            // 감정 선택 위젯
            EmotionSelector(
              selectedEmotions: _selectedEmotions,
              onEmotionToggled: _onEmotionToggled,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveEntry,
        icon: _isSaving
            ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
            : const Icon(Icons.save_rounded),
        label: Text(_isSaving ? '저장 중...' : '기록 저장하기'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
