class locations {
  int? id;
  String? loc;
  double? lat;
  double? lng;

  locations({
    this.id,
    this.loc,
    this.lat,
    this.lng,
  });

  locations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    loc = json['loc'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['loc'] = this.loc;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}
