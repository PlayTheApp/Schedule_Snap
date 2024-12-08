import 'dart:convert';
import 'package:animate_icons/animate_icons.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kpostal/kpostal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schedule_snap/Selected_image.dart';
import 'package:schedule_snap/Task_page.dart';
import 'package:schedule_snap/controllers/location_controller.dart';
import 'package:schedule_snap/controllers/task_controller.dart';
import 'package:schedule_snap/fast_task.dart';
import 'package:schedule_snap/login.dart';
import 'package:intl/intl.dart';
import 'package:schedule_snap/main.dart';
import 'package:schedule_snap/main_task_tile.dart';
import 'package:schedule_snap/model/location.dart';
import 'package:schedule_snap/task_tile.dart';
import 'controllers/notify_service.dart';
import 'model/task.dart';
import 'my_flutter_app_icons.dart';
import 'style.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // 알림 관련

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _taskController = Get.put(TaskController());
  final _locController = Get.put(locController());

  int? closenumber;
  Duration? closestTimeDifference;
  var mytime;

  int? page_number = 0;

  /* ---------------------------------------------------------------------------------------- */
  // 주소 텍스트 필드
  final TextEditingController _locationController = TextEditingController();
  String? My_latlng = null;

  late double My_latitude = 0.0;
  late double My_longitude = 0.0;

  // 자신의 현 위치 가져오기
  Future<void> getCurrentLocation() async {
    try {
      // Geolocator API로 위도, 경도 호출
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, forceAndroidLocationManager: true);

      setState(() {
        _markers.clear();
        My_latitude = position.latitude;
        My_longitude = position.longitude;
        _mylocation = CameraPosition(
          target: LatLng(My_latitude, My_longitude),
          zoom: 16, // 카메라 확대 크기
        ); // 해당 위치로 카메라 위치 기입
      });
    } catch (e) {
      print(e); // 현재 권한 부여가 제대로 되지않은듯?
    }
  }

  Future<void> Change_Address() async {
    // 좌표로 주소 구하기
    final gpsUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${My_latitude},${My_longitude}&key={yourKey}&language=ko';
    final response_Address = await http.get(Uri.parse(gpsUrl));

    setState(() {
      My_latlng = jsonDecode(response_Address.body)['results'][0]['formatted_address']; // 주소 넣기
      My_latlng = My_latlng!.replaceAll('대한민국', ''); // "대한민국" 문자열 삭제
      _locationController.text = My_latlng!; // 텍스트 필드에 기입
    });
  }

  // 자신의 현 위치 가져오기
  Future<void> getDBLocation() async {
    try {
      setState(() {
        _markers.clear();
        My_latitude = _locController.locList[0].lat!;
        My_longitude = _locController.locList[0].lng!;
        _mylocation = CameraPosition(
          target: LatLng(My_latitude, My_longitude),
          zoom: 16, // 카메라 확대 크기
        ); // 해당 위치로 카메라 위치 기입
      });
    } catch (e) {
      print(e); // 현재 권한 부여가 제대로 되지않은듯?
    }
  }

  check_loc() async {
    if (_locController.locList.length >= 1) {
      setState(() {
        getDBLocation();
        Change_Address();
        Add_Marker();
      });
      final GoogleMapController controller = await _controller.future;
      controller.showMarkerInfoWindow(MarkerId("1")); // infowindow 열어두기
    }
  }

  _addloc() async {
    await _locController.addloc(
        loc: locations(
      loc: _locationController.text,
      lat: My_latitude,
      lng: My_longitude,
    ));
    print("주소 저장을 완료했습니다.");
    _locController.getlocs();
  }

  // 카메라 위치?
  Completer<GoogleMapController> _controller = Completer();

  late CameraPosition _mylocation; // 현위치 (혹은 다른위치)

  Future<void> _goToTheLake() async {
    // 현위치 아이콘 클릭시
    if (_locController.locList.length >= 1) {
      _locController.deleteAll();
    }
    await Permission.location.request(); // 권한 부여받았는지 확인
    await getCurrentLocation(); // 현 위치 가져오기
    await Change_Address();
    await Add_Marker(); // 마커 추가하기
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(
      // 기존의 카메라 위치를 지우기 위해 moveCamera 사용
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(36, 127), zoom: 12),
      ),
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_mylocation)); // 해당 위치로 카메라 이동
    controller.showMarkerInfoWindow(MarkerId("1")); // infowindow 열어두기
    await _addloc();
  }

  //마커
  List<Marker> _markers = [];
  late Uint8List markerIcon;

  Add_Marker() {
    // 마커 추가
    _markers.add(Marker(
      markerId: MarkerId("1"),
      // infoWindow: InfoWindow(title: "현 위치"),
      draggable: true,
      onTap: () {},
      position: LatLng(My_latitude, My_longitude),
      icon: BitmapDescriptor.fromBytes(markerIcon),
    ));
  }

  void setCustomMapPin() async {
    // 마커 변환
    markerIcon = await getBytesFromAsset('assets/image/start_marker.png', 70);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  /* ---------------------------------------------------------------------------------------- */

  late bool _isButtonPressed; // 버튼을 눌렀는가?
  late User? currentUser;
  DateTime _selectedDate = DateTime.now();
  double Next_percent = 0.00;

  // final DateTime endTime = DateTime.parse("2023-09-10 07:52:00");

  late Duration _timeDifference;
  late Timer _timer; // 타이머 객체 추가

  late AnimationController _animationController; // 애니메이션 조작
  late Animation _animateColor; // 애니메이션 색상
  late Animation<double> _animateIcon;

  /// 애니메이션 아이콘
  late Animation<double> _translateButton;
  bool isOpened = false; // 클릭 했는지 안했는지
  Curve _curve = Curves.ease; // 애니메이션 관련?

  FocusNode _textFieldFocusNode = FocusNode();
  bool _isTextFieldOpen = false;

  DateTime _startDate = DateTime.now();
  String _startTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 시작 시간
  String _todayTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 현재 시간
  late bool _isToday = false; // 현재 날짜와 다른가?
  late bool _isTime = false; // 시작 과 마감 시간이 현재 시간과 다른가?

  Check_Start_Date() {
    // 날짜가 다른지 확인
    _isToday = _startDate.year != DateTime.now().year || _startDate.month != DateTime.now().month || _startDate.day != DateTime.now().day;
  }

  Check_Time() {
    // 시간이 다른지 확인
    _isTime = _startTime != _todayTime;
  }

  @override
  void initState() {
    // FocusNode의 포커스 변경 이벤트를 구독합니다.
    _textFieldFocusNode.addListener(() {
      setState(() {
        _isTextFieldOpen = _textFieldFocusNode.hasFocus;
      });
    });

    super.initState();

    permiss_notify(); // 알림 권한 요청

    _taskController.getTasks(); // 데이터베이스 갱신
    _locController.getlocs(); // 초반 주소 갱신
    NotifyHeler.initialize(); // 알림 관련 갱신
    NotifyHeler.check();

    setCustomMapPin(); // 마커 이미지 변환
    currentUser = FirebaseAuth.instance.currentUser;
    _isButtonPressed = false;
    _selectedDate = DateTime.now();

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 400))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(
      begin: Colors.white,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));
    _translateButton = Tween<double>(
      // FAB 확장 애니메이션
      begin: 50.0,
      end: -7.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        0.75,
        curve: _curve,
      ),
    ));
    page_number = 0;

    pageController.addListener(_pageListener);
  }

  void _pageListener() {
    // 페이지 넘겼을때
    setState(() {
      page_number = pageController.page?.round();
    });
  }

  void permiss_notify() async {
    final locationStatus = await Permission.location.request(); // 위치 권한
    final notificationStatus = await Permission.notification.request(); // 알림 권한

    if (notificationStatus.isDenied && locationStatus.isDenied) {
      showDialog(
        barrierDismissible: false, // 다른곳의 터치는 막음
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 2,
              color: MainColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          backgroundColor: Colors.white,
          title: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            alignment: Alignment.center,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(children: [WidgetSpan(child: Icon(Icons.location_off, color: Colors.grey, size: 20))]),
                TextSpan(children: [WidgetSpan(child: Icon(Icons.notifications_off_rounded, color: Colors.grey, size: 20))]),
                TextSpan(text: " 권한이 없습니다.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ]),
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(text: "주소 찾기 / 알림 받기를 위해서는 \n", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                      TextSpan(text: "위치 / 알림 권한", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                      TextSpan(text: "을 허용해야 합니다.", style: TextStyle(fontSize: 15, color: Colors.black)),
                    ]),
                  ),
                  Image.asset('assets/image/permiss.jpg', scale: 3),
                  Text("설정 - 애플리케이션 - 위치/알림 - 허용 ", style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              child: Text('설정하기', style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                Navigator.of(context).pop();
                openAppSettings(); // 설정 클릭 시 앱 설정 화면으로 이동
              },
            ),
            TextButton(
              child: Text('나중에', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2,
                              color: MainColor,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                          ),
                          title: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.warning, color: Colors.grey, size: 20))]),
                              TextSpan(text: " 권한 거부 ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.warning, color: Colors.grey, size: 20))]),
                            ]),
                          ),
                          content: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(text: "권한이 없으면 정상적인 서비스가 어렵습니다\n", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                              TextSpan(text: "(이후 설정에서 권한 허용이 가능합니다)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                            ]),
                          ),
                          actionsAlignment: MainAxisAlignment.spaceAround,
                          actions: <Widget>[
                            TextButton(
                              child: Text('확인', style: TextStyle(color: Colors.black)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
      );
    } else if (notificationStatus.isDenied && locationStatus.isGranted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 2,
              color: MainColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          backgroundColor: Colors.white,
          title: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            alignment: Alignment.center,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(children: [WidgetSpan(child: Icon(Icons.notifications_off_rounded, color: Colors.grey, size: 20))]),
                TextSpan(text: " 권한이 없습니다.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ]),
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(text: "앱에서 보내는 알림을 받기 위해서는 \n", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                      TextSpan(text: "알림 권한", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                      TextSpan(text: "을 허용해야 합니다.", style: TextStyle(fontSize: 15, color: Colors.black)),
                    ]),
                  ),
                  Image.asset('assets/image/permiss.jpg', scale: 3),
                  Text("설정 - 애플리케이션 - 알림 - 허용 ", style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              child: Text('설정하기', style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                Navigator.of(context).pop();
                openAppSettings(); // 설정 클릭 시 앱 설정 화면으로 이동
              },
            ),
            TextButton(
              child: Text('나중에', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2,
                              color: MainColor,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                          ),
                          title: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.warning, color: Colors.grey, size: 20))]),
                              TextSpan(text: " 권한 거부 ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.warning, color: Colors.grey, size: 20))]),
                            ]),
                          ),
                          content: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(text: "권한이 없으면 정상적인 서비스가 어렵습니다\n", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                              TextSpan(text: "(이후 설정에서 권한 허용이 가능합니다)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                            ]),
                          ),
                          actionsAlignment: MainAxisAlignment.spaceAround,
                          actions: <Widget>[
                            TextButton(
                              child: Text('확인', style: TextStyle(color: Colors.black)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); // 애니메이션 취소?
    super.dispose();
  }

  animate() {
    // 클릭했을때, 안했을때 반응
    if (!isOpened) {
      _animationController.forward();
      Anicontroller.animateToEnd();
    } else {
      _animationController.reverse();
      Anicontroller.animateToStart();
    }
    isOpened = !isOpened;
  }

  final TextEditingController fast_text = TextEditingController(); // 빠른 일정 추가 텍스트

  final PageController pageController = PageController(
    initialPage: 0,
  );

  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;

  bool OPEN_GPT = false;

  String _keywordValue = "랜덤";
  List<String> keywordList = ["공부", "업무", "음식", "운동", "랜덤"];
  late bool _isKeyword = false;

  final TextEditingController GPTtext = TextEditingController(); // 출발지

  bool OPEN_GPT2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawerEnableOpenDragGesture: false,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // 구글 로그인이 안되어있으면
            return LoginPage(); // 로그인 페이지로 이동
          }
          return GestureDetector(
            // Selected_Schedule() 외 다른곳 터치 감지
            onTap: () {
              setState(() {
                _startDate = DateTime.now();
                _isTextFieldOpen = false;
                Check_Start_Date();
                Check_Time();
                _startTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString();
                _todayTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 현재 시간
                FocusManager.instance.primaryFocus?.unfocus(); // 키보드 내리기
                // FocusScope.of(context).unfocus(); <- 이거 쓰면.... 내려가 있다가 다시 올라옴..;
                _isButtonPressed = false; // 날짜선택 위젯을 닫는다.
                // isOpened = true; // FAB가 열려있다고 가정하고,
                // animate(); // 닫히게 한다.
              });
            },
            child: Scaffold(
                key: _scaffoldKey,
                drawer: Drawer_Menu(snapshot.data!), // 좌측 슬라이드 메뉴
                appBar: App_bar(snapshot.data!), // 상단바
                body: PageView(
                  controller: pageController, // PageController 연결
                  children: [
                    Column(
                      children: [
                        Container(
                          height: (_taskController.taskList.isNotEmpty) ? 150 : 0,
                          child: Obx(() {
                            if (_taskController.taskList.isNotEmpty) {
                              for (int i = 0; i < _taskController.taskList.length; i++) {
                                Task task = _taskController.taskList[i];
                                DateTime taskStartDate = DateFormat("yyyy-MM-dd").parse(task.Start_Date.toString()); // 시작 날짜를 비교
                                Duration DateDifference = taskStartDate.difference(DateTime.now());
                                if (closestTimeDifference == null || DateDifference < closestTimeDifference!) {
                                  closenumber = i;
                                  closestTimeDifference = DateDifference;
                                  // mytime = DateFormat("HH:mm").format(taskStartDate);
                                }
                              }
                              return Main_Task_Tile(_taskController.taskList[closenumber!]);
                            } else
                              return Container();
                          }),
                        ),
                        SizedBox(height: 10),
                        _taskController.taskList.length > 0 ? Selected_Schedule() : Container(), // TODAT + 날짜 리스트 + 달력 종합위젯
                        _isButtonPressed
                            ? Animate(
                                effects: [FadeEffect(curve: Curves.ease, duration: 350.ms), SlideEffect(curve: Curves.ease)],
                                child: Offstage(
                                  offstage: false,
                                  child: _Schedule_List(), // 날짜 리스트
                                ),
                              )
                            : Offstage(
                                offstage: true,
                                child: _Schedule_List(), // 날짜 리스트
                              ),
                        SizedBox(height: 10),
                        _taskController.taskList.length == 0 ? _add_Task() : Task_List(), // 일정 리스트,
                      ],
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OPEN_GPT
                                ? Stack(
                                    children: [
                                      Container(
                                        width: 300,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          border: Border.all(color: Colors.green, width: 3),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Checkbox(
                                                  activeColor: Colors.green,
                                                  checkColor: Colors.white,
                                                  value: isChecked1,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      isChecked1 = value!;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  "아침 명상",
                                                  style: TextStyle(
                                                    decoration: isChecked1 ? TextDecoration.lineThrough : null,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  activeColor: Colors.green,
                                                  checkColor: Colors.white,
                                                  value: isChecked2,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      isChecked2 = value!;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  "업무 피로 회복",
                                                  style: TextStyle(
                                                    decoration: isChecked2 ? TextDecoration.lineThrough : null,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  activeColor: Colors.green,
                                                  checkColor: Colors.white,
                                                  value: isChecked3,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      isChecked3 = value!;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  "새로운 아이디어 기록",
                                                  style: TextStyle(
                                                    decoration: isChecked3 ? TextDecoration.lineThrough : null,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  activeColor: Colors.green,
                                                  checkColor: Colors.white,
                                                  value: isChecked4,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      isChecked4 = value!;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  "가벼운 산책",
                                                  style: TextStyle(
                                                    decoration: isChecked4 ? TextDecoration.lineThrough : null,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  activeColor: Colors.green,
                                                  checkColor: Colors.white,
                                                  value: isChecked5,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      isChecked5 = value!;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  "가족 또는 친구에게 전화 걸기",
                                                  style: TextStyle(
                                                    decoration: isChecked5 ? TextDecoration.lineThrough : null,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Image.asset(
                                          'assets/image/gpt.png',
                                          scale: 8,
                                          color: Colors.green,
                                        ),
                                      )
                                    ],
                                  )
                                : Container(),
                            SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 12), // 크기 조절
                              ),
                              onPressed: () {
                                setState(() {
                                  OPEN_GPT = true;
                                });
                              },
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(children: [
                                    WidgetSpan(
                                        child: Image.asset(
                                      'assets/image/gpt.png',
                                      scale: 14,
                                      color: Colors.white,
                                    ))
                                  ]),
                                  TextSpan(text: " 데일리 체크리스트 생성", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ]),
                              ),
                            ),
                            Container(
                              width: 300,
                              height: 50,
                              child: DropdownButton(
                                elevation: 1,
                                icon: Icon(Icons.arrow_drop_down_rounded, color: MainColor, size: 30),
                                isExpanded: true, // 좌우 최대치
                                alignment: Alignment.center,
                                underline: Container(), // 밑줄
                                borderRadius: BorderRadius.circular(10), // 메뉴 가장자리
                                menuMaxHeight: 200, // 메뉴 최대길이
                                hint: Text("${_keywordValue}", style: TextStyle(color: MainColor)),
                                items: keywordList.map<DropdownMenuItem<String>>((String? value) {
                                  return DropdownMenuItem<String>(
                                      value: value,
                                      child: value == _keywordValue
                                          ? RichText(
                                              // 선택한 부분의 값에 check 표시
                                              text: TextSpan(children: [
                                              TextSpan(children: [WidgetSpan(child: Icon(Icons.check, color: MainColor, size: 20))]),
                                              TextSpan(text: "  ${value!}", style: TextStyle(color: MainColor, fontWeight: FontWeight.bold, fontSize: 16))
                                            ]))
                                          : Text(value!), // 선택 외 나머지는 그대로 유지
                                      alignment: Alignment.center);
                                }).toList(),
                                onChanged: ((String? newValue) {
                                  setState(() {
                                    _keywordValue = newValue!;
                                  });
                                }),
                              ),
                            )
                          ],
                        )),
                    Container(
                        // 질문 텍스트 박스
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            !OPEN_GPT2
                                ? Container(
                                    width: 300,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      border: Border.all(color: Colors.green, width: 3),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text("1. Abandon - (동사) 버리다, 포기하다."),
                                        Text("2. Accomplish - (동사) 성취하다, 완수하다."),
                                        Text("3. Acquire - (동사) 얻다, 습득하다."),
                                        Text("4. Adapt - (동사) 적응하다, 조정하다."),
                                        Text("5. Adequate - (형용사) 충분한, 적절한."),
                                      ],
                                    ),
                                  )
                                : Container(
                                    width: 300,
                                    height: 50,
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.only(left: 14),
                                    decoration: Add_task_style(button_Color),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            onTap: () {},
                                            onChanged: (value) {
                                              // 텍스트가 들어갔을때 초기화 활성화
                                              setState(() {});
                                            },
                                            controller: GPTtext, // 텍스트가 들어가는 부분
                                            autofocus: false,
                                            cursorColor: Colors.grey,
                                            decoration: InputDecoration(
                                                suffixIcon: GestureDetector(
                                                    // 지우기 버튼
                                                    child: Icon(Icons.cancel_outlined, color: Colors.black, size: 20),
                                                    onTap: () {
                                                      setState(() {});
                                                    }),
                                                hintText: "GPT에게 질문해보세요 !",
                                                hintStyle: TextStyle(fontSize: 14),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.white, width: 0),
                                                ),
                                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 12), // 크기 조절
                              ),
                              onPressed: () {
                                setState(() {
                                  OPEN_GPT = true;
                                });
                              },
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(children: [
                                    WidgetSpan(
                                        child: Image.asset(
                                      'assets/image/gpt.png',
                                      scale: 14,
                                      color: Colors.white,
                                    ))
                                  ]),
                                  TextSpan(text: " 질문하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ]),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
                bottomNavigationBar: Container(
                  height: 85,
                  child: BottomAppBar(
                      color: _isTextFieldOpen ? MainColor : null,
                      elevation: 0.0,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55,
                              color: MainColor,
                            ),
                          ),
                          isOpened
                              ? Animate(
                                  effects: Left_Open,
                                  child: Positioned(
                                    bottom: 5,
                                    left: 30,
                                    child: Row(
                                      children: [
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            elevation: 1.0,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                            side: BorderSide(
                                              width: 1,
                                              color: MainColor,
                                            ),
                                          ),
                                          onPressed: () {},
                                          child: RichText(
                                            text: TextSpan(children: [
                                              TextSpan(children: [WidgetSpan(child: Icon(Icons.people_alt, color: Colors.black, size: 20))]),
                                              TextSpan(text: " 일정 조율", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                                            ]),
                                          ),
                                        ),
                                        SizedBox(width: 30),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            elevation: 1.0,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                            side: BorderSide(
                                              width: 1,
                                              color: MainColor,
                                            ),
                                          ),
                                          onPressed: () {
                                            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                              statusBarColor: Colors.white, // 변경하려는 색상 설정
                                              systemNavigationBarColor: Colors.white,
                                              systemNavigationBarDividerColor: Colors.white,
                                              systemNavigationBarIconBrightness: Brightness.dark,
                                            ));
                                            Get.to(() => Selected_image());
                                            setState(() {
                                              _startDate = DateTime.now();
                                              _isButtonPressed = false; // 날짜선택 위젯을 닫는다.
                                              // isOpened = true; // FAB가 열려있다고 가정하고,
                                              // animate(); // 닫히게 한다.
                                            });
                                          },
                                          child: RichText(
                                            text: TextSpan(children: [
                                              TextSpan(children: [WidgetSpan(child: Icon(Icons.android_outlined, color: Colors.black, size: 20))]),
                                              TextSpan(text: " AI 일정", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(child: Text("")),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                minRadius: 40,
                                maxRadius: 40,
                                backgroundColor: MainColor,
                              ),
                            ],
                          ),
                          Positioned(
                            right: 5,
                            child: CircleAvatar(
                              minRadius: 35,
                              maxRadius: 35,
                              backgroundColor: MainColor,
                              child: SizedBox(
                                  width: 65,
                                  height: 65,
                                  child: _isTextFieldOpen
                                      ? FloatingActionButton(
                                          backgroundColor: Colors.white,
                                          child: Icon(Icons.check, color: fast_text.text.isNotEmpty ? MainColor : Colors.grey, size: 40),
                                          onPressed: fast_text.text.isNotEmpty
                                              ? () async {
                                                  await fast_add_task(fast_text.text, _startDate, _startTime);
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                  Fluttertoast.showToast(
                                                    msg: "일정을 생성했습니다.",
                                                    gravity: ToastGravity.TOP,
                                                    backgroundColor: Colors.blue,
                                                    fontSize: 15,
                                                    textColor: Colors.white,
                                                    toastLength: Toast.LENGTH_SHORT,
                                                  );
                                                  setState(() {
                                                    _taskController.getTasks();
                                                    fast_text.clear();
                                                    _startDate = DateTime.now();
                                                    _startTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString();
                                                    _todayTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 현재 시간
                                                    _isTextFieldOpen = false;
                                                    Check_Start_Date();
                                                    Check_Time();
                                                  });
                                                }
                                              : () {
                                                  Fluttertoast.showToast(
                                                    msg: "내용을 채우고 다시 시도해주세요.",
                                                    gravity: ToastGravity.TOP,
                                                    backgroundColor: Colors.redAccent,
                                                    fontSize: 15,
                                                    textColor: Colors.white,
                                                    toastLength: Toast.LENGTH_SHORT,
                                                  );
                                                },
                                        )
                                      : FAB_toggle()),
                            ),
                          ),
                          Positioned(
                            // 빠른 일정 추가
                            left: 15,
                            bottom: 15,
                            child: isOpened
                                ? Container()
                                : Container(
                                    color: MainColor,
                                    width: 300,
                                    height: 30,
                                    child: TextFormField(
                                      onChanged: (value) {
                                        // 텍스트가 들어갔을때 초기화 활성화
                                        setState(() {});
                                      },
                                      controller: fast_text,
                                      focusNode: _textFieldFocusNode,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        suffixIcon: fast_text.text.isNotEmpty
                                            ? GestureDetector(
                                                // 지우기 버튼
                                                child: Icon(Icons.cancel_outlined, color: ServeColor, size: 20),
                                                onTap: fast_text.text.isNotEmpty
                                                    ? () {
                                                        setState(() {
                                                          fast_text.clear();
                                                        });
                                                      }
                                                    : null,
                                              )
                                            : null,
                                        isDense: true,
                                        hintText: "${DateFormat("yyyy년 MM월 dd일 (E) 일정 생성", 'ko').format(_startDate)}",
                                        hintStyle: TextStyle(fontSize: 13),
                                        contentPadding: EdgeInsets.all(5), // 이거 쓰면 가려지는게 해결?
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)), // 안눌렀을때 밑줄
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)), // 눌렀을때 밑줄
                                      ),
                                    ),
                                  ),
                          ),
                          Visibility(
                              // 빠른 일정 날짜 선택
                              visible: _isTextFieldOpen,
                              child: Positioned(
                                top: 10,
                                left: 15,
                                child: Row(
                                  children: [
                                    (fast_text.text.isNotEmpty || _isToday || _isTime)
                                        ? SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: FloatingActionButton(
                                              backgroundColor: Colors.white,
                                              onPressed: () {
                                                setState(() {
                                                  fast_text.clear();
                                                  _startDate = DateTime.now();
                                                  _startTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString();
                                                  _todayTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 현재 시간
                                                  Check_Start_Date();
                                                  Check_Time();
                                                });
                                              },
                                              child: Icon(Icons.rotate_left_rounded, color: Colors.red),
                                            ),
                                          )
                                        : Container(),
                                    Container(
                                      margin: (fast_text.text.isNotEmpty || _isToday || _isTime) ? EdgeInsets.only(left: 10, right: 10) : EdgeInsets.only(right: 10),
                                      width: 150,
                                      height: 25,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              side: BorderSide(
                                                width: 1,
                                                color: ServeColor,
                                              ),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                          onPressed: () async {
                                            DateTime? _pickerDate = await showDatePicker(
                                                // 달력 표시
                                                helpText: "날짜를 선택해주세요",
                                                fieldHintText: "ex) 2020. 8. 7.",
                                                fieldLabelText: "날짜를 입력해주세요 *띄어쓰기",
                                                context: context,
                                                initialDate: _startDate,
                                                firstDate: DateTime(2022),
                                                lastDate: DateTime(2030),
                                                confirmText: "선택");
                                            if (_pickerDate != null) {
                                              _startDate = _pickerDate;
                                            }
                                            setState(() {
                                              Check_Start_Date();
                                            });
                                          },
                                          child: Text("${DateFormat("yyyy년 MM월 dd일 (E)", 'ko').format(_startDate)}", style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      width: 100,
                                      height: 25,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              side: BorderSide(
                                                width: 1,
                                                color: ServeColor,
                                              ),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                          onPressed: () {
                                            getTimeFromUser();
                                          },
                                          child: Text("$_startTime", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))),
                                    ),
                                  ],
                                ),
                              )),
                          !_isTextFieldOpen
                              ? Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(radius: 5, backgroundColor: page_number == 0 ? MainColor : Colors.grey),
                                      SizedBox(width: 5),
                                      CircleAvatar(radius: 5, backgroundColor: page_number == 1 ? MainColor : Colors.grey),
                                      SizedBox(width: 10),
                                      page_number == 0 ? Text("HOME", style: TextStyle(color: MainColor, fontSize: 14)) : Text("DAILY", style: TextStyle(color: MainColor, fontSize: 14))
                                    ],
                                  ))
                              : Container(),
                        ],
                      )),
                )),
          );
        },
      ),
    );
  }

  getTimeFromUser() async {
    // 유저가 선택한 시간을 받아오는 함수
    var pickedTime = await _showTimePicker() ?? TimeOfDay.now(); // 취소 버튼을 눌렀을때 null 값 대체
    String _formatedTime = pickedTime.format(context);
    if (pickedTime == null) {
      print("취소하였습니다.");
    } else {
      setState(() {
        _startTime = _formatedTime;
        Check_Time();
      });
    }
  }

  _showTimePicker() {
    return showTimePicker(
        context: context,
        initialTime: _startTime.split(' ')[0] == '오전'
            ? TimeOfDay(
                hour: int.parse(_startTime.split(" ")[1].split(":")[0]),
                minute: int.parse(_startTime.split(" ")[1].split(":")[1]),
              )
            : TimeOfDay(
                hour: int.parse(_startTime.split(" ")[1].split(":")[0]) + 12,
                minute: int.parse(_startTime.split(" ")[1].split(":")[1]),
              ));
  }

  Animate FAB_Button_text(String text) {
    return Animate(
      effects: Left_Open,
      child: Offstage(
        offstage: false,
        child: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 3.0, color: MainColor),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          height: 30,
          width: 100,
          padding: EdgeInsets.only(top: 4),
          child: Text(text, style: TextStyle(color: TextColor)),
        ),
      ),
    );
  }

  Widget FAB_Button(String text, Widget icon, Function() Change_page) {
    return SizedBox(
      width: 50,
      height: 50,
      child: FittedBox(
        child: FloatingActionButton(
          elevation: 0.0,
          heroTag: text,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: BorderSide(width: 1.5, color: Color.fromRGBO(161, 196, 253, 1))),
          onPressed: Change_page,
          child: icon,
        ),
      ),
    );
  }

  AnimateIconController Anicontroller = AnimateIconController();

  Widget FAB_toggle() {
    return FloatingActionButton(
        shape: RoundedRectangleBorder(side: BorderSide(width: 3, color: isOpened ? Colors.red : ServeColor), borderRadius: BorderRadius.circular(100)),
        backgroundColor: _animateColor.value,
        elevation: 3,
        onPressed: () async {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.white, // 변경하려는 색상 설정
            systemNavigationBarColor: Colors.white,
            systemNavigationBarDividerColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ));
          await Get.to(() => Selected_image());
          setState(() {
            _taskController.getTasks();
          });
        },
        // animate,
        child: Icon(MyFlutterApp.SS_icon, color: MainColor, size: 50)
        // AnimateIcons(
        //     size: 50,
        //     startIcon: MyFlutterApp.SS_icon,
        //     startIconColor: MainColor,
        //     endIcon: MyFlutterApp.SS_icon,
        //     endIconColor: Colors.red,
        //     onStartIconPress: () {
        //       animate();
        //       return true;
        //     },
        //     onEndIconPress: () {
        //       animate();
        //       return true;
        //     },
        //     duration: Duration(milliseconds: 250),
        //     controller: Anicontroller)
        );
  }

  Drawer Drawer_Menu(User user) {
    // 메뉴
    return Drawer(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topRight: Radius.circular(50),
        bottomRight: Radius.circular(20),
      )),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topLeft,
            colors: [ServeColor, Colors.white], // 그래디언트 색상 설정
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 160,
              child: Theme(
                // 외곽 선을 투명으로 주기
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(50)), // ),
                  ),
                  // 사용자 정보
                  otherAccountsPictures: [
                    ElevatedButton(
                      onPressed: () {
                        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                          statusBarColor: MainColor, // 변경하려는 색상 설정
                          systemNavigationBarColor: MainColor,
                          systemNavigationBarDividerColor: MainColor,
                          systemNavigationBarIconBrightness: Brightness.light,
                        ));
                        FirebaseAuth.instance.signOut(); // 로그아웃
                        Fluttertoast.showToast(
                          msg: "로그아웃 되었습니다.",
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          fontSize: 15,
                          textColor: Colors.white,
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      },
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(children: [WidgetSpan(child: Icon(Icons.logout_rounded, color: MainColor, size: 15))]),
                          TextSpan(text: " 로그아웃 ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MainColor)),
                        ]),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            width: 1,
                            color: ServeColor,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    ),
                  ],
                  currentAccountPicture: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.person_sharp, size: 20))]),
                              TextSpan(text: "  ${user.displayName}", style: TextStyle(fontSize: 13, color: Colors.black)),
                            ]),
                          ),
                          SizedBox(height: 5),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.email, size: 20))]),
                              TextSpan(text: "  ${user.email}", style: TextStyle(fontSize: 13, color: Colors.black)),
                            ]),
                          ),
                          SizedBox(height: 5),
                        ],
                      )
                    ],
                  ),
                  currentAccountPictureSize: Size(200, 50),
                  otherAccountsPicturesSize: Size(100, 30),
                  accountName: Container(
                    margin: EdgeInsets.only(right: 20, top: 55),
                    child: Divider(color: Colors.black),
                  ),
                  accountEmail: Container(
                      margin: EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(children: [WidgetSpan(child: Icon(Icons.calendar_month_outlined, color: Colors.black, size: 20))]),
                                  TextSpan(text: "  총 일정 개수 : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                                  TextSpan(text: " ${_taskController.taskList.length}개", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MainColor)),
                                ]),
                              ),
                              TextButton(
                                onPressed: _taskController.taskList.length > 0
                                    ? () {
                                        setState(() {
                                          _taskController.deleteAll(); // 데이터베이스 초기화
                                          NotifyHeler.cancelAllScheduledNotification(); // 알림 초기화
                                          _taskController.getTasks();
                                          // NotifyHeler.showNotification(id: 9999, title: '초기화 완료 !', body: '${_taskController.taskList.length}개의 일정을 모두 삭제 했습니다.', fln: flutterLocalNotificationsPlugin);
                                          Fluttertoast.showToast(
                                            msg: "[ ${_taskController.taskList.length}개 ] 의 일정을 모두 삭제 했습니다.",
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                            fontSize: 15,
                                            textColor: Colors.white,
                                            toastLength: Toast.LENGTH_SHORT,
                                          );
                                        });
                                        Navigator.of(context).pop(); // 뒤로가기
                                      }
                                    : null,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(text: " 초기화", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _taskController.taskList.length > 0 ? Colors.red : Colors.grey)),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: My_latitude == 0.0 ? EdgeInsets.only(top: 10, bottom: 10) : EdgeInsets.only(),
                    child: Row(
                      mainAxisAlignment: My_latitude != 0.0 ? MainAxisAlignment.start : MainAxisAlignment.spaceEvenly,
                      children: [
                        My_latitude != 0.0
                            ? // 초기에는 안보이게 세팅
                            Container(
                                margin: EdgeInsets.only(),
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: 120,
                                child: SizedBox(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                    child: GoogleMap(
                                      mapToolbarEnabled: false,
                                      markers: Set.from(_markers), // 마커
                                      compassEnabled: false, // 나침반
                                      buildingsEnabled: false, // 건물 3인칭
                                      scrollGesturesEnabled: false, // 스크롤
                                      mapType: MapType.terrain, // 맵 타입
                                      zoomControlsEnabled: false, // 줌
                                      initialCameraPosition: _mylocation, // 초기 위치
                                      onMapCreated: (GoogleMapController controller) {
                                        if (!_controller.isCompleted) {
                                          _controller.complete(controller); // 이게 있어야 움직이네
                                        }
                                      },
                                    ),
                                  ),
                                ))
                            : Image.asset('assets/image/map.png', scale: 12),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(children: [WidgetSpan(child: Icon(Icons.location_on, color: Colors.black, size: 17))]),
                                  TextSpan(text: " 주소", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                                ]),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                // 검색한 주소 필드
                                child: Text(
                                  _locationController.text.isNotEmpty ? "${_locationController.text}" : "저장된 주소가 없습니다.",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  My_latitude == 0.0
                      ? Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _goToTheLake(); // 현 위치 주소찾기
                                },
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(children: [WidgetSpan(child: Icon(Icons.my_location_rounded, color: Colors.green, size: 20))]),
                                    TextSpan(text: "  현 위치", style: TextStyle(fontSize: 15, color: Colors.green)),
                                  ]),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // 카카오 도로명 주소
                                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                    statusBarColor: Colors.white, // 변경하려는 색상 설정
                                    systemNavigationBarColor: Colors.white,
                                    systemNavigationBarDividerColor: Colors.white,
                                    systemNavigationBarIconBrightness: Brightness.dark,
                                  ));
                                  Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView(kakaoKey: 'yourKey')));
                                  setState(() {
                                    if (_locController.locList.length >= 1) {
                                      _locController.deleteAll();
                                    }
                                    My_latitude = result.kakaoLatitude!;
                                    My_longitude = result.kakaoLongitude!;
                                    _mylocation = CameraPosition(
                                      target: LatLng(My_latitude, My_longitude),
                                      zoom: 16, // 카메라 확대 크기
                                    ); // 해당 위치로 카메라 위치 기입
                                    My_latlng = result.address;
                                  });
                                  await Change_Address();
                                  await Add_Marker(); // 마커 추가하기
                                  final GoogleMapController controller = await _controller.future;
                                  controller.moveCamera(
                                      // 기존의 카메라 위치를 지우기 위해 moveCamera 사용
                                      CameraUpdate.newCameraPosition(
                                    CameraPosition(target: LatLng(36, 127), zoom: 12),
                                  ));
                                  controller.animateCamera(CameraUpdate.newCameraPosition(_mylocation)); // 해당 위치로 카메라 이동
                                  controller.showMarkerInfoWindow(MarkerId("1")); // infowindow 열어두기
                                  _addloc();
                                },
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(children: [WidgetSpan(child: Icon(Icons.add_location_alt_outlined, color: Colors.blue, size: 20))]),
                                    My_latitude == 0.0 ? TextSpan(text: "  검색", style: TextStyle(fontSize: 15, color: Colors.blue)) : TextSpan(children: []),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            My_latitude != 0.0
                ? Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                width: 2,
                                color: Colors.green,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          onPressed: () {
                            _goToTheLake(); // 현 위치 주소찾기
                          },
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.my_location_rounded, color: Colors.green, size: 20))]),
                            ]),
                          ),
                        ),
                        SizedBox(width: 5),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                width: 2,
                                color: Colors.blue,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          onPressed: () async {
                            // 카카오 도로명 주소
                            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                              statusBarColor: Colors.white, // 변경하려는 색상 설정
                              systemNavigationBarColor: Colors.white,
                              systemNavigationBarDividerColor: Colors.white,
                              systemNavigationBarIconBrightness: Brightness.dark,
                            ));
                            Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView(kakaoKey: 'yourKey')));
                            setState(() {
                              if (_locController.locList.length >= 1) {
                                _locController.deleteAll();
                              }
                              My_latitude = result.kakaoLatitude!;
                              My_longitude = result.kakaoLongitude!;
                              _mylocation = CameraPosition(
                                target: LatLng(My_latitude, My_longitude),
                                zoom: 16, // 카메라 확대 크기
                              ); // 해당 위치로 카메라 위치 기입
                              My_latlng = result.address;
                            });
                            await Change_Address();
                            await Add_Marker(); // 마커 추가하기
                            final GoogleMapController controller = await _controller.future;
                            controller.moveCamera(
                                // 기존의 카메라 위치를 지우기 위해 moveCamera 사용
                                CameraUpdate.newCameraPosition(
                              CameraPosition(target: LatLng(36, 127), zoom: 12),
                            ));
                            controller.animateCamera(CameraUpdate.newCameraPosition(_mylocation)); // 해당 위치로 카메라 이동
                            controller.showMarkerInfoWindow(MarkerId("1")); // infowindow 열어두기
                            _addloc();
                          },
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.add_location_alt_outlined, color: Colors.blue, size: 20))]),
                            ]),
                          ),
                        ),
                        SizedBox(width: 5),
                        OutlinedButton(
                          // 주소 복사하기
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                width: 2,
                                color: Colors.black,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: "${_locationController.text}"));
                            Fluttertoast.showToast(
                              msg: "주소를 복사했습니다.",
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blue,
                              fontSize: 15,
                              textColor: Colors.white,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          },
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.copy, color: Colors.black, size: 20))]),
                            ]),
                          ),
                        ),
                        SizedBox(width: 5),
                        OutlinedButton(
                          // 주소 지우기
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                width: 2,
                                color: Colors.red,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          onPressed: () {
                            setState(() {
                              My_latitude = 0.0;
                              My_longitude = 0.0;
                              _locationController.text = "";
                              _locController.deleteAll();
                              _locController.getlocs();
                              Fluttertoast.showToast(
                                msg: "주소를 삭제했습니다.",
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                fontSize: 15,
                                textColor: Colors.white,
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            });
                          },
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(children: [WidgetSpan(child: Icon(Icons.playlist_remove_rounded, color: Colors.red, size: 20))]),
                            ]),
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                  )
                : Container(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // 뒤로가기
                    setState(() {
                      _isTextFieldOpen = false;
                      FocusManager.instance.primaryFocus?.unfocus(); // 키보드 내리기
                    });
                  },
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(children: [WidgetSpan(child: Icon(Icons.cancel_outlined, color: Colors.black, size: 18))]),
                      TextSpan(text: "  닫기 ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                    ]),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar App_bar(User user) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: IconButton(
        onPressed: () {
          setState(() {
            // isOpened = true; // FAB가 열려있다고 가정하고,
            // animate(); // 닫히게 한다.
            _isTextFieldOpen = false;
            FocusManager.instance.primaryFocus?.unfocus(); // 키보드 내리기
            _scaffoldKey.currentState?.openDrawer(); // Drawer 오픈
            check_loc(); // 데이터베이스 주소 가져오기
          });
        },
        icon: CircleAvatar(
          minRadius: 15,
          maxRadius: 15,
          backgroundColor: Colors.white,
          backgroundImage: user.photoURL != null ? NetworkImage('${user.photoURL}') : null,
        ),
      ),
      // title: Image.asset('assets/image/Main_Logo.png', scale: 3.5),
      leading: Container(),
      leadingWidth: 0,
      actions: [
        _taskController.taskList.length > 0
            ? TextButton(
                onPressed: () async {
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor: Colors.white, // 변경하려는 색상 설정
                    systemNavigationBarColor: Colors.white,
                    systemNavigationBarDividerColor: Colors.white,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ));
                  await Navigator.of(context).push(Add_task_Route());
                  _taskController.getTasks();
                  _locController.getlocs();
                  setState(() {
                    _isButtonPressed = false; // 날짜선택 위젯을 닫는다.
                    // isOpened = true; // FAB가 열려있다고 가정하고,
                    // animate(); // 닫히게 한다.
                  });
                },
                child: RichText(
                    text: TextSpan(
                  children: [
                    TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/non_task.png', width: 18, height: 18, color: MainColor))]),
                    TextSpan(text: " 일정 생성", style: TextStyle(color: MainColor, fontWeight: FontWeight.bold)),
                  ],
                )),
              )
            : Container(
                alignment: Alignment.center,
                child: Text("현재 일정이 없습니다.", style: TextStyle(color: Colors.grey)),
              ),
        SizedBox(width: 20),
      ],
    );
  }

  Selected_Schedule() {
    // TODAY 및 날짜 선택 종합 위젯
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isButtonPressed
              ? Animate(
                  effects: Left_Open,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isButtonPressed = false;
                        _selectedDate = DateTime.now();
                      });
                    },
                    child: Text("현재 날짜", style: TextStyle(color: MainColor)),
                    style: Serve_Style,
                  ),
                )
              : Container(),
          SizedBox(width: 10),
          !_isButtonPressed ? Expanded(child: Divider(color: MainColor)) : Container(),
          SelectedDate(),
          !_isButtonPressed ? Expanded(child: Divider(color: MainColor)) : Container(),
          SizedBox(width: 10),
          _isButtonPressed
              ? Animate(
                  effects: [FadeEffect(curve: Curves.ease), SlideEffect(curve: Curves.ease, duration: 350.ms, begin: Offset(-0.7, 0))],
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime? _pickerDate = await showDatePicker(
                          helpText: "날짜를 선택해주세요",
                          fieldHintText: "ex) 2020. 8. 7.",
                          fieldLabelText: "날짜를 입력해주세요 *띄어쓰기",
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2022),
                          lastDate: DateTime(2030),
                          confirmText: "선택");
                      if (_pickerDate != null) {
                        setState(() {
                          _isButtonPressed = false;
                          _selectedDate = _pickerDate;
                        });
                      }
                    },
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(children: [WidgetSpan(child: Icon(Icons.calendar_month_outlined, size: 20, color: MainColor)), TextSpan(text: " 달력", style: TextStyle(color: MainColor))])
                      ]),
                    ),
                    style: Serve_Style,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  ElevatedButton SelectedDate() {
    // TODAT
    bool isToday = _selectedDate.year == DateTime.now().year && _selectedDate.month == DateTime.now().month && _selectedDate.day == DateTime.now().day;
    // 선택한 날짜가 현재날짜와 동일한가?
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isButtonPressed = !_isButtonPressed;
        });
      },
      child: Text(
        _isButtonPressed // 버튼을 눌렀을때
            ? '${DateFormat("M / d").format(_selectedDate)}' // 날짜를 표시한다
            : isToday // 날짜를 선택했을때 현재날짜와 동일하면?
                ? 'TODAY'
                : '${DateFormat("M월 d일").format(_selectedDate)}', // 선택한 날짜를 표시한다
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        side: _isButtonPressed ? BorderSide(width: 2) : null,
        padding: EdgeInsets.symmetric(horizontal: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        backgroundColor: _isButtonPressed ? MainColor : ServeColor,
        shadowColor: Shadow_Color,
        elevation: 4,
      ),
    );
  }

  Task_List() {
    // // Task를 날짜와 시간에 따라 정렬
    // _taskController.taskList.sort((task1, task2) {
    //   // Task1과 Task2의 날짜와 시간을 DateTime으로 변환
    //   DateTime dateTime1 = DateFormat("a h:mm", 'ko').parse("${task1.Start_Time}");
    //   DateTime dateTime2 = DateFormat("a h:mm", 'ko').parse("${task2.Start_Time}");

    //   // 두 DateTime을 비교하여 내림차순으로 정렬
    //   return dateTime2.compareTo(dateTime1);
    // });

    return Expanded(
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index];
              // print(_taskController.taskList.length); // 데이터베이스 길이
              print(task.toJson()); // 데이터베이스 내용
              if (task.repeat == 1) {
                // 1 : 매일 반복
                DateTime date = DateFormat("a h:mm", 'ko').parse(task.Start_Time.toString());
                var mytime = DateFormat("HH:mm").format(date);
                NotifyHeler.scheduledNotification(int.parse(mytime.toString().split(":")[0]), int.parse(mytime.toString().split(":")[1]), task);
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (_locController.locList.length >= 1) {
                                locations loc = _locController.locList[0];
                                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                  statusBarColor: Color.fromARGB(0, 255, 255, 255), // 변경하려는 색상 설정
                                  statusBarBrightness: Brightness.dark,
                                  statusBarIconBrightness: Brightness.dark,
                                  systemNavigationBarColor: Colors.white,
                                  systemNavigationBarDividerColor: Colors.white,
                                  systemNavigationBarIconBrightness: Brightness.dark,
                                ));
                                await Get.to(() => Task_page(loc: loc, task: task));
                              } else {
                                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                  statusBarColor: Color.fromARGB(0, 255, 255, 255), // 변경하려는 색상 설정
                                  statusBarBrightness: Brightness.dark,
                                  statusBarIconBrightness: Brightness.dark,
                                  systemNavigationBarColor: Colors.white,
                                  systemNavigationBarDividerColor: Colors.white,
                                  systemNavigationBarIconBrightness: Brightness.dark,
                                ));
                                await Get.to(() => Task_page(task: task));
                              }
                            },
                            child: TaskTile(task),
                          )
                        ],
                      )),
                    ));
              }
              if (task.Start_Date == DateFormat('yyyy-MM-dd').format(_selectedDate)) {
                DateTime date = DateFormat("a h:mm", 'ko').parse(task.Start_Time.toString());
                var mytime = DateFormat("HH:mm").format(date);
                NotifyHeler.scheduledNotification(int.parse(mytime.toString().split(":")[0]), int.parse(mytime.toString().split(":")[1]), task);
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (_locController.locList.length >= 1) {
                                locations loc = _locController.locList[0];
                                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                  statusBarColor: Color.fromARGB(0, 255, 255, 255), // 변경하려는 색상 설정
                                  statusBarBrightness: Brightness.dark,
                                  statusBarIconBrightness: Brightness.dark,
                                  systemNavigationBarColor: Colors.white,
                                  systemNavigationBarDividerColor: Colors.white,
                                  systemNavigationBarIconBrightness: Brightness.dark,
                                ));
                                await Get.to(() => Task_page(loc: loc, task: task));
                              } else {
                                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                  statusBarColor: Color.fromARGB(0, 255, 255, 255), // 변경하려는 색상 설정
                                  statusBarBrightness: Brightness.dark,
                                  statusBarIconBrightness: Brightness.dark,
                                  systemNavigationBarColor: Colors.white,
                                  systemNavigationBarDividerColor: Colors.white,
                                  systemNavigationBarIconBrightness: Brightness.dark,
                                ));
                                await Get.to(() => Task_page(task: task));
                              }
                            },
                            child: TaskTile(task),
                          )
                        ],
                      )),
                    ));
              } else {
                return Container();
              }
            });
      }),
    );
  }

  _add_Task() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: DottedBorder(
          color: Colors.grey,
          dashPattern: [6],
          strokeWidth: 1,
          borderType: BorderType.RRect,
          radius: Radius.circular(16),
          padding: EdgeInsets.all(6),
          strokeCap: StrokeCap.round,
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // 원형 모양을 위한 반지름 값 설정
                      )),
                  onPressed: () async {
                    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                      statusBarColor: Colors.white, // 변경하려는 색상 설정
                      systemNavigationBarColor: Colors.white,
                      systemNavigationBarDividerColor: Colors.white,
                      systemNavigationBarIconBrightness: Brightness.dark,
                    ));
                    await Navigator.of(context).push(Add_task_Route());
                    _taskController.getTasks();
                    _locController.getlocs();
                    setState(() {
                      _startDate = DateTime.now();
                      _isButtonPressed = false; // 날짜선택 위젯을 닫는다.
                      // isOpened = true; // FAB가 열려있다고 가정하고,
                      // animate(); // 닫히게 한다.
                    });
                  },
                  child: RichText(
                      text: TextSpan(
                    children: [
                      TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/non_task.png', scale: 14, color: MainColor))]),
                    ],
                  )))),
        ));
  }

  _Schedule_List() {
    // 날짜 리스트
    return Container(
      decoration: BoxDecoration(border: Border.all(color: MainColor), borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.only(left: 40, right: 40, top: 5),
      child: DatePicker(
        DateTime.now(),
        monthTextStyle: TextStyle(fontSize: 15),
        dateTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        dayTextStyle: TextStyle(fontSize: 15),
        height: 80,
        width: 60,
        initialSelectedDate: _selectedDate,
        selectionColor: MainColor,
        selectedTextColor: Colors.black,
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        locale: 'ko',
      ),
    );
  }
}
