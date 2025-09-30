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
      roomTypePoints: (json['roomTypePoints'] is double)
          ? json['roomTypePoints']
          : int.tryParse(json['roomTypePoints'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "pic": pic,
      "roomTypeName": roomTypeName,
      "roomTypePoints": roomTypePoints,
    };
  }
}
