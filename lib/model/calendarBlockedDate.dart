class CalendarBlockedDate {
  final String state;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String contentType; // color of the blocked date
  final String description;

  CalendarBlockedDate({
    required this.state,
    required this.dateFrom,
    required this.dateTo,
    required this.contentType,
    required this.description,
  });

  factory CalendarBlockedDate.fromJson(Map<String, dynamic> json) {
    return CalendarBlockedDate(
      state: json['state'] ?? '',
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      contentType: json['contentType'] ?? '', //color of blocked date
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'dateFrom': dateFrom.toIso8601String(),
      'dateTo': dateTo.toIso8601String(),
      'contentType': contentType,
      'description': description,
    };
  }
}
