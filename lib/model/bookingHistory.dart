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
  }) : this.createdAt = createdAt ??
            DateTime.now(); // Default to current time if not provided

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
          : DateTime.now(), // Default to current time if not provided in API
    );
  }
}
