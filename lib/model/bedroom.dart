class BedroomFacility {
  final String icon;
  final String facilitiesName;
  final String? picPath;
  final String? iconBase64;
  final int? roomTypeDetailId;

  BedroomFacility({
    required this.icon,
    required this.facilitiesName,
    this.picPath,
    this.iconBase64,
    this.roomTypeDetailId,
  });

  factory BedroomFacility.fromJson(Map<String, dynamic> json) {
    return BedroomFacility(
      icon: _safeString(json['icon']),
      facilitiesName: _safeString(json['facilitiesName']),
      picPath: json['picPath'] as String?,
      iconBase64: json['iconBase64'] as String?,
      roomTypeDetailId: json['roomTypeDetailId'] as int?,
    );
  }

  static String _safeString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'facilitiesName': facilitiesName,
      'picPath': picPath,
      'iconBase64': iconBase64,
      'roomTypeDetailId': roomTypeDetailId,
    };
  }
}

class BedroomDetail {
  final int numBedrooms;
  final String bedtype1;
  final String bedtype2;
  final int roomNum;
  final List<BedroomFacility> bedroomFacilities;

  BedroomDetail({
    required this.numBedrooms,
    required this.bedtype1,
    required this.bedtype2,
    required this.roomNum,
    required this.bedroomFacilities,
  });

  factory BedroomDetail.fromJson(Map<String, dynamic> json) {
    List<BedroomFacility> facilities = [];
    if (json['bedroomFacilities'] != null &&
        json['bedroomFacilities'] is List) {
      facilities = (json['bedroomFacilities'] as List)
          .map((facilityJson) => BedroomFacility.fromJson(facilityJson))
          .toList();
    }

    return BedroomDetail(
      numBedrooms: _safeInt(json['numBedrooms']),
      bedtype1: _safeString(json['bedtype1']),
      bedtype2: _safeString(json['bedtype2']),
      roomNum: _safeInt(json['roomNum']),
      bedroomFacilities: facilities,
    );
  }

  static String _safeString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  static int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'numBedrooms': numBedrooms,
      'bedtype1': bedtype1,
      'bedtype2': bedtype2,
      'roomNum': roomNum,
      'bedroomFacilities': bedroomFacilities.map((f) => f.toJson()).toList(),
    };
  }

  // Helper method to get all facilities from all bedrooms (flattened)
  static List<BedroomFacility> getAllFacilities(
      List<BedroomDetail> bedroomDetails) {
    return bedroomDetails
        .expand((bedroom) => bedroom.bedroomFacilities)
        .toList();
  }
}
