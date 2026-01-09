import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';
import 'package:mana_mana_app/screens/property_detail/view_model/property_detail_view_model.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class UnitOverviewContainer extends StatelessWidget {
  const UnitOverviewContainer({Key? key}) : super(key: key);

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
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    // Listen to both models for changes
    final propertyModel = Provider.of<PropertyDetailVM>(context);
    final dashboardModel = Provider.of<NewDashboardVM_v3>(context);

    // Get the currently selected property and unit
    final selectedProperty = propertyModel.selectedProperty;
    final selectedUnit = propertyModel.selectedUnitNo;
    final selectedType = propertyModel.selectedType;

    // Check if we have valid selections
    if (selectedProperty == null ||
        selectedUnit == null ||
        selectedType == null) {
      return const SizedBox.shrink();
    }

    // Check if there's any data for this specific unit
    final hasData = propertyModel.unitByMonth.any(
      (unit) =>
          unit.slocation == selectedProperty &&
          unit.stype == selectedType &&
          unit.sunitno == selectedUnit,
    );
    Map<String, String> getPreviousMonthYear(DateTime now) {
      int prevMonth = now.month - 1;
      int year = now.year;

      if (prevMonth == 0) {
        prevMonth = 12; // December
        year -= 1; // Go back one year
      }

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
        'Dec',
      ];

      return {
        "month": months[prevMonth - 1],
        "year": year.toString(),
      };
    }

    // Also check if the selected unit data has meaningful values (not just 0.00)
    final hasMeaningfulData = hasData &&
        (propertyModel.selectedUnitPro?.total != 0.0 ||
            propertyModel.selectedUnitBlc?.total != 0.0);

    if (!hasData || !hasMeaningfulData) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(16)),
        padding: EdgeInsets.all(ResponsiveSize.scaleWidth(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
              SizedBox(height: ResponsiveSize.scaleHeight(16)),
              Text(
                'No data available for this unit',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: ResponsiveSize.text(16),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get the monthly profit (NOPROF)
    final monthlyProfit = propertyModel.selectedUnitPro?.total ?? 0.0;
    final formattedMonthlyProfit =
        monthlyProfit.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

    // Get the net profit after POB (OWNBAL)
    final netProfit = propertyModel.selectedUnitBlc?.total ?? 0.0;
    final formattedNetProfit = netProfit.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    // Get occupancy rate from the dashboard model
    double occupancyRate = 0.0;
    // Get occupancy from the dashboard model (now with improved fallback logic)
    String occString = dashboardModel.getUnitOccupancyFromCache(
      selectedProperty,
      selectedUnit,
    );
    occupancyRate = double.tryParse(occString) ?? 0.0;

    // Debug: only log if we have a meaningful occupancy rate
    if (occupancyRate > 0) {
      // print(
      //     '✅ Group Occupancy for $selectedProperty unit $selectedUnit: $occupancyRate%');
    }

    final formattedOcc = '${occupancyRate.toStringAsFixed(1)}%';

    final prev = getPreviousMonthYear(DateTime.now());

    String shortMonth = prev["month"]!;
    String year = prev["year"]!;

    Widget buildCard(
      String title,
      String value,
      String footer,
      String color,
      String fontColor,
      String circleColor,
      Widget icon, {
      bool isCurrency = true,
      VoidCallback? onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            elevation: 2,
            color: Color(int.parse(color)),
            child: Container(
              height: MediaQuery.of(context).size.width >= 600
                  ? ResponsiveSize.scaleHeight(110)
                  : ResponsiveSize.scaleHeight(90),
              padding: EdgeInsets.all(ResponsiveSize.scaleWidth(8.0)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon on the left
                  Column(
                    children: [
                      SizedBox(height: ResponsiveSize.scaleHeight(8)),
                      Container(
                        width: ResponsiveSize.scaleWidth(45),
                        height: ResponsiveSize.scaleWidth(45),
                        decoration: BoxDecoration(
                          color: Color(int.parse(circleColor)),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding:
                              EdgeInsets.all(ResponsiveSize.scaleWidth(10)),
                          child: icon,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: ResponsiveSize.scaleWidth(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ResponsiveSize.scaleHeight(8)),
                        Container(
                          height: ResponsiveSize.scaleHeight(25),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'outfit',
                              fontSize: ResponsiveSize.text(10),
                              color: Color(int.parse(fontColor)),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveSize.scaleHeight(8)),
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
                                        color: Color(int.parse(fontColor)),
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
                                  color: Color(int.parse(fontColor)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveSize.scaleHeight(4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildCard(
                    'Monthly Profit',
                    formattedMonthlyProfit,
                    '$shortMonth $year',
                    '0xFFFFFFFF',
                    '0xFF606060',
                    '0xFF606060',
                    Image.asset(
                      'assets/images/wallet_property.png',
                      width: ResponsiveSize.scaleWidth(20),
                      height: ResponsiveSize.scaleHeight(20),
                      fit: BoxFit.contain,
                      color: Color(int.parse('0xFFFFCF00')),
                    ),
                  ),
                  const SizedBox(width: 4),
                  buildCard(
                    'Net Profit After POB',
                    formattedNetProfit,
                    '$shortMonth $year',
                    '0xFFFFFFFF',
                    '0xFF606060',
                    '0xFF606060',
                    Image.asset(
                      'assets/images/property_net_profit.png',
                      width: ResponsiveSize.scaleWidth(20),
                      height: ResponsiveSize.scaleWidth(20),
                      fit: BoxFit.contain,
                      color: Color(int.parse('0xFFFFCF00')),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveSize.scaleHeight(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildCard(
                    '$year Accumulated Profit',
                    formattedNetProfit,
                    '$shortMonth $year',
                    '0xFFFFFFFF',
                    '0xFF606060',
                    '0xFF606060',
                    Image.asset(
                      'assets/images/property_accumulated.png',
                      width: ResponsiveSize.scaleWidth(20),
                      height: ResponsiveSize.scaleWidth(20),
                      fit: BoxFit.contain,
                      color: Color(int.parse('0xFFFFCF00')),
                    ),
                  ),
                  const SizedBox(width: 4),
                  buildCard(
                    'Group Occupancy',
                    formattedOcc,
                    '$shortMonth $year',
                    '0xFFFFFFFF',
                    '0xFF000000',
                    '0xFF606060',
                    Image.asset(
                      'assets/images/property_occupancy.png',
                      width: MediaQuery.of(context).size.width >= 600
                          ? ResponsiveSize.scaleWidth(25)
                          : ResponsiveSize.scaleWidth(20),
                      fit: BoxFit.contain,
                      color: Color(int.parse('0xFFFFCF00')),
                    ),
                    isCurrency: false,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
