// === lib/widgets/hexaru_bgm_control.dart ===

import 'package:flutter/material.dart';
import '../services/bgm_service.dart';

class HexaruBGMToggle extends StatefulWidget {
  const HexaruBGMToggle({super.key});

  @override
  State<HexaruBGMToggle> createState() => _HexaruBGMToggleState();
}

class _HexaruBGMToggleState extends State<HexaruBGMToggle> {
  final _bgm = HexaruBGMService.instance;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _bgm.initialize();
    _isPlaying = _bgm.isPlaying;
  }

  void _toggleBGM() async {
    await _bgm.toggle();
    setState(() {
      _isPlaying = _bgm.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isPlaying ? Icons.music_note : Icons.music_off,
        color: _isPlaying ? Colors.indigo : Colors.grey,
      ),
      onPressed: _toggleBGM,
      tooltip: _isPlaying ? 'BGM 끄기' : 'BGM 켜기',
    );
  }
}

// === 컴팩트 버전 (AppBar용) ===

class HexaruBGMCompact extends StatefulWidget {
  const HexaruBGMCompact({super.key});

  @override
  State<HexaruBGMCompact> createState() => _HexaruBGMCompactState();
}

class _HexaruBGMCompactState extends State<HexaruBGMCompact> {
  final _bgm = HexaruBGMService.instance;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _bgm.initialize();
    _isPlaying = _bgm.isPlaying;
  }

  void _toggleBGM() async {
    await _bgm.toggle();
    setState(() {
      _isPlaying = _bgm.isPlaying;
    });
    
    // 토스트 메시지 표시
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPlaying ? '🎵 BGM이 켜졌습니다' : '🔇 BGM이 꺼졌습니다'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _isPlaying 
            ? Colors.indigo.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _toggleBGM,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPlaying ? Icons.music_note : Icons.music_off,
                  size: 18,
                  color: _isPlaying ? Colors.indigo : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'BGM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _isPlaying ? Colors.indigo : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}