import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:schedule_snap/db/db_helper.dart';
import 'package:schedule_snap/db/location_db.dart';
import 'package:schedule_snap/style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'controllers/notify_service.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 초기화를 보장해주는 역할
  await Firebase.initializeApp(
    // 구글 초기화
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DBHelper.initDb();
  await loc_DBHelper.initDb();
  await NotifyHeler.initialize(); // 알림 관련 갱신
  KakaoSdk.init(nativeAppKey: 'ecf699d704df957cebe60e4879c65e3b');
  runApp(MyApp());
}

void action() {
  Workmanager().executeTask((taskName, inputData) {
    final String? Data = inputData!['Data'];

    if (taskName == "URL") {
      print("URL : $Data");
      launchUrl(Uri.parse(Data!), mode: LaunchMode.externalApplication);
    } else if (taskName == "APP") {
      print("APP : $Data");
      DeviceApps.openApp(Data!);
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, // 수동 모드로 설정
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top], // 상단, 하단 다 보이게 설정
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: MainColor, // 변경하려는 색상 설정
      systemNavigationBarColor: MainColor,
      systemNavigationBarDividerColor: MainColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return ChangeNotifierProvider(
      // Provider 상태 관리
      create: (_) {}, // Provider에서 따로 사용할 함수..?
      child: GetMaterialApp(
        // Get 네비를 사용
        // 앱 내 최상위 위젯을 의미
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ko'),
        ],
        debugShowCheckedModeBanner: false, // DEBUG 표시 안함
        theme: ThemeData(scaffoldBackgroundColor: Colors.white, fontFamily: 'JejuGothic'), // 메인 배경 색상
        home: LoginPage(),
      ),
    );
  }
}
