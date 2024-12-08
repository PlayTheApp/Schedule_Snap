import 'package:get/get.dart';

import '../db/db_helper.dart';
import '../model/task.dart';

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<int> addTask({Task? task}) async {
    // 해당 함수를 실행시키면 레코드 삽입 함수를 실행
    return await DBHelper.insert(task);
  }

    void getTasks() async { // 데이터베이스 갱신
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => new Task.fromJson(data)).toList());
  }

    void delete(Task task) {
    DBHelper.delete(task);
    print(" 일정을 제거 하였습니다.");
    getTasks();
  }

    void deleteAll() {
    DBHelper.deleteAll();
    print(" 일정을 모두 제거 하였습니다.");
    getTasks();
  }
}