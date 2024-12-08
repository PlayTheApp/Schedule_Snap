import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controllers/task_controller.dart';
import 'model/task.dart';

final TaskController _taskController = Get.put(TaskController()); // 데이터베이스

fast_add_task(String fast_text, DateTime startDate, String startTime) async {
    //빠른 일정을 데이터베이스에 넣는 과정
    int numbers = await _taskController.addTask(
      task: Task(
          Title: fast_text,
          Start_Date: DateFormat('yyyy-MM-dd').format(startDate),
          End_Date: DateFormat('yyyy-MM-dd').format(startDate),
          Start_Time: startTime,
          End_Time: startTime,
          Keyword: "기타",
          remind: 1,
          repeat: 0,
          Detail: "",
          startlocation: "",
          endlocation: "",
          start_lat: 0.0,
          start_lng: 0.0,
          end_lat: 0.0,
          end_lng: 0.0,
          km: "",
          time: "",
          Comment: "",
          value: 0,
          URL_Text: "",
          open_app: "",
          app_name: ""),
    );
    print("My id is " + "$numbers");
  }