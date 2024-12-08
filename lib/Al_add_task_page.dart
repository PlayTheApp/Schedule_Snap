import 'dart:async';
import 'dart:convert';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kpostal/kpostal.dart';
import 'package:schedule_snap/controllers/notify_service.dart';
import 'package:schedule_snap/style.dart'; // 기본
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';

import 'Home.dart';
import 'controllers/location_controller.dart';
import 'controllers/task_controller.dart';
import 'model/location.dart';
import 'model/task.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // 알림 관련

class Al_add_task_page extends StatefulWidget {
  final String? responses;
  final locations? loc;

  const Al_add_task_page({super.key, required this.responses, this.loc});

  @override
  State<Al_add_task_page> createState() => _Al_add_task_pageState();
}

class _Al_add_task_pageState extends State<Al_add_task_page> {
  String? titles = null;
  String? Detail = null;
  String? keyword = null;
  DateTime StartDate = DateTime.now();
  DateTime StartTime = DateTime.now();
  DateTime EndDate = DateTime.now();
  DateTime EndTime = DateTime.now();
  String? Place = null;
  String? URL = null;

  final locController _locController = Get.put(locController());
  final TaskController _taskController = Get.put(TaskController()); // 데이터베이스
  final TextEditingController Title_Text = TextEditingController(); // 제목
  late bool _isTitle_Text = false; // 제목이 채워져 있는가?

  DateTime Start_Date = DateTime.now();
  DateTime End_Date = DateTime.now();
  late bool _isToday = false; // 현재 날짜와 다른가?

  String _nowTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 현재 시간
  String _todayTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 현재 시간
  String _startTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 시작 시간
  String _endTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString(); // 마감 시간
  late bool _isTime = false; // 시작 과 마감 시간이 현재 시간과 다른가?

  int daysDifference = 0;
  int hoursDifference = 0;
  int minutesDifference = 0;

  int daysDiffnow = 0;
  int hoursDiffnow = 0;
  int minutesDiffnow = 0;

  String _keywordValue = "기타";
  List<String> keywordList = ["기념일", "대회", "공연", "축제", "운동", "모임", "여가", "예약", "공부", "업무", "기타"];
  late bool _isKeyword = false;

  int alarmValue = 1; // 알림 index
  List<String> alarmList = [" 1분 전 ", " 5분 전 ", " 10분 전 ", " 30분 전 ", " 1시간 전 "];
  late List<bool> _isalarmList = List.generate(alarmList.length, (index) => index == 1); // 5분 전이 기본값 (true)
  late bool _isalarm = false;

  int repeatValue = 0; // 반복 index
  List<String> repeatList = [" 없음 ", " 매 일 ", " 매 주 ", " 매 달 ", " 매 년 "];
  late List<bool> _isrepeatList = List.generate(repeatList.length, (index) => index == 0); // 없음이 기본값 (true)
  late bool _isrepeat = false;

  final TextEditingController Detail_Text = TextEditingController(); // 제목
  late bool _isDetail_Text = false; // 제목이 채워져 있는가?

  final TextEditingController _startlocation = TextEditingController(); // 출발지
  final TextEditingController _endlocation = TextEditingController(); // 도착지

  late bool _isaddress = false; // 주소가 채워져 있는가?

  double start_lat = 0.0; // 출발지 위도
  double start_lng = 0.0; // 출발지 경도
  double end_lat = 0.0; // 도착지 위도
  double end_lng = 0.0; // 도착지 경도

  String km = ""; // 거리
  String time = ""; // 소요시간

  Set<Marker> _marker = Set<Marker>();
  late Uint8List start_markerIcon;
  late Uint8List end_markerIcon;

  Completer<GoogleMapController> _controller = Completer(); // 구글 맵 컨트롤러
  Set<Polyline> _polylines = Set<Polyline>(); // 구글 맵 선
  int _polylineIdCounter = 1; // 구글 맵 선 관련 함수

  final TextEditingController Comment_Text = TextEditingController(); // 특이사항
  late bool _iscomment = false; // 특이사항의 텍스트 필드가 채워져있는가?

  int values = 0; // 사이트(0)/앱(1) 열기 변수값

  final TextEditingController URL_Text = TextEditingController(); // 사이트 열기
  late bool _isurl = false; // 사이트 열기의 텍스트 필드가 채워져있는가?

  late Future<List<Application>> _appsFuture; // 설치된 앱 리스트
  final TextEditingController open_app = TextEditingController(); // 앱 열기
  String app_name = "";
  late bool _isapp = false;
  late Widget appIconWidget;

  @override
  void initState() {
    setCustomMapPin(); // 마커 이미지 변환
    super.initState();
    fetchData(); // 이미지에서 텍스트 추출
    _locController.getlocs(); // 현위치 주소값 가져오기
    getDBloc(); // 현위치 주소값 불러오기 (출발지)
    getPlace(); // 받은 장소의 주소, lat, lng 변환 (도착지)
    Check_field(); // 필드에 값이 들어있는지 체크
    Check_All(); // 모두 검사
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchData() async {
    // 이미지에서 텍스트 추출
    final response = widget.responses;
    Map<String, dynamic> jsonData = json.decode(response!) as Map<String, dynamic>;
    if (jsonData.isNotEmpty) {
      titles = jsonData['Subject'];
      Detail = jsonData['Contents'];
      keyword = jsonData['Category'];
      StartDate = DateTime.parse(jsonData['StartDate']);
      // StartTime = jsonData['StartTime'];
      EndDate = DateTime.parse(jsonData['EndDate']);
      // EndTime = DateTime.parse(jsonData['EndTime']);
      Place = jsonData['Place'];
    } else {
      throw Exception('Failed to fetch data');
      // title = "추출된 제목이 없습니다.";
      // comment = "추출된 내용이 없습니다.";
    }

    setState(() {
      Title_Text.text = titles!;
      _keywordValue = keyword!;
      Detail_Text.text = Detail!;
      Start_Date = StartDate;
      // Starts_Time = DateFormat("hh:mm a").format(StartTime).toString();
      End_Date = EndDate;
      // _startTime  = DateFormat("hh:mm a").format(StartTime).toString();
      // _endTime = DateFormat("hh:mm a").format(EndTime).toString();
    });
  }

  Check_field() {
    Check_Title_text();
    Check_Start_Date();
    Check_End_Date();
    Check_Time();
    Check_Keyword();
    Check_Alarm();
    Check_repeat();
    Check_Address();
    Check_Comment();
    Check_Detail_text();
    Check_URL();
    Check_app();
  }

  Check_All() {
    // 전부 확인
    return _isTitle_Text || _isToday || _isTime || _isKeyword || _isalarm || _isrepeat || _isDetail_Text || _isaddress || _iscomment || _isurl || _isapp;
  }

  Check_Title_text() {
    // 제목 필드가 채워져 있는지 확인
    _isTitle_Text = Title_Text.text.isNotEmpty;
  }

  Check_Start_Date() {
    // 날짜가 다른지 확인
    _isToday = Start_Date.year != DateTime.now().year || Start_Date.month != DateTime.now().month || Start_Date.day != DateTime.now().day;
  }

  Check_End_Date() {
    // 날짜가 다른지 확인
    _isToday = End_Date.year != DateTime.now().year || End_Date.month != DateTime.now().month || End_Date.day != DateTime.now().day;
  }

  Check_Time() {
    // 시간이 다른지 확인
    _isTime = _startTime != _todayTime || _endTime != _todayTime;
  }

  Check_Keyword() {
    // 키워드가 "기타"가 아닌지 확인
    _isKeyword = (_keywordValue != "기타");
  }

  Check_Alarm() {
    // 알림이 기본값(5분 전)인지 아닌지 확인
    _isalarm = (!_isalarmList[1]);
  }

  Check_repeat() {
    // 반복이 기본값(없음)인지 아닌지 확인
    _isrepeat = (!_isrepeatList[0]);
  }

  Check_Address() {
    // 장소 필드가 채워져 있는지 확인 (출발지 + 도착지)
    _isaddress = _startlocation.text.isNotEmpty || _endlocation.text.isNotEmpty;
  }

  Check_Comment() {
    // 특이사항이 채워져 있는지 확인
    _iscomment = Comment_Text.text.isNotEmpty;
  }

  Check_Detail_text() {
    // 내용 필드가 채워져 있는지 확인
    _isDetail_Text = Detail_Text.text.isNotEmpty;
  }

  Check_URL() {
    // URL이 채워져 있는지 확인
    _isurl = URL_Text.text.isNotEmpty;
  }

  Check_app() {
    _isapp = open_app.text.isNotEmpty;
  }

  getDBloc() async {
    if (_locController.locList.length >= 1) {
      setState(() {
        _startlocation.text = widget.loc!.loc!;
        start_lat = widget.loc!.lat!;
        start_lng = widget.loc!.lng!;
        print("${_startlocation.text}");
        _setMarker('출발지', LatLng(start_lat, start_lng), start_markerIcon); // 해당 위치로 마커 생성
      });
    }
  }

  void _setMarker(String id, LatLng point, Uint8List marker) {
    // 마커 생성
    setState(() {
      _marker.add(Marker(
        markerId: MarkerId(id),
        infoWindow: InfoWindow(title: id),
        position: point,
        onTap: null,
        icon: BitmapDescriptor.fromBytes(marker),
      ));
    });
  }

  void setCustomMapPin() async {
    // 마커 변환
    start_markerIcon = await getBytesFromAsset('assets/image/start_marker.png', 100);
    end_markerIcon = await getBytesFromAsset('assets/image/end_marker.png', 100);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    // 마커 이미지 변환
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  getPlace() async {
    // 장소(Place)에 대한 주소, lat, lng
    final String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$Place&key={yourKey}&language=ko';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    var results = {
      'address': json['results'][0]['formatted_address'],
      'lat': json['results'][0]['geometry']['location']['lat'],
      'lng': json['results'][0]['geometry']['location']['lng'],
    };

    setState(() {
      _endlocation.text = results['address'];
      end_lat = results['lat'];
      end_lng = results['lng'];
      _setMarker('도착지', LatLng(end_lat, end_lng), end_markerIcon); // 해당 위치로 마커 생성
    });
  }

  Future<Map<String, dynamic>> getDirections() async {
    // 구글 directions API
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$start_lat,$start_lng&destination=$end_lat,$end_lng&mode=transit&key={yourKey}&language=ko';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'km': json['routes'][0]['legs'][0]['distance']['text'],
      'time': json['routes'][0]['legs'][0]['duration']['text'],
      'polyline_decoded': PolylinePoints().decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };

    return results;
  }

  Future<void> _goToPlace(double lat, double lng, Map<String, dynamic> boundsNe, Map<String, dynamic> boundsSw) async {
    // 카메라 이동 (구글 맵)
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(
      // 기존의 카메라 위치를 지우기 위해 moveCamera 사용
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.showMarkerInfoWindow(MarkerId("목적지")); // infowindow 열어두기

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    setState(() {
      _polylines.clear(); // 다시 검색요청을 했을때 기존에 그렸던 선을 제거하기 위한 용도
    });

    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      // 선 생성
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  find_Route() async {
    // 출발지 - 목적지 경로 찾는 함수
    var directions = await getDirections(); // 구글 directions API
    _goToPlace(
      // 해당 좌표로 카메라 이동
      directions['start_location']['lat'], // 출발지 위도
      directions['start_location']['lng'], // 출발지 경도
      directions['bounds_ne'], // ne 범위
      directions['bounds_sw'], // sw 범위
    );
    _setPolyline(directions['polyline_decoded']); // 선 그리기
    setState(() {
      km = directions['km'];
      time = directions['time'];
    });
  }

  final GlobalKey _widgetKey = GlobalKey(); // 제목 포커스 용도
  final GlobalKey _widgetKey2 = GlobalKey(); // 내용 포커스 용도
  final GlobalKey _widgetKey3 = GlobalKey(); // 특이사항 포커스 용도
  final GlobalKey _widgetKey4 = GlobalKey(); // 일정 시작시 행동 포커스 용도

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
        appBar: Add_task_AppBar(),
        body: Container(
          padding: EdgeInsets.only(left: 20, right: 20), // 양 끝의 여백을 주기 위함
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text_Field(20, _widgetKey, " 제목", 46, 17, 1, () => _isTitle_Text = Title_Text.text.isNotEmpty, Title_Text, _isTitle_Text, () {
                  Title_Text.clear();
                  Check_Title_text();
                }, "\"제목을 입력해주세요.\""), // 제목
                Date_Field(),
                Keyword_Field(), // 키워드
                Toggle_Field("alarm", " 알림", alarmList, _isalarmList, () => Check_Alarm()), // 알림
                Toggle_Field("repeat", " 반복", repeatList, _isrepeatList, () => Check_repeat()), // 반복
                Choice_Line(), // 선택 사항
                Text_Field(20, _widgetKey2, " 내용", 250, 15, 15, () => _isDetail_Text = Detail_Text.text.isNotEmpty, Detail_Text, _isDetail_Text, () {
                  Detail_Text.clear();
                  Check_Detail_text();
                }, "\"내용을 입력해주세요.\""), // 내용
                Directions(), // 장소
                Text_Field(20, _widgetKey3, " 특이사항", 46, 17, 1, () => _iscomment = Comment_Text.text.isNotEmpty, Comment_Text, _iscomment, () {
                  Comment_Text.clear();
                  Check_Comment();
                }, "\"해당 내용은 알림에 공지됩니다.\""), // 특이사항
                Start_Open_Action(), // 일정 시작시 행동
                SizedBox(height: 100), // 여백 공간
              ],
            ),
          ),
        ),
        bottomSheet: Bottom_Button(), // 일정 생성 버튼
      ),
    );
  }

  AppBar Add_task_AppBar() {
    // 상단바
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
      title: Text("일정 추가", style: TextStyle(color: Colors.black, fontSize: 18)),
      centerTitle: true, // title을 가운데에 위치
      actions: [
        TextButton(
          // 전체 초기화
          onPressed: Check_All()
              ? () {
                  FocusScope.of(context).unfocus(); // 키보드 내리기
                  setState(() {
                    Title_Text.clear();
                    Start_Date = DateTime.now();
                    End_Date = DateTime.now();
                    _nowTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString();
                    _todayTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString();
                    _startTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString();
                    _endTime = DateFormat("a h:mm", 'ko').format(DateTime.now()).toString();
                    _isTime = Check_All(); // _isTime 값 갱신
                    _isTitle_Text = Title_Text.text.isNotEmpty;
                    _keywordValue = "기타";
                    alarmValue = 1;
                    repeatValue = 0;
                    _isalarmList = [false, true, false, false, false];
                    _isrepeatList = [true, false, false, false, false];
                    Detail_Text.clear();
                    _isDetail_Text = Detail_Text.text.isNotEmpty;
                    _startlocation.clear();
                    _endlocation.clear();
                    km = "";
                    time = "";
                    Comment_Text.clear();
                    URL_Text.clear();
                    open_app.clear();
                    appIconWidget = Container();
                    app_name = "";
                    values = 0;
                    Check_Title_text();
                    Check_Start_Date();
                    Check_End_Date();
                    Check_Time();
                    Check_Keyword();
                    Check_Alarm();
                    Check_repeat();
                    Check_Detail_text();
                    Check_Address();
                    Check_Comment();
                    Check_URL();
                    Check_app();
                  });
                }
              : null,
          child: Text("초기화", style: TextStyle(color: Check_All() ? Colors.red : Colors.grey)),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Text_Field(
      double top, GlobalKey keys, String Text_title, double height, double fontsize, int Lines, Function() onChanged, TextEditingController controller, bool _istext, Function() onTap, String hint) {
    // 제목 & 내용
    return Container(
      margin: EdgeInsets.only(top: top, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          top != 0
              ? RichText(
                  key: keys,
                  text: TextSpan(
                    children: [
                      TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/Title_text.png', width: 18, height: 18))]),
                      TextSpan(text: Text_title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ))
              : Container(),
          Container(
            height: height,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 14),
            decoration: Add_task_style(button_Color),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: TextStyle(fontSize: fontsize),
                    onTap: () {
                      Scrollable.ensureVisible(keys.currentContext!);
                    },
                    maxLines: Lines,
                    onChanged: (value) {
                      // 텍스트가 들어갔을때 초기화 활성화
                      setState(() {
                        onChanged(); // 초기에 비어있는지 확인
                      });
                    },
                    controller: controller, // 텍스트가 들어가는 부분
                    autofocus: false,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          // 지우기 버튼
                          child: Icon(Icons.cancel_outlined, color: _istext ? Colors.black : Colors.white, size: 20),
                          onTap: _istext
                              ? () {
                                  setState(() {
                                    onTap();
                                  });
                                }
                              : null,
                        ),
                        hintText: hint,
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
        ],
      ),
    );
  }

  Text_Field_site(
      double top, GlobalKey keys, String Text_title, double height, double fontsize, int Lines, Function() onChanged, TextEditingController controller, bool _istext, Function() onTap, String hint) {
    // 제목 & 내용
    return Container(
      margin: EdgeInsets.only(top: top, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          top != 0
              ? RichText(
                  key: keys,
                  text: TextSpan(
                    children: [
                      TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/Title_text.png', width: 18, height: 18))]),
                      TextSpan(text: Text_title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ))
              : Container(),
          Container(
            height: height,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 14),
            decoration: Add_task_style(button_Color),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: TextStyle(fontSize: fontsize),
                    onTap: () {
                      Scrollable.ensureVisible(keys.currentContext!);
                    },
                    maxLines: Lines,
                    onChanged: (value) {
                      // 텍스트가 들어갔을때 초기화 활성화
                      setState(() {
                        onChanged(); // 초기에 비어있는지 확인
                      });
                    },
                    controller: controller, // 텍스트가 들어가는 부분
                    autofocus: false,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        label: Text("https://"),
                        suffixIcon: GestureDetector(
                          // 지우기 버튼
                          child: Icon(Icons.cancel_outlined, color: _istext ? Colors.black : Colors.white, size: 20),
                          onTap: _istext
                              ? () {
                                  setState(() {
                                    onTap();
                                  });
                                }
                              : null,
                        ),
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
        ],
      ),
    );
  }

  Date_Field() {
    // 날짜

    // 날짜 차이를 변환
    DateTime startDateTime = DateTime(Start_Date.year, Start_Date.month, Start_Date.day);
    DateTime endDateTime = DateTime(End_Date.year, End_Date.month, End_Date.day);

    Duration difference_Date = endDateTime.difference(startDateTime);

    // 음수 시간 차이를 양수로 변환
    DateTime nowTime = DateFormat("a h:mm", 'ko').parse(_nowTime);
    DateTime startTime = DateFormat("a h:mm", 'ko').parse(_startTime);
    DateTime endTime = DateFormat("a h:mm", 'ko').parse(_endTime);

    Duration diff_now = startTime.difference(nowTime); // 현재시간과 일정 시작 시간 차이
    Duration difference_Time = endTime.difference(startTime); // 일정 시작 - 마감 차이

    if (difference_Time.isNegative) {
      difference_Time = Duration(hours: 24) + difference_Time;
    } else if (diff_now.isNegative) {
      diff_now = Duration(hours: 24) + diff_now;
    }

    daysDiffnow = diff_now.inDays;
    hoursDiffnow = diff_now.inHours;
    minutesDiffnow = diff_now.inMinutes.remainder(60);

    daysDifference = difference_Date.inDays;
    hoursDifference = difference_Time.inHours;
    minutesDifference = difference_Time.inMinutes.remainder(60);

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/Date.png', width: 20, height: 18))]),
                  TextSpan(text: ' 날짜', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      daysDiffnow == 0
                          ? ""
                          : daysDiffnow > 0
                              ? "$daysDiffnow일 "
                              : "[ Error ]",
                      style: TextStyle(color: MainColor),
                      textAlign: TextAlign.center),
                  Text(
                      (hoursDiffnow >= 0 && minutesDiffnow >= 0)
                          ? (hoursDiffnow == 0 && minutesDiffnow == 0)
                              ? ""
                              : (hoursDiffnow == 0)
                                  ? "$minutesDiffnow분 "
                                  : (minutesDiffnow == 0)
                                      ? "$hoursDiffnow시간 "
                                      : "$hoursDiffnow시간 $minutesDiffnow분 "
                          : "[ Error ] ",
                      style: TextStyle(color: MainColor),
                      textAlign: TextAlign.center),
                  Text((daysDiffnow > 0 || (hoursDiffnow != 0) || (minutesDiffnow != 0)) ? "후" : "", style: TextStyle(color: MainColor), textAlign: TextAlign.center),
                ],
              )
            ],
          ),
          Divider(color: Colors.black),
          Container(
            // 시작 날짜
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.access_time_outlined, size: 25, color: MainColor),
                    Container(
                      child: Date_Button(Start_Date, (selectedDate) {
                        setState(() {
                          Start_Date = selectedDate;
                          End_Date = selectedDate; // 주는 이유는, 날짜 선택을 빠르게 하기 위함
                          Check_Start_Date();
                        });
                      }),
                    ),
                  ],
                ),
                Container(
                  child: Selected_Time_Button(_startTime, () => getTimeFromUser(isStartTime: true)),
                ),
              ],
            ),
          ),
          Container(
            // 마감 날짜
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.access_time_filled_outlined, size: 25, color: MainColor),
                    Container(
                      child: Date_Button(End_Date, (selectedDate) {
                        setState(() {
                          End_Date = selectedDate;
                          Check_End_Date();
                        });
                      }),
                    ),
                  ],
                ),
                Container(
                  child: Selected_Time_Button(_endTime, () => getTimeFromUser(isStartTime: false)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton Date_Button(DateTime Date, Function(DateTime) onDateSelected) {
    // 날짜 선택
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () async {
          FocusScope.of(context).unfocus(); // 키보드 내리기
          DateTime? _pickerDate = await showDatePicker(
              // 달력 표시
              helpText: "날짜를 선택해주세요",
              fieldHintText: "ex) 2020. 8. 7.",
              fieldLabelText: "날짜를 입력해주세요 *띄어쓰기",
              context: context,
              initialDate: Start_Date,
              firstDate: DateTime(2022),
              lastDate: DateTime(2030),
              confirmText: "선택");
          if (_pickerDate != null) {
            onDateSelected(_pickerDate);
          }
        },
        child: Text(" ${DateFormat("yyyy년 M월 d일").format(Date)}", style: TextStyle(color: Colors.black, fontSize: 15)));
  }

  ElevatedButton Selected_Time_Button(String text, Function() Select_Time) {
    // 시간 선택
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          FocusScope.of(context).unfocus(); // 키보드 내리기
          Select_Time();
        },
        child: Text(" $text", style: TextStyle(color: Colors.black, fontSize: 15)));
  }

  getTimeFromUser({required bool isStartTime}) async {
    // 유저가 선택한 시간을 받아오는 함수
    var pickedTime = await _showTimePicker(isStartTime) ?? TimeOfDay.now(); // 취소 버튼을 눌렀을때 null 값 대체
    String _formatedTime = pickedTime.format(context);
    if (pickedTime == null) {
      print("취소하였습니다.");
    } else if (isStartTime == true) {
      setState(() {
        _startTime = _formatedTime;
        _endTime = _formatedTime;
        Check_Time();
      });
    } else if (isStartTime == false) {
      setState(() {
        _endTime = _formatedTime;
        Check_Time();
      });
    }
  }

  _showTimePicker(bool isStartTime) {
    return showTimePicker(
        context: context,
        initialTime: isStartTime
            ? _startTime.split(' ')[0] == '오전'
                ? TimeOfDay(
                    hour: int.parse(_startTime.split(" ")[1].split(":")[0]),
                    minute: int.parse(_startTime.split(" ")[1].split(":")[1]),
                  )
                : TimeOfDay(
                    hour: int.parse(_startTime.split(" ")[1].split(":")[0]) + 12,
                    minute: int.parse(_startTime.split(" ")[1].split(":")[1]),
                  )
            : _endTime.split(' ')[0] == '오전'
                ? TimeOfDay(
                    hour: int.parse(_endTime.split(" ")[1].split(":")[0]),
                    minute: int.parse(_endTime.split(" ")[1].split(":")[1]),
                  )
                : TimeOfDay(
                    hour: int.parse(_endTime.split(" ")[1].split(":")[0]) + 12,
                    minute: int.parse(_endTime.split(" ")[1].split(":")[1]),
                  ));
  }

  Keyword_Field() {
    // 키워드
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/keyword.png', width: 20, height: 18))]),
                  TextSpan(text: ' 키워드', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              )),
              Container(
                decoration: Add_task_style(button_Color),
                padding: EdgeInsets.only(left: 10),
                alignment: Alignment.center,
                width: 230,
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
                      Check_Keyword();
                    });
                  }),
                ),
              ),
            ],
          ),
        ),
        _keywordValue == "기념일"
            ? Keyword_icon('assets/image/Anniversary.png', 13)
            : _keywordValue == "대회"
                ? Keyword_icon('assets/image/Contest.png', 10)
                : _keywordValue == "공연"
                    ? Keyword_icon('assets/image/show.png', 11)
                    : _keywordValue == "축제"
                        ? Keyword_icon('assets/image/Event.png', 11)
                        : _keywordValue == "운동"
                            ? Keyword_icon('assets/image/Exercise.png', 11)
                            : _keywordValue == "모임"
                                ? Keyword_icon('assets/image/Gathering.png', 11)
                                : _keywordValue == "여가"
                                    ? Keyword_icon('assets/image/Leisure.png', 11)
                                    : _keywordValue == "예약"
                                        ? Keyword_icon('assets/image/Reservation.png', 11)
                                        : _keywordValue == "공부"
                                            ? Keyword_icon('assets/image/Study.png', 10)
                                            : _keywordValue == "업무"
                                                ? Keyword_icon('assets/image/Work.png', 11)
                                                : SizedBox.shrink(),
      ],
    );
  }

  Toggle_Field(String image, String Toggle_title, List<String> list, List<bool> listbool, Function() Check) {
    // 알림 및 반복 필드
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
              text: TextSpan(
            children: [
              TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/${image}.png', width: 20, height: 18))]),
              TextSpan(text: Toggle_title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          )),
          Container(
            alignment: Alignment.centerRight,
            width: 300,
            height: 50,
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(10),
                    borderWidth: 2,
                    children: list.map((alarm) => Text(alarm)).toList(),
                    isSelected: listbool,
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0; buttonIndex < listbool.length; buttonIndex++) {
                          if (buttonIndex == index) {
                            listbool[buttonIndex] = true;
                            list == alarmList
                                ? alarmValue = buttonIndex
                                : list == repeatList
                                    ? repeatValue = buttonIndex
                                    : null;
                          } else {
                            listbool[buttonIndex] = false;
                          }
                        }
                        Check();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Choice_Line() {
    // 선택 사항 구분 용도 라인
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Row(
        children: [
          Expanded(child: Divider(color: MainColor, thickness: 2)),
          Container(
            decoration: Add_task_style(MainColor),
            alignment: Alignment.center,
            width: 80,
            height: 20,
            child: Text("선택 사항", style: TextStyle(fontSize: 13, color: MainColor)),
          ),
          Expanded(child: Divider(color: MainColor, thickness: 2)),
        ],
      ),
    );
  }

  Directions() {
    // 장소
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
                text: TextSpan(
              children: [
                TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/location.png', width: 20, height: 18))]),
                TextSpan(text: ' 장소', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            )),
            RichText(
              text: TextSpan(children: [
                TextSpan(text: km.isNotEmpty ? "거리 : " : "", style: TextStyle(color: Colors.black, fontSize: 15)),
                TextSpan(text: km.isNotEmpty ? " $km " : "", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
                TextSpan(text: time.isNotEmpty ? " / 소요시간 : " : "", style: TextStyle(color: Colors.black, fontSize: 15)),
                TextSpan(text: time.isNotEmpty ? " $time " : "", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ),
        Divider(color: Colors.black),
        (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty)
            ? Container(
                height: (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty) ? 300 : 150,
                width: double.infinity,
                margin: EdgeInsets.only(top: 10, bottom: 10),
                decoration: Add_task_style(button_Color),
                child: SizedBox(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    child: (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty)
                        ? GoogleMap(
                            zoomGesturesEnabled: false, // 확대
                            compassEnabled: false, // 나침반
                            buildingsEnabled: false, // 건물 3인칭
                            scrollGesturesEnabled: false, // 스크롤
                            mapType: MapType.normal, // 맵 타입
                            zoomControlsEnabled: false, // 줌
                            initialCameraPosition: CameraPosition(
                              target: LatLng(end_lat, end_lng),
                              zoom: 15, // 카메라 확대 크기
                            ), // 초기 위치
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            markers: _marker,
                            polylines: _polylines,
                          )
                        : Container(
                            alignment: Alignment.center,
                            child: Text("출발지와 목적지를 입력해주세요", style: TextStyle(color: Colors.grey)),
                          ),
                  ),
                ))
            : Container(),
        Container(
          width: double.infinity,
          height: 110,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: MainColor,
                        radius: 12,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 10,
                      ),
                      CircleAvatar(
                        backgroundColor: MainColor,
                        radius: 5,
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.red[100],
                            radius: 3,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.red[300],
                            radius: 3,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.red[500],
                            radius: 3,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.location_on, size: 30, color: Colors.red),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 320,
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: _startlocation.text.isNotEmpty ? BorderSide(width: 1, color: MainColor) : null,
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView(kakaoKey: 'yourKey')));
                        setState(() {
                          _startlocation.text = result.address; // 도로명 주소 값
                          start_lat = result.kakaoLatitude!; // 도로명 주소 값의 위도
                          start_lng = result.kakaoLongitude!; // 도로명 주소 값의 경도
                          _setMarker('출발지', LatLng(start_lat, start_lng), start_markerIcon); // 해당 위치로 마커 생성
                          Check_Address();
                        });
                      },
                      child: Text(
                          _startlocation.text.isNotEmpty
                              ? _startlocation.text.length > 25
                                  ? "${_startlocation.text.substring(0, 25)}..."
                                  : "${_startlocation.text}"
                              : "출발지",
                          style: TextStyle(color: _startlocation.text.isNotEmpty ? MainColor : Colors.black)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 320,
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: _endlocation.text.isNotEmpty ? BorderSide(width: 1, color: Colors.red) : null,
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView(kakaoKey: 'yourKey')));
                        setState(() {
                          _endlocation.text = result.address;
                          end_lat = result.kakaoLatitude!;
                          end_lng = result.kakaoLongitude!;
                          _setMarker('도착지', LatLng(end_lat, end_lng), end_markerIcon);
                          Check_Address();
                        });
                      },
                      child: Text(
                          _endlocation.text.isNotEmpty
                              ? _endlocation.text.length > 25
                                  ? "${_endlocation.text.substring(0, 25)}..."
                                  : "${_endlocation.text}"
                              : "도착지",
                          style: TextStyle(color: _endlocation.text.isNotEmpty ? Colors.red : Colors.black)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        (km != "" && time != "")
            ? Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Map_Button(" 구글  ", "https://www.google.com/maps/dir/?api=1&origin=${_startlocation.text}&destination=${_endlocation.text}&travelmode=transit", "assets/image/Google_Map.png"),
                    Map_Button(
                        " 네이버  ",
                        "nmap://route/public?slat=${start_lat}&slng=${start_lng}&sname=${_startlocation.text}&dlat=${end_lat}&dlng=${end_lng}&dname=${_endlocation.text}&appname=com.example.schedule_snap",
                        "assets/image/Naver_Map.png"),
                    Map_Button(" 카카오  ", "kakaomap://route?sp=${start_lat},${start_lng}&ep=${end_lat},${end_lng}&by=PUBLICTRANSIT", "assets/image/Kakao_Map.png"),
                  ],
                ),
              )
            : Container(),
        (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width * 0.88,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty) // 출발지, 목적지 둘다 채워져 있으면 거리 검색 버튼 활성화
                          ? () {
                              find_Route();
                              _setMarker('출발지', LatLng(start_lat, start_lng), start_markerIcon); // 해당 위치로 마커 생성
                            }
                          : null,
                      child: (km != "" && time != "") ? Text("다시 검색") : Text("검색"),
                    ),
                  ),
                ],
              )
            : Container(),
      ]),
    );
  }

  Map_Button(String text, String URL, String icon) {
    // 타사 맵 이동 버튼
    return Expanded(
      child: Container(
        decoration: Add_task_style(button_Color),
        margin: EdgeInsets.only(top: 10, right: 5),
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(side: BorderSide(width: 1, color: Colors.white)),
            onPressed: (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty)
                ? () async {
                    await launchUrl(Uri.parse(URL), mode: LaunchMode.externalApplication);
                  }
                : null,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(text: text, style: TextStyle(color: (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty) ? Colors.black : Colors.grey, fontSize: 15, fontWeight: FontWeight.bold)),
                TextSpan(children: [WidgetSpan(child: Image.asset(icon, scale: 4))]),
              ]),
            )),
      ),
    );
  }

  Start_Open_Action() {
    // 일정 시작시 행동
    return Container(
        margin: EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                    text: TextSpan(
                  children: [
                    TextSpan(children: [WidgetSpan(child: Image.asset('assets/image/start.png', width: 20, height: 18))]),
                    TextSpan(text: ' 일정 시작시 행동', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                )),
                switch_toggle(), // 스위치 버튼
              ],
            ),
            values == 0
                ? Text_Field_site(0, _widgetKey4, "", 60, 17, 1, () => _isurl = URL_Text.text.isNotEmpty, URL_Text, _isurl, () {
                    URL_Text.clear();
                    Check_URL();
                  }, "https://") // URL
                : values == 1
                    ? Container(margin: EdgeInsets.only(top: 10), child: Open_App_List(_appsFuture) // APP
                        )
                    : Spacer(),
          ],
        ));
  }

  switch_toggle() {
    // 사이트 열기 / 앱 열기 스위치 버튼
    return Container(
      key: _widgetKey4, // 포커싱 위치
      width: 230,
      height: 40,
      child: AnimatedToggleSwitch<int>.size(
        boxShadow: [
          BoxShadow(spreadRadius: 0, blurRadius: 1.0, color: Colors.grey.withOpacity(0.5), offset: Offset(0, 1) // changes position of shadow
              ),
        ],
        animationDuration: Duration(milliseconds: 350), // 전환 속도
        indicatorColor: MainColor, // 테마 색상
        borderRadius: BorderRadius.circular(20), // 박스 가장자리
        borderColor: Colors.grey, // 박스 색상
        borderWidth: 1, // 박스 굵기
        current: values,
        values: const [0, 1],
        iconOpacity: 0.2, // 선택을 안한 값의 투명도
        indicatorSize: const Size(double.infinity, 40), // 전체 사이즈
        iconSize: Size.square(15), // 아이콘 크기
        selectedIconSize: Size.square(25), // 선택된 아이콘 크기
        customIconBuilder: (context, local, global) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              alternativeIconBuilder(context, local, global),
              Text(
                  local.value == 0
                      ? ' 사이트 열기'
                      : local.value == 1
                          ? ' 앱 열기'
                          : '',
                  style: TextStyle(fontSize: 12)),
            ],
          );
        },
        onChanged: (i) => setState(() => values = i), // value 값 변경
      ),
    );
  }

  Widget alternativeIconBuilder(BuildContext context, SizeProperties<int> local, GlobalToggleProperties<int> global) {
    // 열기 위젯의 변수 값에 따른 아이콘 변경
    IconData data = Icons.access_time_rounded;
    Color? color = Colors.black;
    switch (local.value) {
      case 0:
        data = Icons.open_in_browser_rounded;
        color = Colors.indigo[900];
        break;
      case 1:
        data = Icons.phone_android;
        color = Colors.green[900];
        break;
    }
    return Icon(data, size: local.iconSize.shortestSide, color: color);
  }

  Open_App_List(Future<List<Application>> appsFuture) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
            // 체크된 부분을 확인용도
            text: TextSpan(children: [
          TextSpan(text: "실행되는 앱 :  ", style: TextStyle(color: app_name == "" ? Colors.grey : MainColor, fontWeight: FontWeight.bold, fontSize: 12)),
          TextSpan(children: [WidgetSpan(child: appIconWidget, alignment: PlaceholderAlignment.middle)]),
          TextSpan(text: " ${app_name}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        ])),
        Container(
          margin: EdgeInsets.only(top: 10),
          width: double.infinity,
          height: 250,
          decoration: Add_task_style(button_Color),
          child: FutureBuilder<List<Application>>(
            future: appsFuture, // 초기화한 Future를 사용, (+ 초기에 안잡으면 다른곳을 터치했을때 자꾸 초기화 발생)
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                List<Application> apps = snapshot.data!;
                return GridView.count(
                  crossAxisCount: 3,
                  children: List.generate(apps.length, (index) {
                    final appInfo = apps[index];

                    return InkWell(
                      // Ges를 사용하면 아이콘 외 다른곳을 클릭시 자꾸 초기화 발생
                      onTap: open_app.text == appInfo.packageName
                          ? () {
                              // 만약에 선택된 앱을 한번 더 클릭시 지우게 한다.
                              setState(() {
                                appIconWidget = Container();
                                open_app.clear();
                                app_name = "";
                                Check_app();
                              });
                            }
                          : () {
                              // 선택되지 않은 앱이라면
                              setState(() {
                                if (appInfo is ApplicationWithIcon) appIconWidget = Image.memory(appInfo.icon, width: 20);
                                open_app.text = appInfo.packageName;
                                app_name = appInfo.appName;
                                Check_app();
                              });
                            },
                      child: open_app.text == appInfo.packageName
                          ? Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  // 선택된 앱이라는것을 확인하기 위한 용도
                                  decoration: Check_App_style(),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (appInfo is ApplicationWithIcon) Image.memory(appInfo.icon, width: 40),
                                      SizedBox(height: 10),
                                      Text(appInfo.appName, style: TextStyle(color: Colors.black), textAlign: TextAlign.center)
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Icon(Icons.check, size: 30, color: MainColor),
                                )
                              ],
                            )
                          : Column(
                              // 선택되지 않은 앱들은 default
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (appInfo is ApplicationWithIcon) Image.memory(appInfo.icon, width: 40),
                                SizedBox(height: 10),
                                Text(appInfo.appName, style: TextStyle(color: Colors.black), textAlign: TextAlign.center)
                              ],
                            ),
                    );
                  }),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        )
      ],
    );
  }

  SafeArea Bottom_Button() {
    // 하단 버튼
    return SafeArea(
      child: Container(
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        height: 50,
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MainColor,
            padding: EdgeInsets.symmetric(horizontal: 150, vertical: 12),
          ),
          onPressed: _isTitle_Text && (_isToday || _isTime)
              ? () async {
                  await _addTaskToDb(); // 받은 일정을 데이터베이스에 넣는 과정
                  Fluttertoast.showToast(
                    msg: (daysDiffnow > 0 && hoursDiffnow > 0 && minutesDiffnow > 0)
                        ? "[ $daysDiffnow일 $hoursDiffnow시간 $minutesDiffnow분 ] 후에 일정이 시작됩니다."
                        : (daysDiffnow > 0 && hoursDiffnow > 0)
                            ? "[ $daysDiffnow일 $hoursDiffnow시간 ] 후에 일정이 시작됩니다."
                            : (daysDiffnow > 0 && minutesDiffnow > 0)
                                ? "[ $daysDiffnow일 $minutesDiffnow분 ] 후에 일정이 시작됩니다."
                                : (hoursDiffnow > 0 && minutesDiffnow > 0)
                                    ? "[ $hoursDiffnow시간 $minutesDiffnow분 ] 후에 일정이 시작됩니다."
                                    : daysDiffnow > 0
                                        ? "[ $daysDiffnow일 ] 후에 일정이 시작됩니다."
                                        : hoursDiffnow > 0
                                            ? "[ $hoursDiffnow시간 ] 후에 일정이 시작됩니다."
                                            : minutesDiffnow > 0
                                                ? "[ $minutesDiffnow분 ] 후에 일정이 시작됩니다."
                                                : "지정된 시간에 일정이 시작됩니다.",
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    fontSize: 15,
                    textColor: Colors.white,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor: Colors.white, // 변경하려는 색상 설정
                    systemNavigationBarColor: MainColor,
                    systemNavigationBarDividerColor: MainColor,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ));
                  setState(() {
                    _taskController.getTasks();
                  });
                  Get.until((route) => route.isFirst);
                }
              : null,
          child: Text('일정 생성'),
        ),
      ),
    );
  }

  _addTaskToDb() async {
    //받은 일정을 데이터베이스에 넣는 과정
    int numbers = await _taskController.addTask(
      task: Task(
          Title: Title_Text.text,
          Start_Date: DateFormat('yyyy-MM-dd').format(Start_Date),
          End_Date: DateFormat('yyyy-MM-dd').format(End_Date),
          Start_Time: _startTime,
          End_Time: _endTime,
          Keyword: _keywordValue,
          remind: alarmValue,
          repeat: repeatValue,
          Detail: Detail_Text.text,
          startlocation: _startlocation.text,
          endlocation: _endlocation.text,
          start_lat: start_lat,
          start_lng: start_lng,
          end_lat: end_lat,
          end_lng: end_lng,
          km: km,
          time: time,
          Comment: Comment_Text.text,
          value: values,
          URL_Text: URL_Text.text,
          open_app: open_app.text,
          app_name: app_name),
    );
    print("My id is " + "$numbers");
  }
}
