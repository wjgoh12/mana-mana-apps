class SingleUnitByMonth {
  double? total;
  String? slocation;
  String? stype;
  String? sunitno;
  int? imonth;
  int? iyear;
  String? stranscode;

  SingleUnitByMonth(
      {this.total,
      this.slocation,
      this.stype,
      this.sunitno,
      this.imonth,
      this.iyear,
      this.stranscode});

  SingleUnitByMonth.fromJson(
      Map<String, dynamic> json, int index, String prefix) {
    total = json['total'];
    slocation = json['slocation'];
    stype = json['stype'];
    sunitno = json['sunitno'];
    imonth = json['imonth'];
    iyear = json['iyear'];
    stranscode = json['stranscode'];
  }
}

extension SingleUnitByMonthMapper on SingleUnitByMonth {
  Map<String, dynamic> toJson() {
    return {
      'unitNo': sunitno,
      'location': slocation, // match detail page expected key
      'total': total,
      'stype': stype,
      'imonth': imonth,
      'iyear': iyear,
      'stranscode': stranscode,
    };
  }
}
