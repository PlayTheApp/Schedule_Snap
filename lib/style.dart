import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedule_snap/controllers/location_controller.dart';
import 'package:schedule_snap/model/location.dart';

import 'Add_task_page.dart';

Color TextColor = Colors.black;
Color MainColor = Color(0xFF5A97FB);
Color ServeColor = Color(0xFFA1C4FD);
Color Shadow_Color = Color(0x7CA1C4FD);
Color button_Color = Colors.grey.withOpacity(0.3);
Color Anniversary_Color = Color.fromARGB(255, 252, 183, 206);
Color Contest_Color = Color.fromARGB(255, 231, 182, 47);
Color show_Color = Color.fromARGB(255, 255, 61, 61);
Color Event_Color = Color.fromARGB(255, 252, 230, 108);
Color Exercise_Color = Color.fromARGB(255, 255, 149, 50);
Color Gathering_Color = Color.fromARGB(255, 133, 217, 231);
Color Leisure_Color = Color.fromARGB(255, 92, 207, 108);
Color Reservation_Color = Color.fromARGB(255, 172, 116, 204);
Color Study_Color = Colors.blue;
Color Work_Color = Color.fromARGB(255, 196, 133, 18);

final _locController = Get.put(locController());

TextStyle get TitleLine {
  // 로그인 타이틀
  return GoogleFonts.exo2(
      textStyle: TextStyle(
    fontSize: 30,
    color: Colors.white,
  ));
}

Color get login_background {
  // 로그인 화면 배경색
  return Colors.white;
}

Positioned Line(double top, double left) {
  // 선
  return Positioned(
    top: top,
    left: left,
    child: CustomPaint(
      size: Size(65, 140),
      painter: Lines(),
    ),
  );
}

Positioned Line_text(double top, double left, String text) {
  // 선 텍스트
  return Positioned(
    top: top,
    left: left,
    child: Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );
}

class Lines extends CustomPainter {
  // 로그인 화면 밑줄 그리기
  @override
  paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 2.0;

    Offset p1 = Offset(65, 600);
    Offset p2 = Offset(size.width, size.height);

    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

Positioned Circle(double top, double left, Color color) {
  // 원
  return Positioned(
    top: top,
    left: left,
    child: Image.asset('assets/image/Circle.png', scale: 4.5, color: color),
  );
}

Positioned Google(double top, double left) {
  // 구글 아이콘
  // 원
  return Positioned(
    top: top,
    left: left,
    child: Image.asset('assets/image/Google_Logo.png', scale: 4),
  );
}

Positioned Kakao(double top, double left) {
  // 카카오 아이콘
  // 원
  return Positioned(
    top: top,
    left: left,
    child: Image.asset('assets/image/Kakao_Logo.png', scale: 3.5),
  );
}

OutlinedButton Google_Button(VoidCallback onPressed) {
  // 구글 로그인 버튼
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      fixedSize: Size(300, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 원형 모양을 위한 반지름 값 설정
      ),
      side: BorderSide(
        width: 2,
        color: MainColor,
      ),
      elevation: 4,
    ),
    onPressed: onPressed,
    child: RichText(
      text: TextSpan(children: [
        TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/Google_Logo.png', scale: 8))]),
        TextSpan(text: "  구글 로그인", style: TextStyle(fontSize: 16, color: Colors.black)),
      ]),
    ),
  );
}

Container Login_Button(VoidCallback onPressed) {
  return Container(
    width: 250,
    height: 50,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(80),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [ServeColor, MainColor],
      ),
    ),
    child: MaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: StadiumBorder(),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 15, color: Colors.white),
        children: [
        TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/Google_Logo.png', scale: 45))]),
        TextSpan(text: "  구글 로그인"),
      ]),
    ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ),
  );
}

ElevatedButton Kakao_Button() {
  // 카카오 로그인 버튼
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      fixedSize: Size(200, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 원형 모양을 위한 반지름 값 설정
      ),
      elevation: 4,
    ),
    onPressed: () {},
    child: Text("카카오 로그인", style: TextStyle(color: Colors.black)),
  );
}

ButtonStyle get Serve_Style {
  return ElevatedButton.styleFrom(
    side: BorderSide(width: 2, color: MainColor),
    backgroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 25),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  );
}

List<Effect> get Left_Open {
  return [FadeEffect(curve: Curves.ease), SlideEffect(curve: Curves.ease, duration: 350.ms, begin: Offset(0.7, 0))];
}

List<Effect> get Right_Open {
  return [FadeEffect(curve: Curves.ease), SlideEffect(curve: Curves.ease, duration: 350.ms, begin: Offset(-0.7, 0))];
}

Route Add_task_Route() {
  // 일정 추가 버튼 클릭시 전환 애니메이션
  if (_locController.locList.length >= 1) {
    locations loc = _locController.locList[0];
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => Add_task(loc: loc),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  } else {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => Add_task(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

BoxDecoration Add_task_style(Color color) {
  // 일정 추가 필드 스타일
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        spreadRadius: 0,
        blurRadius: 1.0,
        color: color.withOpacity(0.5),
        offset: Offset(0, 1), // changes position of shadow
      ),
    ],
    border: Border.all(
      color: color,
      width: 1.0,
    ),
    borderRadius: BorderRadius.circular(10), // 텍스트 필드 가장자리
  );
}

BoxDecoration Check_App_style() {
  // 실행 할 앱 체크 박스 스타일
  return BoxDecoration(
      border: Border.all(
        color: MainColor,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(10),
      color: Colors.white);
}

Positioned Keyword_icon(String icon, double size) {
  // 키워드 아이콘
  return Positioned(
    bottom: 30,
    right: 50,
    child: Image.asset(icon, scale: size),
  );
}

Keyword_main(String icon, double size) {
  // 키워드 아이콘
  return Container(
    child: Image.asset(icon, scale: size),
  );
}
