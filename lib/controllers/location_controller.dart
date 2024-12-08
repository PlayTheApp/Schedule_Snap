import 'package:get/get.dart';
import 'package:schedule_snap/model/location.dart';

import '../db/location_db.dart';

class locController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var locList = <locations>[].obs;

  Future<int> addloc({locations? loc}) async {
    // 해당 함수를 실행시키면 레코드 삽입 함수를 실행
    return await loc_DBHelper.insert(loc);
  }

  void getlocs() async {
    // 데이터베이스 갱신
    List<Map<String, dynamic>> locs = await loc_DBHelper.query();
    locList.assignAll(locs.map((data) => new locations.fromJson(data)).toList());
  }

  void delete(locations task) {
    loc_DBHelper.delete(task);
    print(" 주소를 제거 하였습니다.");
    getlocs();
  }

  void deleteAll() {
    loc_DBHelper.deleteAll();
    print(" 주소를 모두 제거 하였습니다.");
    getlocs();
  }
}
