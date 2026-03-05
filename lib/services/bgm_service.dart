// === lib/services/bgm_service.dart ===

import 'package:flutter/material.dart';
import 'dart:js' as js; 
//import 'dart:js_interop'; //이걸 어떻게 써야하지?

class HexaruBGMService {
  static HexaruBGMService? _instance;
  static HexaruBGMService get instance {
    _instance ??= HexaruBGMService._();
    return _instance!;
  }

  HexaruBGMService._();

  bool _isInitialized = false;
  bool _isPlaying = false;

  // BGM 초기화 (Tone.js 사용)
  void initialize() {
    if (_isInitialized) return;

    js.context.callMethod('eval', ['''
      (function() {
        if (window.hexaruBGM) return;
        
        const Tone = window.Tone;
        if (!Tone) {
          console.error('Tone.js not loaded');
          return;
        }

        // 🎹 악기 설정 - 따뜻한 패드 사운드
        const synth1 = new Tone.PolySynth(Tone.Synth, {
          oscillator: { type: 'sine' },
          envelope: {
            attack: 2.0,
            decay: 1.0,
            sustain: 0.6,
            release: 3.0
          },
          volume: -8
        }).toDestination();

        const synth2 = new Tone.PolySynth(Tone.Synth, {
          oscillator: { type: 'triangle' },
          envelope: {
            attack: 1.5,
            decay: 0.8,
            sustain: 0.7,
            release: 2.5
          },
          volume: -10
        }).toDestination();

        // 🌙 잔잔한 멜로디 시퀀스 (로파이/앰비언트 느낌)
        const melody = [
          ['C4', 'E4', 'G4'], ['D4', 'F4', 'A4'], 
          ['E4', 'G4', 'B4'], ['C4', 'E4', 'G4'],
          ['A3', 'C4', 'E4'], ['G3', 'B3', 'D4'],
          ['F3', 'A3', 'C4'], ['C4', 'E4', 'G4']
        ];

        const bass = ['C2', 'D2', 'E2', 'C2', 'A1', 'G1', 'F1', 'C2'];

        let melodyIndex = 0;
        let bassIndex = 0;

        // 🔄 루프 설정
        const melodyLoop = new Tone.Loop((time) => {
          synth1.triggerAttackRelease(melody[melodyIndex], '2n', time);
          melodyIndex = (melodyIndex + 1) % melody.length;
        }, '2n');

        const bassLoop = new Tone.Loop((time) => {
          synth2.triggerAttackRelease(bass[bassIndex], '1n', time);
          bassIndex = (bassIndex + 1) % bass.length;
        }, '1n');

        // BPM 설정 (느린 템포)
        Tone.getTransport().bpm.value = 65;

        window.hexaruBGM = {
          start: async function() {
            await Tone.start();
            melodyLoop.start(0);
            bassLoop.start(0);
            Tone.getTransport().start();
          },
          stop: function() {
            Tone.getTransport().stop();
            melodyLoop.stop();
            bassLoop.stop();
          },
          setVolume: function(vol) {
            const db = Tone.gainToDb(vol);
            synth1.volume.value = db - 8;
            synth2.volume.value = db - 10;
          }
        };
      })();
    ''']);

    _isInitialized = true;
  }

  // BGM 재생
  Future<void> play() async {
    if (!_isInitialized) initialize();
    
    try {
      js.context['hexaruBGM'].callMethod('start', []);
      _isPlaying = true;
    } catch (e) {
      debugPrint('BGM 재생 실패: $e');
    }
  }

  // BGM 정지
  void stop() {
    if (!_isInitialized) return;
    
    try {
      js.context['hexaruBGM'].callMethod('stop', []);
      _isPlaying = false;
    } catch (e) {
      debugPrint('BGM 정지 실패: $e');
    }
  }

  // 토글 (재생 중이면 정지, 정지 중이면 재생)
  Future<void> toggle() async {
    if (_isPlaying) {
      stop();
    } else {
      await play();
    }
  }

  bool get isPlaying => _isPlaying;

  // 리소스 정리
  void dispose() {
    stop();
  }
}

