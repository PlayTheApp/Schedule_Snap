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

class Text_page extends StatefulWidget {
  const Text_page({super.key});

  @override
  State<Text_page> createState() => _Text_pageState();
}

class _Text_pageState extends State<Text_page> {
  final TextEditingController _URLController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          progress(),
          SizedBox(height: 70),
          Container(
            padding: EdgeInsets.only(left: 15, right: 5), // 여백을 주기 위함
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10), // 텍스트 필드 가장자리
            ),
            child: TextFormField(
              maxLines: 100,
              maxLength: 500,
              style: TextStyle(fontSize: 15, height: 1.5),
              controller: _URLController,
              decoration: InputDecoration(
                hintText: "텍스트를 입력해주세요.",
                hintStyle: TextStyle(fontSize: 15),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)), // 안눌렀을때 밑줄
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)), // 눌렀을때 밑줄
              ),
            ),
          ),
          SizedBox(height: 10),
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: MainColor,
    padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12), // 크기 조절
  ),
  onPressed: () {},
  child: Text('일정 생성', style: TextStyle(color: Colors.white)), // 텍스트 색상 변경
),
        ]
        ))
    );
  }
}
