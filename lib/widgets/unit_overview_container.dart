import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class UnitOverviewContainer extends StatelessWidget {
  final NewDashboardVM_v3 model;
  final PropertyDetailVM model2;

  const UnitOverviewContainer({
    Key? key,
    required this.model,
    required this.model2,
  }) : super(key: key);

  String monthNumberToName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    // Get the monthly profit (NOPROF)
    final monthlyProfit = model2.selectedUnitPro?.total ?? 0.0;
    final formattedMonthlyProfit =
        monthlyProfit.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

    // Get the net profit after POB (OWNBAL)
    final netProfit = model2.selectedUnitBlc?.total ?? 0.0;
    final formattedNetProfit = netProfit.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    // Get occupancy rate from the property detail model
    double occupancyRate = 0.0;
    if (model2.selectedUnitNo != null && model2.locationByMonth.isNotEmpty) {
      for (var entry in model2.locationByMonth) {
        if (entry is Map<String, dynamic> && entry['units'] is Map) {
          Map<String, dynamic> units = entry['units'] as Map<String, dynamic>;
          if (units.containsKey(model2.selectedUnitNo)) {
            occupancyRate = units[model2.selectedUnitNo]['occupancy'] ?? 0.0;
            break;
          }
        }
      }
    }
    final formattedOcc = '${occupancyRate.toStringAsFixed(1)}%';

    DateTime now = DateTime.now();
    String shortMonth = monthNumberToName(now.month);
    String year = now.year.toString();

    Widget buildCard(String title, String value, String footer,
        {bool isCurrency = true}) {
      return Expanded(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: ResponsiveSize.scaleHeight(90),
            padding: EdgeInsets.all(ResponsiveSize.scaleWidth(8.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'outfit',
                    fontSize: ResponsiveSize.text(11),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      if (isCurrency)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: Transform.translate(
                            offset: const Offset(0, -4),
                            child: Text(
                              'RM',
                              style: TextStyle(
                                fontFamily: 'outfit',
                                fontSize: ResponsiveSize.text(10),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          fontFamily: 'outfit',
                          fontSize: ResponsiveSize.text(15),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveSize.scaleHeight(4)),
                Text(
                  footer,
                  style: TextStyle(
                    fontFamily: 'outfit',
                    fontSize: ResponsiveSize.text(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCard('Monthly Profit', formattedMonthlyProfit,
                  '$shortMonth $year'),
              const SizedBox(width: 8),
              buildCard('Net Profit After POB', formattedNetProfit,
                  '$shortMonth $year'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCard('$year Accumulated Profit', formattedNetProfit,
                  '$shortMonth $year'),
              const SizedBox(width: 8),
              buildCard('Group Occupancy', formattedOcc, '$shortMonth $year',
                  isCurrency: false),
            ],
          ),
        ],
      ),
    );
  }
}
