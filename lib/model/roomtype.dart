class RoomType {
  final String pic;
  final String roomTypeName;
  final double roomTypePoints;

  RoomType({
    required this.pic,
    required this.roomTypeName,
    required this.roomTypePoints,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      pic: json['pic'] ?? '', // fallback to empty string if null
      roomTypeName: json['roomTypeName'] ?? '',
      roomTypePoints: _parseToDouble(json['roomTypePoints']),
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      "pic": pic,
      "roomTypeName": roomTypeName,
      "roomTypePoints": roomTypePoints,
    };
  }
}
