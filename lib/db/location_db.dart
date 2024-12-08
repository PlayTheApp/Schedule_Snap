import 'package:schedule_snap/model/location.dart';
import 'package:sqflite/sqflite.dart';

class loc_DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _addressTableName = "addresses";

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String _path = await getDatabasesPath() + 'locations.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          print("새로운 주소 데이터베이스를 만들었습니다.");
          return db.execute("CREATE TABLE $_addressTableName("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "loc TEXT, "
              "lat REAL, "
              "lng REAL "
              ")");
        },
      );
    } catch (e) {
      print(e); // 오류 검출용?
    }
  }

  static Future<int> insert(locations? loc) async {
    // 새로운 레코드를 넣기 위한 함수
    print("insert function called");
    return await _db?.insert(_addressTableName, loc!.toJson()) ?? 1;
  } 

    static Future<List<Map<String, dynamic>>> query() async {
    print("주소 데이터베이스를 새로고침 하였습니다.");
    return await _db!.query(_addressTableName);
  }

  static delete(locations loc) async {
    return await _db!.delete(_addressTableName, where: 'id=?', whereArgs: [loc.id]);
  }

  static deleteAll() async {
    return await _db!.delete(_addressTableName);
  }
}
