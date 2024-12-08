import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:schedule_snap/Camera_page.dart';
import 'package:schedule_snap/URL_page.dart';
import 'package:schedule_snap/style.dart';

import 'Text_page.dart';

class Selected_image extends StatefulWidget {
  const Selected_image({super.key});

  @override
  State<Selected_image> createState() => _Selected_imageState();
}

class _Selected_imageState extends State<Selected_image> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.white, // 변경하려는 색상 설정
          systemNavigationBarColor: MainColor,
          systemNavigationBarDividerColor: MainColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ));
        setState(() {
          FocusScope.of(context).unfocus(); // 키보드 내리기
        });
        return Future.value(true);
      },
      child: Scaffold(
        appBar: _appBar(),
        body: _widgetOptions.elementAt(_selectedIndex), // 선택한 페이지로 정해짐
        bottomNavigationBar: BottomNavigationBar(
          // 하단 네비게이션 바
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.image),
              label: '이미지',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.link),
              label: 'URL',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.text_fields_rounded),
              label: '텍스트',
            ),
          ],
          currentIndex: _selectedIndex, // 지정 인덱스로 이동
          selectedItemColor: MainColor,
          onTap: _onItemTapped, // 선언했던 onItemTapped
          elevation: 0,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  int _selectedIndex = 0; // 선택된 페이지의 인덱스 넘버 초기화

  final List<Widget> _widgetOptions = <Widget>[
    Camera_page(),
    URL_page(),
    Text_page(),
  ];

  void _onItemTapped(int index) {
    // 탭을 클릭했을떄 지정한 페이지로 이동
    setState(() {
      _selectedIndex = index;
    });
  }

  AppBar _appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined),
          color: Colors.black,
          iconSize: 30,
          onPressed: () {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.white, // 변경하려는 색상 설정
              systemNavigationBarColor: MainColor,
              systemNavigationBarDividerColor: MainColor,
              systemNavigationBarIconBrightness: Brightness.light,
            ));
            FocusScope.of(context).unfocus(); // 키보드 내리기
            Get.until((route) => route.isFirst); // 이전 페이지 지우고 처음으로 돌아가기
          }),
      title: Text("AI 일정 추가", style: TextStyle(color: Colors.black, fontSize: 18)),
      centerTitle: true, // title을 가운데에 위치
    );
  }
}

Widget progress() {
  // 진행률 표시
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircleAvatar(
        radius: 10,
        backgroundColor: MainColor,
        child: Text("1", style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
      Container(height: 1, width: 10, color: Colors.grey),
      CircleAvatar(
        radius: 10,
        backgroundColor: Colors.grey,
        child: Text("2", style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    ],
  );
}
