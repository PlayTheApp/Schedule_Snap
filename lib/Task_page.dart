import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:schedule_snap/controllers/task_controller.dart';
import 'package:schedule_snap/style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'controllers/location_controller.dart';
import 'model/location.dart';
import 'model/task.dart';
import 'package:http/http.dart' as http;

class Task_page extends StatefulWidget {
  final locations? loc;
  final Task? task;

  const Task_page({super.key, this.loc, this.task});

  @override
  State<Task_page> createState() => _Task_pageState();
}

class _Task_pageState extends State<Task_page> {
  final locController _locController = Get.put(locController());
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _startlocation = TextEditingController(); // 출발지
  final TextEditingController _endlocation = TextEditingController(); // 도착지
  Completer<GoogleMapController> _controller = Completer(); // 구글 맵 컨트롤러
  Set<Polyline> _polylines = Set<Polyline>(); // 구글 맵 선
  int _polylineIdCounter = 1; // 구글 맵 선 관련 함수
  Set<Marker> _marker = Set<Marker>();
  late Uint8List start_markerIcon;
  late Uint8List end_markerIcon;

  double start_lat = 0.0; // 출발지 위도
  double start_lng = 0.0; // 출발지 경도
  double end_lat = 0.0; // 도착지 위도
  double end_lng = 0.0; // 도착지 경도

  String km = ""; // 거리
  String time = ""; // 소요시간

  @override
  void initState() {
    super.initState();
    _locController.getlocs();
    getDBloc();
    setCustomMapPin(); // 마커 이미지 변환
  }

  void setCustomMapPin() async {
    // 마커 변환
    start_markerIcon = await getBytesFromAsset('assets/image/start_marker.png', 100);
    end_markerIcon = await getBytesFromAsset('assets/image/end_marker.png', 100);
    getmarker();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    // 마커 이미지 변환
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  getmarker() async {
    // 마커 가져오기
    setState(() {
      _setMarker('출발지', LatLng(start_lat, start_lng), start_markerIcon);
      _setMarker('목적지', LatLng(end_lat, end_lng), end_markerIcon); // 해당 위치로 마커 생성
    });
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

  getDBloc() async {
    if (widget.task!.startlocation!.isNotEmpty) {
      setState(() {
        _startlocation.text = widget.task!.startlocation!;
        start_lat = widget.task!.start_lat!;
        start_lng = widget.task!.start_lng!;
        _endlocation.text = widget.task!.endlocation!;
        end_lat = widget.task!.end_lat!;
        end_lng = widget.task!.end_lng!;
      });
    } else if (_locController.locList.length >= 1) {
      setState(() {
        _startlocation.text = widget.loc!.loc!;
        start_lat = widget.loc!.lat!;
        start_lng = widget.loc!.lng!;
        _endlocation.text = widget.task!.endlocation!;
        end_lat = widget.task!.end_lat!;
        end_lng = widget.task!.end_lng!;
      });
    } else {
      setState(() {
        _endlocation.text = widget.task!.endlocation!;
        end_lat = widget.task!.end_lat!;
        end_lng = widget.task!.end_lng!;
      });
    }
  }

  Future<Map<String, dynamic>> getDirections() async {
    // 구글 directions API
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$start_lat,$start_lng&destination=$end_lat,$end_lng&mode=transit&key=AIzaSyCZ01Jclb8VTtYqz7Tn7e827XFsq8yhbqk&language=ko';

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
          70),
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
        // patterns: [PatternItem.dash(10), PatternItem.gap(10)],
        polylineId: PolylineId(polylineIdVal),
        width: 3,
        color: Colors.red,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
              actions: [
                widget.task!.endlocation!.isNotEmpty
                    ? Container(
                        // 목적지가 있어야 공유 가능
                        width: 30,
                        height: 30,
                        child: FloatingActionButton.small(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          onPressed: () async {
                            bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();

                            final LocationTemplate defaultLocation = LocationTemplate(
                              address: _endlocation.text,
                              content: Content(
                                title: '현위치 : ${_startlocation.text}',
                                description: '소요시간 : [ 40분 ] \n 도착 예정 시간 : [ 오후 3시 45분 ]',
                                imageUrl: Uri.parse('https://ifh.cc/g/VDw8aW.png'),
                                link: Link(
                                  webUrl:
                                      Uri.parse("https://map.kakao.com/?map_type=TYPE_MAP&target=car&rt=%2C%2C523953%2C1084098&rt1=${_startlocation}&rt2=${_endlocation}&rtIds=%2C&rtTypes=%2C%208"),
                                  mobileWebUrl: Uri.parse("kakaomap://route?sp=${start_lat},${start_lng}&ep=${end_lat},${end_lng}&by=PUBLICTRANSIT"),
                                ),
                              ),
                            );

                            if (isKakaoTalkSharingAvailable) {
                              try {
                                Uri uri = await ShareClient.instance.shareDefault(template: defaultLocation);
                                await ShareClient.instance.launchKakaoTalk(uri);
                                print('카카오톡 공유 완료');
                              } catch (error) {
                                print('카카오톡 공유 실패 $error');
                              }
                            } else {
                              try {
                                Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(template: defaultLocation);
                                await launchBrowserTab(shareUrl, popupOpen: true);
                              } catch (error) {
                                print('카카오톡 공유 실패 $error');
                              }
                            }
                          },
                          child: Icon(Icons.share, color: Colors.black, size: 20),
                        ))
                    : Container(),
                SizedBox(width: 10)
              ],
              // pinned: true, // 밑으로 스크롤 해도, 상단바는 남아있음.
              expandedHeight: (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty) ? 300.0 : 100.0,
              flexibleSpace: Stack(
                children: [
                  FlexibleSpaceBar(
                    background: (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty)
                        ? GoogleMap(
                            zoomGesturesEnabled: false, // 확대
                            compassEnabled: false, // 나침반
                            buildingsEnabled: false, // 건물 3인칭
                            scrollGesturesEnabled: false, // 스크롤
                            mapType: MapType.normal, // 맵 타입
                            zoomControlsEnabled: false, // 줌
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.task!.end_lat!, widget.task!.end_lng!),
                              zoom: 15, // 카메라 확대 크기
                            ), // 초기 위치
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            markers: _marker,
                            polylines: _polylines,
                          )
                        : Container(),
                  ),
                  (_startlocation.text.isNotEmpty && _endlocation.text.isNotEmpty)
                      ? Positioned(
                          bottom: 60,
                          right: 10,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () async {
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
                            },
                            child: (km.isEmpty & time.isEmpty)
                                ? RichText(
                                    text: TextSpan(children: [
                                      TextSpan(children: [WidgetSpan(child: Icon(Icons.turn_sharp_right_outlined, size: 20))]),
                                      TextSpan(text: " 길찾기", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    ]),
                                  )
                                : RichText(
                                    text: TextSpan(children: [
                                      TextSpan(children: [WidgetSpan(child: Icon(Icons.turn_sharp_right_outlined, size: 20))]),
                                      TextSpan(text: " 재검색", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    ]),
                                  ),
                          ))
                      : Container(),
                  (km.isNotEmpty & time.isNotEmpty)
                      ? Positioned(
                          bottom: 65,
                          left: 10,
                          child: Container(
                            width: 200,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.directions_run_rounded, size: 20, color: MainColor),
                                Text(km, style: TextStyle(fontWeight: FontWeight.bold)),
                                Icon(Icons.access_time, size: 20, color: Colors.green),
                                Text(time, style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ))
                      : Container(),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    child: Text(widget.task!.Title!, style: TextStyle(fontSize: 20), textAlign: TextAlign.center)),
                ),
              )),
          SliverFillRemaining(
            // 메인 페이지
            hasScrollBody: true, // 스크롤 없게 만듬
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 30),
                  Line("날짜", widget.task!.Start_Date!.isNotEmpty),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(children: [WidgetSpan(child: Icon(Icons.calendar_month_outlined, size: 17))]),
                      TextSpan(text: " ${widget.task!.Start_Date} ~", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                      TextSpan(text: " ${widget.task!.End_Date}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                    ]),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(children: [WidgetSpan(child: Icon(Icons.access_time_outlined, size: 17))]),
                      TextSpan(text: " ${widget.task!.Start_Time} ~", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                      TextSpan(text: " ${widget.task!.End_Time}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                    ]),
                  ),
                  SizedBox(height: 10),
                  Line("키워드", widget.task!.Keyword!.isNotEmpty),
                  SizedBox(height: 20),
                  Text("${widget.task!.Keyword}"),
                  SizedBox(height: 20),
                  Line("내용", widget.task!.Detail!.isNotEmpty),
                  (widget.task!.Detail!.isNotEmpty)
                      ? Column(
                          children: [
                            SizedBox(height: 20),
                            Container(
                              margin: EdgeInsets.only(left: 30, right: 30),
                              child: Text("${widget.task!.Detail}"),
                            ),
                            SizedBox(height: 10),
                          ],
                        )
                      : SizedBox(height: 10),
                  Line("장소", widget.task!.startlocation!.isNotEmpty),
                  (widget.task!.startlocation!.isNotEmpty)
                      ? Column(
                          children: [
                            SizedBox(height: 10),
                            Text("출발지 : ${_startlocation.text}"),
                            SizedBox(height: 10),
                            Text("도착지 : ${_endlocation.text}"),
                            SizedBox(height: 10),
                          ],
                        )
                      : SizedBox(height: 10),
                  Line("특이사항", widget.task!.Comment!.isNotEmpty),
                  (widget.task!.Comment!.isNotEmpty)
                      ? Column(
                          children: [
                            SizedBox(height: 10),
                            Text("${widget.task!.Comment}"),
                            SizedBox(height: 10),
                          ],
                        )
                      : SizedBox(height: 10),
                  Line("일정 시작시 행동", widget.task!.URL_Text!.isNotEmpty || widget.task!.open_app!.isNotEmpty),
                  (widget.task!.value! == 0 && widget.task!.URL_Text!.isNotEmpty)
                      ? Column(
                          children: [
                            SizedBox(height: 10),
                            Text("사이트 오픈"),
                            SizedBox(height: 10),
                            Text("( ${widget.task!.URL_Text} )", style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 10),
                          ],
                        )
                      : (widget.task!.value! == 1 && widget.task!.open_app!.isNotEmpty)
                          ? Column(
                              children: [
                                SizedBox(height: 10),
                                Text("앱 열기"),
                                SizedBox(height: 10),
                                Text("( ${widget.task!.app_name} )", style: TextStyle(color: Colors.grey)),
                                SizedBox(height: 10),
                              ],
                            )
                          : SizedBox(height: 10),
                  Line_End(),
                  SizedBox(height: 50),
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: SafeArea(
        child: Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          height: 50,
          color: Colors.white,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 150, vertical: 12),
            ),
            onPressed: () async {
              _taskController.delete(widget.task!);
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.white, // 변경하려는 색상 설정
                systemNavigationBarColor: MainColor,
                systemNavigationBarDividerColor: MainColor,
                systemNavigationBarIconBrightness: Brightness.light,
              ));
              Fluttertoast.showToast(
                msg: "일정을 삭제했습니다.",
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                fontSize: 15,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_SHORT,
              );
              setState(() {
                _taskController.getTasks();
              });
              Get.until((route) => route.isFirst);
            },
            child: Text('일정 삭제'),
          ),
        ),
      ),
    );
  }

  Widget Line(String text, bool check) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 30),
        Expanded(child: Divider(color: check ? MainColor : Colors.grey[400])),
        SizedBox(width: 10),
        Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: check ? MainColor : Colors.grey[400])),
        SizedBox(width: 10),
        Expanded(child: Divider(color: check ? MainColor : Colors.grey[400])),
        SizedBox(width: 30),
      ],
    );
  }

  Widget Line_End() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 30),
        Expanded(child: Divider(color: MainColor)),
        SizedBox(width: 30),
      ],
    );
  }
}
