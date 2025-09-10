class Propertystate {
  final String pic;
  final String stateName;
  final String locationName;

  Propertystate({
    required this.pic,
    required this.stateName,
    required this.locationName,
  });

  factory Propertystate.fromJson(Map<String, dynamic> json) {
    return Propertystate(
      pic: json['pic'] ?? '',
      stateName: json['stateName'] ?? '',
      locationName: json['locationName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pic': pic,
      'stateName': stateName,
      'locationName': locationName,
    };
  }
}

class LocationResponse {
  final List<Propertystate> locations;

  LocationResponse({required this.locations});

  factory LocationResponse.fromJson(List<dynamic> json) {
    return LocationResponse(
      locations: json.map((item) => Propertystate.fromJson(item)).toList(),
    );
  }
}
