import 'bedroom.dart';

class RoomType {
  final String? state;
  final int bookingLocation;
  final String? bookingLocationName;
  final int rooms;
  final String? arrivalDate;
  final String? departureDate;
  final String pic;
  final String pic2;
  final String pic3;
  final String pic4;
  final String pic5;
  final String roomTypeName;
  final String roomTypeDesc; // Added field
  final double roomTypePoints;
  final int numberOfPax;
  final int numBedrooms;
  final List<BedroomDetail> bedroomDetails;

  RoomType({
    this.state,
    this.bookingLocation = 0,
    this.bookingLocationName,
    this.rooms = 0,
    this.arrivalDate,
    this.departureDate,
    required this.pic,
    this.pic2 = '',
    this.pic3 = '',
    this.pic4 = '',
    this.pic5 = '',
    required this.roomTypeName,
    this.roomTypeDesc = '', // Default empty
    required this.roomTypePoints,
    required this.numberOfPax,
    this.numBedrooms = 1,
    this.bedroomDetails = const [],
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    // Parse bedroomDetails array
    List<BedroomDetail> bedroomDetailsList = [];
    if (json['bedroomDetails'] != null && json['bedroomDetails'] is List) {
      bedroomDetailsList = (json['bedroomDetails'] as List)
          .map((detailJson) => BedroomDetail.fromJson(detailJson))
          .toList();
    }

    return RoomType(
      state: json['state'] as String?,
      bookingLocation: _safeInt(json['bookingLocation']),
      bookingLocationName: json['bookingLocationName'] as String?,
      rooms: _safeInt(json['rooms']),
      arrivalDate: json['arrivalDate'] as String?,
      departureDate: json['departureDate'] as String?,
      pic: _safeString(json['pic']),
      pic2: _safeString(json['pic2']),
      pic3: _safeString(json['pic3']),
      pic4: _safeString(json['pic4']),
      pic5: _safeString(json['pic5']),
      roomTypeName: _safeString(json['roomTypeName']),
      roomTypeDesc: _safeString(json['roomTypeDesc']), // Parse field
      roomTypePoints: _parseToDouble(json['roomTypePoints']),
      numberOfPax: _safeInt(json['numGuestPax'] ?? json['numberOfPax']),
      numBedrooms: _safeInt(json['numBedrooms']),
      bedroomDetails: bedroomDetailsList,
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
      "state": state,
      "bookingLocation": bookingLocation,
      "bookingLocationName": bookingLocationName,
      "rooms": rooms,
      "arrivalDate": arrivalDate,
      "departureDate": departureDate,
      "pic": pic,
      "pic2": pic2,
      "pic3": pic3,
      "pic4": pic4,
      "pic5": pic5,
      "roomTypeName": roomTypeName,
      "roomTypeDesc": roomTypeDesc,
      "roomTypePoints": roomTypePoints,
      "numGuestPax": numberOfPax,
      "numBedrooms": numBedrooms,
      "bedroomDetails": bedroomDetails.map((d) => d.toJson()).toList(),
    };
  }
}
