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
  final String? bookingId; // Unique booking ID from API

  BookingHistory({
    required this.location,
    required this.unitNo,
    required this.bookingLocation,
    required this.typeRoom,
    required this.arrivalDate,
    required this.departureDate,
    required this.pointUsed,
    required this.status,
    this.bookingId, // Optional booking ID
  }) : createdAt = DateTime
            .now(); // Not used for sorting anymore, just for compatibility

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
      if (bookingId != null) 'bookingId': bookingId,
    };
  }

  // Generate a unique key for this booking based on immutable fields
  String get stableIdentifier {
    // Use immutable booking details (not status or createdAt)
    // This creates a unique ID that won't change when status updates
    return '${location}_${unitNo}_${bookingLocation}_${typeRoom}_${arrivalDate.toIso8601String()}_${departureDate.toIso8601String()}_$pointUsed';
  }

  // Generate a unique key for this booking
  String get storageKey {
    // Use bookingId if available, otherwise use stable identifier
    if (bookingId != null && bookingId!.isNotEmpty) {
      return 'booking_$bookingId';
    }
    return 'booking_$stableIdentifier';
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
      bookingId: json['bookingId']?.toString() ?? json['id']?.toString(),
    );
  }
}
