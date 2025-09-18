class OccupancyRate {
  final int year;
  final int month;
  final double amount;

  OccupancyRate({
    required this.year,
    required this.month,
    required this.amount,
  });

  factory OccupancyRate.fromJson(Map<String, dynamic> json) {
    return OccupancyRate(
      year: json['year'] as int,
      month: json['month'] as int,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'amount': amount,
      };

  @override
  String toString() =>
      'OccupancyRate(year: $year, month: $month, amount: $amount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OccupancyRate &&
        other.year == year &&
        other.month == month &&
        other.amount == amount;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ amount.hashCode;

  OccupancyRate copyWith({
    int? year,
    int? month,
    double? amount,
  }) {
    return OccupancyRate(
      year: year ?? this.year,
      month: month ?? this.month,
      amount: amount ?? this.amount,
    );
  }
}
