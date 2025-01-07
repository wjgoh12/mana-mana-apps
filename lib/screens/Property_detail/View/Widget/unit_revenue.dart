import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/overall_revenue_container.dart';

class UnitRevenue extends StatelessWidget {
  final PropertyDetailVM model;
  const UnitRevenue({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String getMonthName(int month) {
      switch (month) {
        case 1:
          return 'Jan';
        case 2:
          return 'Feb';
        case 3:
          return 'Mar';
        case 4:
          return 'Apr';
        case 5:
          return 'May';
        case 6:
          return 'Jun';
        case 7:
          return 'Jul';
        case 8:
          return 'Aug';
        case 9:
          return 'Sep';
        case 10:
          return 'Oct';
        case 11:
          return 'Nov';
        case 12:
          return 'Dec';
        default:
          return '';
      }
    }

    return OverallRevenueContainer(
      text1: 'Monthly Profit',
      text2:
          'RM ${model.selectedUnitPro.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0.00'}',
      // text2: 'RM ${selectedUnitPro.total?.toStringAsFixed(2) ?? '0.00'}',
      text3: '${getMonthName(model.unitLatestMonth)} ${model.unitLatestYear}',
      text4: 'Net After POB​',
      text5:
          'RM ${model.selectedUnitBlc.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0.00'}',
      // text5: 'RM ${selectedUnitBlc.total?.toStringAsFixed(2) ?? '0.00'}',
      text6: '${getMonthName(model.unitLatestMonth)} ${model.unitLatestYear}',
      color: const Color(0XFF4313E9),
      backgroundColor: const Color(0XFFFFFFFF),
    );
  }
}
