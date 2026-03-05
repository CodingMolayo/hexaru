//===main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart'; // date_utils.dart를 위해 추가
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';
import 'screens/review_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/stats_screen.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // .env 파일을 사용하므로 이 파일은 더 이상 필요하지 않습니다.
import 'package:flutter_dotenv/flutter_dotenv.dart'; // flutter_dotenv 패키지 임포트

import 'services/bgm_service.dart';


void main() async {
  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // main 함수를 async로 변경하고, runApp 전에 초기화 코드를 추가합니다.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // .env 파일에서 직접 환경 변수를 읽어 Firebase를 초기화합니다.
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
    ),
  );

  await LocalStorageService.init(); // 로컬 저장소 서비스 초기화
  await initializeDateFormatting('ko_KR', null); // 한국어 날짜 포맷 초기화

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const DailyReflectionApp());

  // 앱 시작 시 BGM 자동 초기화 및 재생
  WidgetsBinding.instance.addPostFrameCallback((_) {
    HexaruBGMService.instance.initialize();
    //HexaruBGMService.instance.play(); 자동 재생 시 주석 없애고
  });
}

class DailyReflectionApp extends StatelessWidget {
  const DailyReflectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HEXARU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/record': (context) => const RecordScreen(),
        '/review': (context) => const ReviewScreen(),
        // --- /calendar 라우팅 수정 ---
        // 이전 화면에서 arguments로 날짜(DateTime)를 받을 수 있도록 수정합니다.
        '/calendar': (context) {
          // ModalRoute를 통해 arguments를 가져옵니다. 타입은 DateTime일 수도, null일 수도 있습니다.
          final initialDate = ModalRoute.of(context)?.settings.arguments as DateTime?;
          // CalendarScreen을 생성할 때 받아온 날짜를 전달합니다.
          return CalendarScreen(initialDate: initialDate);
        },
        '/stats': (context) => const StatsScreen(),
      },
    );
  }
}
