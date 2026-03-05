// === screens/home_screen.dart
// 웹 네이티브 방식으로 구현 (플러그인 불필요)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/hex_summary_card.dart';
import '../models/entry_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../theme/bgm_control.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ✅ 웹 전용 import
import 'dart:html' as html;
import 'dart:js' as js;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<DailyEntry> _recentEntries = [];
  bool _isTodayRecorded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final lastRecordDate = LocalStorageService.getLastRecordDate();
    if (lastRecordDate != null) {
      _isTodayRecorded = app_date_utils.DateUtils.isToday(lastRecordDate);
    } else {
      _isTodayRecorded = false;
    }

    _recentEntries = LocalStorageService.getRecentEntries(5);

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToRecordScreen() async {
    final result = await Navigator.pushNamed(context, '/record');
    if (mounted) {
      _loadData();
    }
  }

  // ✅ 순수 웹 방식: 피드백 폼 열기
  Future<void> _openFeedbackForm() async {
    const feedbackUrl = 'https://forms.gle/6rxDiMX8TaTj1RdXA';
    
    if (kIsWeb) {
      try {
        // dart:html 사용
        html.window.open(feedbackUrl, '_blank');
      } catch (e) {
        debugPrint('피드백 폼 열기 실패: $e');
        if (mounted) {
          _showLinkCopyDialog(feedbackUrl, '피드백 폼');
        }
      }
    } else {
      // 모바일 앱 (만약을 위한 fallback)
      _showLinkCopyDialog(feedbackUrl, '피드백 폼');
    }
  }

  // ✅ 순수 웹 방식: 앱 공유하기
  Future<void> _shareApp() async {
    const appUrl = 'https://hexaru-star.web.app';
    const shareText = '🌙 하루의 마무리를 Hexaru에서 함께 해요!\n$appUrl';
    
    if (kIsWeb) {
      try {
        // Web Share API 체크
        final hasShareApi = js.context.hasProperty('navigator') &&
            js.context['navigator'].hasProperty('share');
        
        if (hasShareApi) {
          // Web Share API 사용
          await js.context['navigator'].callMethod('share', [
            js.JsObject.jsify({
              'title': 'Hexaru',
              'text': shareText,
              'url': appUrl,
            })
          ]);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ 공유했습니다!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Web Share API 미지원 - 다이얼로그 표시
          _showShareDialog(shareText);
        }
      } catch (e) {
        debugPrint('공유 실패: $e');
        if (mounted) {
          // 사용자가 취소했거나 오류 발생 - 다이얼로그 표시
          _showShareDialog(shareText);
        }
      }
    } else {
      _showShareDialog(shareText);
    }
  }

  // 공유 다이얼로그
  void _showShareDialog(String shareText) {
    const appUrl = 'https://hexaru-star.web.app';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Hexaru 공유하기'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌙 하루의 마무리를 Hexaru에서 함께 해요!',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      appUrl,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareText));
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📋 링크가 복사되었습니다!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    tooltip: '복사',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          if (kIsWeb)
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('새 탭에서 열기'),
              onPressed: () {
                Navigator.pop(context);
                html.window.open(appUrl, '_blank');
              },
            ),
        ],
      ),
    );
  }

  // 링크 복사 다이얼로그
  void _showLinkCopyDialog(String url, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.link, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '링크를 열 수 없습니다.\n아래 링크를 복사해서 브라우저에 붙여넣어 주세요.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                url,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('링크 복사'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📋 링크가 복사되었습니다!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HEXARU'),
        actions: [
          const HexaruBGMCompact(),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildRecordButton(context),
                  const SizedBox(height: 24),
                  _buildMenu(context),
                  const SizedBox(height: 32),
                  _buildRecentEntries(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 하루는 어땠나요?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '차분히 하루를 돌아보며 스스로를 위한 기록을 남겨보세요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildRecordButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(_isTodayRecorded
          ? Icons.check_circle_outline_rounded
          : Icons.edit_note_rounded),
      label: Text(
        _isTodayRecorded ? '오늘 기록 완료' : '오늘 하루 기록하기',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: _isTodayRecorded
            ? Colors.grey.shade400
            : Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: _isTodayRecorded ? null : _navigateToRecordScreen,
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMenuButton(
          context,
          icon: Icons.calendar_today_rounded,
          label: '지난 기록',
          onTap: () => Navigator.pushNamed(context, '/review').then((_) => _loadData()),
        ),
        _buildMenuButton(
          context,
          icon: Icons.bar_chart_rounded,
          label: '통계 보기',
          onTap: () => Navigator.pushNamed(context, '/stats'),
        ),
        _buildMenuButton(
          context,
          icon: Icons.feedback_rounded,
          label: '의견 보내기',
          onTap: _openFeedbackForm,
        ),
        _buildMenuButton(
          context,
          icon: Icons.share_rounded,
          label: '소개하기',
          onTap: _shareApp,
        ),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon, required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context) {
    if (_recentEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.sentiment_satisfied_rounded,
                size: 60,
                color: AppTheme.textLight,
              ),
              const SizedBox(height: 16),
              const Text(
                '아직 기록이 없어요.\n첫 기록을 남겨보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 5일의 기록',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/review').then((_) => _loadData()),
              child: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentEntries.length,
          itemBuilder: (context, index) {
            return HexSummaryCard(
              entry: _recentEntries[index],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${app_date_utils.DateUtils.formatDay(_recentEntries[index].date)} 기록',
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}