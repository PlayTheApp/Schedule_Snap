import 'package:sqflite/sqflite.dart';
import '../model/task.dart';

class DBHelper {
  static Database? db;
  static final int _version = 1;
  static final String _tableName = "tasks";

  static Future<void> initDb() async {
    if (db != null) {
      return;
    }
    try {
      String _path = await getDatabasesPath() + 'tasks.db';
      db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          print("새로운 데이터베이스를 만들었습니다.");
          return db.execute("CREATE TABLE $_tableName("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "Title TEXT, "
              "Start_Date TEXT, "
              "End_Date TEXT, "
              "Start_Time TEXT, "
              "End_Time TEXT, "
              "Keyword TEXT, "
              "remind INTEGER, "
              "repeat INTEGER, "
              "Detail TEXT, "
              "startlocation TEXT, "
              "endlocation TEXT, "
              "start_lat REAL, "
              "start_lng REAL, "
              "end_lat REAL, "
              "end_lng REAL, "
              "km TEXT, "
              "time TEXT, "
              "Comment TEXT, "
              "value INTEGER, "
              "URL_Text TEXT, "
              "open_app TEXT, "
              "app_name TEXT)");
        },
      );
    } catch (e) {
      print(e); // 오류 검출용?
    }
  }

  static Future<int> insert(Task? task) async {
    // 새로운 레코드를 넣기 위한 함수
    print("insert function called");
    return await db?.insert(_tableName, task!.toJson()) ?? 1;
  } 

    static Future<List<Map<String, dynamic>>> query() async {
    print("데이터베이스를 새로고침 하였습니다.");
    return await db!.query(_tableName);
  }

  static delete(Task task) async {
    return await db!.delete(_tableName, where: 'id=?', whereArgs: [task.id]);
  }

  static deleteAll() async {
    return await db!.delete(_tableName);
  }
}
