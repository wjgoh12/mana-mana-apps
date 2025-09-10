class UnitAvailablePoint {
  final String email;
  final String location;
  final String unitNo;
  final int redemptionPoints;
  final int redemptionBalancePoints;

  UnitAvailablePoint({
    required this.email,
    required this.location,
    required this.unitNo,
    required this.redemptionPoints,
    required this.redemptionBalancePoints,
  });

  factory UnitAvailablePoint.fromJson(Map<String, dynamic> json) {
    return UnitAvailablePoint(
      email: json['email'] ?? '',
      location: json['location'] ?? '',
      unitNo: json['unitNo'] ?? '',
      redemptionPoints: json['redemptionPoints'] ?? 0,
      redemptionBalancePoints: json['redemptionBalancePoints'] ?? 0,
    );
  }
}
