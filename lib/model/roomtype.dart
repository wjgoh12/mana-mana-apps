class RoomType {
  final String pic;
  final String pic2;
  final String pic3;
  final String pic4;
  final String pic5;
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
  final String room1BedType2;
  final String room2BedType2;
  final bool b1Sofa;
  final bool b2Sofa;
  final bool b1SofaBed;
  final bool b2SofaBed;

  RoomType({
    required this.pic,
    required this.pic2,
    required this.pic3,
    required this.pic4,
    required this.pic5,
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
    this.room1BedType2 = '',
    this.room2BedType2 = '',
    this.b1Sofa = false,
    this.b2Sofa = false,
    this.b1SofaBed = false,
    this.b2SofaBed = false,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      pic: _safeString(json['pic']),
      pic2: _safeString(json['pic2']),
      pic3: _safeString(json['pic3']),
      pic4: _safeString(json['pic4']),
      pic5: _safeString(json['pic5']),
      roomTypeName: _safeString(json['roomTypeName']),
      roomTypePoints: _parseToDouble(json['roomTypePoints']),
      numberOfPax: _safeInt(json['numGuestPax'] ?? json['numberOfPax']),
      numBedrooms: _safeInt(json['numBedrooms']),
      bedRoom1: _safeString(json['bedRoom1']),
      bedRoom2: _safeString(json['bedRoom2']),
      b1WashingMachine: _safeBool(json['b1WashingMachine']),
      b2WashingMachine: _safeBool(json['b2WashingMachine']),
      b1Bathtub: _safeBool(json['b1Bathtub']),
      b2Bathtub: _safeBool(json['b2Bathtub']),
      room1BedType2: _safeString(json['room1BedType2']),
      room2BedType2: _safeString(json['room2BedType2']),
      b1Sofa: _safeBool(json['b1Sofa']),
      b2Sofa: _safeBool(json['b2Sofa']),
      b1SofaBed: _safeBool(json['b1SofaBed']),
      b2SofaBed: _safeBool(json['b2SofaBed']),
    );
  }

  static String _safeString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    // convert booleans/numbers to meaningful string representation
    return v.toString();
  }

  static int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static bool _safeBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
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
      "pic2": pic2,
      "pic3": pic3,
      "pic4": pic4,
      "pic5": pic5,
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
      'room1BedType2': room1BedType2,
      'room2BedType2': room2BedType2,
      'b1Sofa': b1Sofa,
      'b2Sofa': b2Sofa,
      'b1SofaBed': b1SofaBed,
      'b2SofaBed': b2SofaBed,
    };
  }
}
