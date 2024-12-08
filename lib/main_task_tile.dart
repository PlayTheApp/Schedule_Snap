import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'Task_page.dart';
import 'controllers/location_controller.dart';
import 'model/location.dart';
import 'model/task.dart';

class Main_Task_Tile extends StatefulWidget {
  final Task? task;

  Main_Task_Tile(this.task);

  @override
  _MainTaskTileState createState() => _MainTaskTileState();
}

class _MainTaskTileState extends State<Main_Task_Tile> {
  final _locController = Get.put(locController());

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 10),
        child: GestureDetector(
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
              await Get.to(() => Task_page(loc: loc, task: widget.task!));
            } else {
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Color.fromARGB(0, 255, 255, 255), // 변경하려는 색상 설정
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarDividerColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ));
              await Get.to(() => Task_page(task: widget.task!));
            }
          },
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("NOW", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("[ ${widget.task!.Start_Date} ]", style: TextStyle(color: Colors.green, fontSize: 14)),
                    Text("${widget.task!.Start_Time} ~ ${widget.task!.End_Time}", style: TextStyle(color: Colors.green)),
                    SizedBox(height: 20),
                    Text(
                        widget.task!.Title!.isNotEmpty
                            ? (widget.task!.Title!.length > 10)
                                ? "${widget.task!.Title!.substring(0, 11)}..."
                                : widget.task!.Title!
                            : "",
                        style: TextStyle(fontSize: 18)),
                  ],
                ),
                widget.task?.Keyword == "기념일"
                    ? Image.asset('assets/image/Anniversary.png', scale: 5)
                    : widget.task?.Keyword == "대회"
                        ? Image.asset('assets/image/Contest.png', scale: 5)
                        : widget.task?.Keyword == "공연"
                            ? Image.asset('assets/image/show.png', scale: 5)
                            : widget.task?.Keyword == "축제"
                                ? Image.asset('assets/image/Event.png', scale: 5)
                                : widget.task?.Keyword == "운동"
                                    ? Image.asset('assets/image/Exercise.png', scale: 5)
                                    : widget.task?.Keyword == "모임"
                                        ? Image.asset('assets/image/Gathering.png', scale: 5)
                                        : widget.task?.Keyword == "여가"
                                            ? Image.asset('assets/image/Leisure.png', scale: 5)
                                            : widget.task?.Keyword == "예약"
                                                ? Image.asset('assets/image/Reservation.png', scale: 5)
                                                : widget.task?.Keyword == "공부"
                                                    ? Image.asset('assets/image/Study.png', scale: 5)
                                                    : widget.task?.Keyword == "업무"
                                                        ? Image.asset('assets/image/Work.png', scale: 5)
                                                        : Image.asset('assets/image/schedule.png', scale: 5),
              ],
            ),
          ),
        ));
  }
}
