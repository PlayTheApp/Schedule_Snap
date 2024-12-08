import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schedule_snap/style.dart';

import 'Al_add_task_page.dart';
import 'Selected_image.dart';
import 'package:http/http.dart' as http;

import 'controllers/location_controller.dart';
import 'model/location.dart';

final _locController = Get.put(locController());

class Camera_page extends StatefulWidget {
  const Camera_page({super.key});

  @override
  State<Camera_page> createState() => _Camera_pageState();
}

class _Camera_pageState extends State<Camera_page> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  String? imagePath;

  bool selected_Camera = false;
  int imageSize = 0;
  int send_server = 0;
  String? responses;

  @override
  void initState() {
    super.initState();
    check_camera();
  }

  @override
  void dispose() {
    super.dispose();

    if (_cameraController != null) {
      // 뒤로가면 카메라 종료
      _cameraController!.dispose();
      _cameraController = null;
      _isCameraReady = false;
      selected_Camera = false;
    }
  }

  void check_camera() {
    availableCameras().then((cameras) {
      // 카메라 ON
      if (cameras.isNotEmpty && _cameraController == null) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.veryHigh,
        );
        _cameraController!.initialize().then((_) {
          setState(() {
            _cameraController!.setFlashMode(FlashMode.off); // 플래쉬 끄기
            _isCameraReady = true;
          });
        });
      }
    });
  }

  Future<void> _onTakePicture(BuildContext context) async {
    // 즉시 카메라 찍기
    _cameraController!.takePicture().then((image) {
      setState(() {
        imagePath = image.path;
        image.length().then((value) {
          setState(() {
            imageSize = value;
          });
        });
      });
      print("사진 찍기 완료");
    });
  }

  void deleteImage(String imagePath) async {
    // 찍은 이미지 삭제
    final File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      await imageFile.delete();
      print('이미지 삭제 완료');
    } else {
      print('해당 이미지 파일이 존재하지 않습니다.');
    }
  }

  //이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: imageSource,
    );
    if (image != null) {
      setState(() {
        imagePath = image.path; //가져온 이미지를 _image에 저장
        image.length().then((value) {
          setState(() {
            imageSize = value;
          });
        });
      });
      print("이미지 가져오기 완료");
    }
  }

  Future<void> sendImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://13.209.211.123:8080/upload/image'), // 이미지를 업로드할 URL을 지정하세요.
    );

    var multipartFile = await http.MultipartFile.fromPath(
      'imgFile', // 서버에서 이미지를 받을 때 사용할 필드명을 지정하세요.
      imageFile.path,
    );

    request.files.add(multipartFile);
    var response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      setState(() {
        responses = responseBody;
        send_server = 0;
      });
      print('이미지 업로드 성공! ${response}');
      Fluttertoast.showToast(
        msg: "이미지 업로드 성공!",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 15,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      setState(() {
        send_server = 0;
      });
      print('이미지 업로드 실패. ${response.statusCode}');
      Fluttertoast.showToast(
        msg: "이미지 업로드에 실패했습니다. \n 다시 시도해주세요.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 15,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          progress(),
          SizedBox(height: 10),
          imagePath == null
              ? Expanded(
                  child: _cameraController != null && _isCameraReady // 카메라가 준비가 되어있는가?
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.9,
                              child: CameraPreview(
                                _cameraController!,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: 20,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 200,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text("[ 정확하게 촬영해주세요 ]", style: TextStyle(fontSize: 12)),
                                      ),
                                    ),
                                    imagePath == null && selected_Camera
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(color: MainColor, backgroundColor: Colors.white, strokeWidth: 10),
                                              SizedBox(height: 20),
                                              Container(
                                                alignment: Alignment.center,
                                                width: 150,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Text("[ 잠시만 기다려주세요 ]", style: TextStyle(fontSize: 12)),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    Positioned(
                                      bottom: 20,
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            elevation: 2,
                                            backgroundColor: Colors.white,
                                            side: BorderSide(width: 1, color: Colors.black),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                          ),
                                          onPressed: () async {
                                            await getImage(ImageSource.camera);
                                          },
                                          child: RichText(
                                            text: TextSpan(children: [
                                              TextSpan(children: [WidgetSpan(child: Icon(Icons.camera_alt_rounded, color: Colors.black, size: 15))]),
                                              TextSpan(text: "  기본 카메라로 촬영", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold))
                                            ]),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          // 준비가 안되어 있다면, 카메라가 안켜짐
                          alignment: Alignment.center,
                          color: Colors.grey,
                          width: double.infinity,
                          height: 400,
                          child: Text("카메라 사용권한이 없습니다."),
                        ),
                )
              : Column(children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 10), // 여백을 주기 위함
                        child: Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.54,
                          child: Image.file(File(imagePath!), filterQuality: FilterQuality.high, fit: BoxFit.fitHeight),
                        ),
                      ),
                      send_server == 1
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: MainColor, backgroundColor: Colors.white, strokeWidth: 10),
                                SizedBox(height: 20),
                                Container(
                                  alignment: Alignment.center,
                                  width: 150,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text("[ 잠시만 기다려주세요 ]", style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            )
                          : Container()
                    ],
                  ),
                  SizedBox(height: 10),
                  imageSize > 1000000
                      ? RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "이미지 크기 :", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: "  ${(imageSize / (1024 * 1024)).toStringAsFixed(2)} MB", style: TextStyle(color: imageSize > 10000000 ? Colors.red : Colors.blue, fontWeight: FontWeight.bold)),
                            TextSpan(text: "  / ", style: TextStyle(color: Colors.black)),
                            TextSpan(text: "10MB", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ]),
                        )
                      : RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "이미지 크기 :", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: "  ${(imageSize / 1024).toStringAsFixed(2)} KB", style: TextStyle(color: imageSize > 10000000 ? Colors.red : Colors.blue, fontWeight: FontWeight.bold)),
                            TextSpan(text: "  / ", style: TextStyle(color: Colors.black)),
                            TextSpan(text: "10MB", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                ]),
          SizedBox(height: 10),
          Action_Button(), // 카메라 하단 버튼
        ],
      ),
    );
  }

  Widget Action_Button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            onPressed: _cameraController != null && imagePath == null
                ? () async {
                    await getImage(ImageSource.gallery);
                  }
                : null,
            icon: Icon(Icons.image_outlined),
            iconSize: 40,
            splashRadius: 20),
        IconButton(
            onPressed: _cameraController != null && imagePath == null
                ? () {
                    setState(() {
                      selected_Camera = true;
                      _onTakePicture(context); // 카메라 찍기
                    });
                  }
                : imagePath != null
                    ? () async {
                        if (imagePath != null) {
                          final File imageFile = File(imagePath!);
                          setState(() {
                            send_server = 1;
                          });
                          await sendImage(imageFile); // 이미지를 POST로 전송하기
                          if (_locController.locList.length >= 1) {
                            locations loc = _locController.locList[0];
                            await Get.to(() => Al_add_task_page(responses: responses, loc: loc));
                          }
                          else {
                            await Get.to(() => Al_add_task_page(responses: responses));
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: "이미지를 추가하고 다시 시도해주세요.",
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            fontSize: 15,
                            textColor: Colors.white,
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      }
                    : null,
            icon: Icon(imagePath == null ? Icons.camera : Icons.check_circle, color: MainColor),
            iconSize: 70,
            splashRadius: 40),
        IconButton(
            onPressed: imagePath == null
                ? null
                : () {
                    setState(() {
                      selected_Camera = false;
                      deleteImage(imagePath!); // 사진 삭제
                      imagePath = null; // 경로 지우기
                    });
                  },
            icon: Icon(Icons.delete),
            iconSize: 40,
            splashRadius: 20,
            color: Colors.red),
      ],
    );
  }
}
