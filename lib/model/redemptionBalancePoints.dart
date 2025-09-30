class RedemptionBalancePoints {
  final String locationName;
  final String unitNo;
  final double redemptionPoints;
  final double redemptionBalancePoints;

  RedemptionBalancePoints({
    required this.locationName,
    required this.unitNo,
    required this.redemptionPoints,
    required this.redemptionBalancePoints,
  });

  factory RedemptionBalancePoints.fromJson(Map<String, dynamic> json) {
    return RedemptionBalancePoints(
      locationName: json['locationName'] ?? '',
      unitNo: json['unitNo'] ?? '',
      redemptionPoints: json['redemptionPoints'] ?? 0.00,
      redemptionBalancePoints: json['redemptionBalancePoints'] ?? 0.00,
    );
  }
}
