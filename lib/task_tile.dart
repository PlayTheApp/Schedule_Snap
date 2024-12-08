import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedule_snap/style.dart';
import 'model/task.dart';

class TaskTile extends StatelessWidget {
  final Task? task;
  TaskTile(this.task);
  Color task_color = MainColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 12),
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 50, top: 20, bottom: 10), // 양 끝의 여백을 주기 위함
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(16),
              color: task?.Keyword == "기념일"
                  ? Anniversary_Color
                  : task?.Keyword == "대회"
                      ? Contest_Color
                      : task?.Keyword == "공연"
                          ? show_Color
                          : task?.Keyword == "축제"
                              ? Event_Color
                              : task?.Keyword == "운동"
                                  ? Exercise_Color
                                  : task?.Keyword == "모임"
                                      ? Gathering_Color
                                      : task?.Keyword == "여가"
                                          ? Leisure_Color
                                          : task?.Keyword == "예약"
                                              ? Reservation_Color
                                              : task?.Keyword == "공부"
                                                  ? Study_Color
                                                  : task?.Keyword == "업무"
                                                      ? Work_Color
                                                      : ServeColor,
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1.0,
                  blurRadius: 1.0,
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task!.Title!.isNotEmpty
                          ? (task!.Title!.length > 10)
                              ? "${task!.Title!.substring(0, 11)}..."
                              : task!.Title!
                          : "",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "${task!.Start_Time} - ${task!.End_Time}",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      task!.Detail!.isNotEmpty
                          ? (task!.Detail!.length > 10)
                              ? "${task!.Detail!.substring(0, 14)}..."
                              : task!.Detail!
                          : "",
                      style: GoogleFonts.lato(textStyle: TextStyle(fontSize: 13, color: Colors.black)),
                      maxLines: 1,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                task?.Keyword == "기념일"
                    ? Keyword_main('assets/image/Anniversary.png', 8)
                    : task?.Keyword == "대회"
                        ? Keyword_main('assets/image/Contest.png', 6)
                        : task?.Keyword == "공연"
                            ? Keyword_main('assets/image/show.png', 8)
                            : task?.Keyword == "축제"
                                ? Keyword_main('assets/image/Event.png', 8)
                                : task?.Keyword == "운동"
                                    ? Keyword_main('assets/image/Exercise.png', 8)
                                    : task?.Keyword == "모임"
                                        ? Keyword_main('assets/image/Gathering.png', 8)
                                        : task?.Keyword == "여가"
                                            ? Keyword_main('assets/image/Leisure.png', 8)
                                            : task?.Keyword == "예약"
                                                ? Keyword_main('assets/image/Reservation.png', 8)
                                                : task?.Keyword == "공부"
                                                    ? Keyword_main('assets/image/Study.png', 7)
                                                    : task?.Keyword == "업무"
                                                        ? Keyword_main('assets/image/Work.png', 8)
                                                        : Keyword_main('assets/image/schedule.png', 8),
              ],
            )));
  }
}
