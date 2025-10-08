// ignore: file_names
class BookingHistory {
  final String location;
  final String unitNo;
  final String bookingLocation;
  final String typeRoom;
  final DateTime arrivalDate;
  final DateTime departureDate;
  final int pointUsed;
  final String status;
  final DateTime createdAt; // Added creation date

  BookingHistory({
    required this.location,
    required this.unitNo,
    required this.bookingLocation,
    required this.typeRoom,
    required this.arrivalDate,
    required this.departureDate,
    required this.pointUsed,
    required this.status,
    DateTime? createdAt, // Optional in constructor but will be initialized
  }) : createdAt = createdAt ??
            DateTime.now(); // Default to current time if not provided

  // Convert to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'unitNo': unitNo,
      'bookingLocation': bookingLocation,
      'typeRoom': typeRoom,
      'arrivalDate': arrivalDate.toIso8601String(),
      'departureDate': departureDate.toIso8601String(),
      'pointUsed': pointUsed,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Generate a unique key for this booking
  String get storageKey {
    // Combine relevant fields to create a unique identifier
    return 'booking_${location}_${unitNo}_${arrivalDate.toIso8601String()}_${createdAt.millisecondsSinceEpoch}';
  }

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    return BookingHistory(
      location: json['location'] ?? '',
      unitNo: json['unitNo'] ?? '',
      bookingLocation: json['bookingLocation'] ?? '',
      typeRoom: json['typeRoom'] ?? '',
      arrivalDate: DateTime.parse(json['arrivalDate']),
      departureDate: DateTime.parse(json['departureDate']),
      pointUsed: json['pointUsed'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
