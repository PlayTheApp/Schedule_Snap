class Task {
  int? id;
  String? Title; // 제목
  String? Start_Date; // 시작 날짜
  String? End_Date; // 마감 날짜
  String? Start_Time; // 시작 시간
  String? End_Time; // 마감 시간
  String? Keyword; // 키워드
  int? remind; // 알림
  int? repeat; // 반복
  String? Detail; // 내용
  String? startlocation; // 출발지 주소
  String? endlocation; // 도착지 주소
  double? start_lat; // 출발지 위도
  double? start_lng; // 출발지 경도
  double? end_lat; // 도착지 위도
  double? end_lng; // 도착지 경도
  String? km; // 거리
  String? time; // 소요시간
  String? Comment; // 특이사항
  int? value; // 사이트(0)/앱(1) 열기 변수값
  String? URL_Text; // URL
  String? open_app; // 앱 패키지 이름
  String? app_name; // 앱 이름

  Task({
    this.id,
    this.Title,
    this.Start_Date,
    this.End_Date,
    this.Start_Time,
    this.End_Time,
    this.Keyword,
    this.remind,
    this.repeat,
    this.Detail,
    this.startlocation,
    this.endlocation,
    this.start_lat,
    this.start_lng,
    this.end_lat,
    this.end_lng,
    this.km,
    this.time,
    this.Comment,
    this.value,
    this.URL_Text,
    this.open_app,
    this.app_name,
  });

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    Title = json['Title'];
    Start_Date = json['Start_Date'];
    End_Date = json['End_Date'];
    Start_Time = json['Start_Time'];
    End_Time = json['End_Time'];
    Keyword = json['Keyword'];
    remind = json['remind'];
    repeat = json['repeat'];
    Detail = json['Detail'];
    startlocation = json['startlocation'];
    endlocation = json['endlocation'];
    start_lat = json['start_lat'];
    start_lng = json['start_lng'];
    end_lat = json['end_lat'];
    end_lng = json['end_lng'];
    km = json['km'];
    time = json['time'];
    Comment = json['Comment'];
    value = json['value'];
    URL_Text = json['URL_Text'];
    open_app = json['open_app'];
    app_name = json['app_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Title'] = this.Title;
    data['Start_Date'] = this.Start_Date;
    data['End_Date'] = this.End_Date;
    data['Start_Time'] = this.Start_Time;
    data['End_Time'] = this.End_Time;
    data['Keyword'] = this.Keyword;
    data['remind'] = this.remind;
    data['repeat'] = this.repeat;
    data['Detail'] = this.Detail;
    data['startlocation'] = this.startlocation;
    data['endlocation'] = this.endlocation;
    data['start_lat'] = this.start_lat;
    data['start_lng'] = this.start_lng;
    data['end_lat'] = this.end_lat;
    data['end_lng'] = this.end_lng;
    data['km'] = this.km;
    data['time'] = this.time;
    data['Comment'] = this.Comment;
    data['value'] = this.value;
    data['URL_Text'] = this.URL_Text;
    data['open_app'] = this.open_app;
    data['app_name'] = this.app_name;
    return data;
  }
}
