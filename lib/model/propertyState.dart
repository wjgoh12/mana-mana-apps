class PropertyState {
  final String pic;
  final String stateName;
  final String locationName;

  PropertyState({
    required this.pic,
    required this.stateName,
    required this.locationName,
  });

  factory PropertyState.fromJson(Map<String, dynamic> json) {
    return PropertyState(
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
  final List<PropertyState> locations;

  LocationResponse({required this.locations});

  factory LocationResponse.fromJson(List<dynamic> json) {
    return LocationResponse(
      locations: json.map((item) => PropertyState.fromJson(item)).toList(),
    );
  }
}
