import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schedule_snap/style.dart';

import 'Al_add_task_page.dart';
import 'Selected_image.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'controllers/location_controller.dart';
import 'model/location.dart';

final _locController = Get.put(locController());

class URL_page extends StatefulWidget {
  const URL_page({super.key});

  @override
  State<URL_page> createState() => _URL_pageState();
}

class _URL_pageState extends State<URL_page> {
  final TextEditingController _URLController = TextEditingController();
  XFile? _image; //이미지를 담을 변수 선언
  int imageSize = 0;
  int send_server = 0;
  bool selected_URL = false;
  String? responses;

  @override
  void initState() {
    super.initState();
    selected_URL = false;
  }

  // URL에서 이미지를 가져오는 함수
  Future<void> getImageFromUrl(String imageUrl) async {
    try {
      // 이미지 다운로드
      var response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // 이미지 저장
        List<String> parts = imageUrl.split('/');
        String imageName = parts.last; // "my_image.jpg"
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/${imageName}.png';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // _image에 저장
        setState(() {
          _image = XFile(filePath);
          file.length().then((value) {
            setState(() {
              imageSize = value;
            });
          });
        });

        Fluttertoast.showToast(
          msg: "이미지 불러오기 성공",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: MainColor,
          fontSize: 12,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: "이미지 불러오는데 실패했습니다. \n 다시 시도해주세요.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          fontSize: 12,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
        print('URL에서 이미지 가져오기 실패. HTTP 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "이미지 불러오는데 실패했습니다. \n 다시 시도해주세요.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        fontSize: 12,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      print('URL에서 이미지 가져오기 실패: $e');
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

  Future<void> deleteImage(String imagePath) async {
    final File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      try {
        await imageFile.delete();
        print('이미지 삭제 완료');
      } catch (e) {
        print('이미지 삭제 중 오류 발생: $e');
      }
    } else {
      print('해당 이미지 파일이 존재하지 않습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(children: [
          progress(),
          _image != null ? SizedBox(height: 10) : SizedBox(height: 150),
          _image != null
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Image.file(File(_image!.path)), // 가져온 이미지를 화면에 띄워주는 코드
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
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
                )
              : _image == null && selected_URL
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
                        SizedBox(height: 20),
                      ],
                    )
                  : Icon(Icons.image_search_outlined, size: 100),
          SizedBox(height: 20),
          _image != null
              ? Column(
                  children: [
                    imageSize > 1000000
                        ? RichText(
                            text: TextSpan(children: [
                              TextSpan(text: "이미지 크기 :", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: "  ${(imageSize / (1024 * 1024)).toStringAsFixed(2)} MB",
                                  style: TextStyle(color: imageSize > 10000000 ? Colors.red : Colors.blue, fontWeight: FontWeight.bold)),
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
                    SizedBox(height: 10),
                  ],
                )
              : Container(),
          _image == null
              ? Container(
                  padding: EdgeInsets.only(left: 15, right: 5), // 여백을 주기 위함
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10), // 텍스트 필드 가장자리
                  ),
                  child: TextField(
                    style: TextStyle(fontSize: 15, height: 1.5),
                    controller: _URLController,
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        child: Icon(Icons.search, color: MainColor, size: 40),
                        onTap: () async {
                          if (_URLController.text.isNotEmpty) {
                            selected_URL = true;
                            FocusScope.of(context).unfocus(); // 키보드 내리기
                            await getImageFromUrl(_URLController.text);
                          } else {
                            Fluttertoast.showToast(
                              msg: " URL 구간을 채워주세요 ",
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              fontSize: 15,
                              textColor: Colors.white,
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          }
                        },
                      ),
                      hintText: "URL를 입력해주세요.",
                      hintStyle: TextStyle(fontSize: 15),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)), // 안눌렀을때 밑줄
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)), // 눌렀을때 밑줄
                    ),
                  ),
                )
              : Container(),
          _image != null
              ? Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (_image != null) {
                                final File imageFile = File(_image!.path);
                                setState(() {
                                  send_server = 1;
                                });
                                await sendImage(imageFile); // 이미지를 POST로 전송하기
                                if (_locController.locList.length >= 1) {
                                  locations loc = _locController.locList[0];
                                  await Get.to(() => Al_add_task_page(responses: responses, loc: loc));
                                } else {
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
                            },
                            icon: Icon(Icons.check_circle, color: MainColor),
                            iconSize: 50,
                            splashRadius: 20),
                        IconButton(
                            onPressed: () async {
                              if (_image != null) {
                                final String imagePath = _image!.path;
                                await deleteImage(imagePath); // 이미지 삭제
                                setState(() {
                                  _image = null; // 이미지를 null로 초기화
                                  send_server = 0;
                                  _URLController.clear();
                                  selected_URL = false;
                                });
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                            iconSize: 50,
                            splashRadius: 20),
                      ],
                    )
                  ],
                )
              : Container()
        ]),
      ),
    );
  }
}
