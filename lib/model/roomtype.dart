class RoomType {
  final String pic;
  final String roomTypeName;
  final double roomTypePoints;
  final int numberOfPax;
  final int numBedrooms;
  final String bedRoom1;
  final String bedRoom2;
  final bool b1WashingMachine;
  final bool b2WashingMachine;
  final bool b1Bathtub;
  final bool b2Bathtub;

  RoomType({
    required this.pic,
    required this.roomTypeName,
    required this.roomTypePoints,
    required this.numberOfPax,
    this.numBedrooms = 1,
    this.bedRoom1 = '',
    this.bedRoom2 = '',
    this.b1WashingMachine = false,
    this.b2WashingMachine = false,
    this.b1Bathtub = false,
    this.b2Bathtub = false,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      pic: json['pic'] ?? '', // fallback to empty string if null
      roomTypeName: json['roomTypeName'] ?? '',
      roomTypePoints: _parseToDouble(json['roomTypePoints']),
      numberOfPax: json['numGuestPax'] ?? 0,
      numBedrooms: json['numBedrooms'] ?? 1,
      bedRoom1: json['bedRoom1'] ?? '',
      bedRoom2: json['bedRoom2'] ?? '',
      b1WashingMachine: json['b1WashingMachine'] ?? false,
      b2WashingMachine: json['b2WashingMachine'] ?? false,
      b1Bathtub: json['b1Bathtub'] ?? false,
      b2Bathtub: json['b2Bathtub'] ?? false,
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
      "numGuestPax": numberOfPax,
      "numBedrooms": numBedrooms,
      "bedRoom1": bedRoom1,
      "bedRoom2": bedRoom2,
      "b1WashingMachine": b1WashingMachine,
      "b2WashingMachine": b2WashingMachine,
      "b1Bathtub": b1Bathtub,
      "b2Bathtub": b2Bathtub,
    };
  }
}
