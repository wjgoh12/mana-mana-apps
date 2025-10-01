import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_rate_box.dart';

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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
    if (selectedUnit != null && selectedProperty != null) {
      // Get occupancy from the dashboard model (now with improved fallback logic)
      String occString = dashboardModel.getUnitOccupancyFromCache(
        selectedProperty,
        selectedUnit,
      );
      occupancyRate = double.tryParse(occString) ?? 0.0;
      
      // Debug: only log if we have a meaningful occupancy rate
      if (occupancyRate > 0) {
        print('✅ Group Occupancy for $selectedProperty unit $selectedUnit: $occupancyRate%');
      }
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
      String fontColor, {
      bool isCurrency = true,
      VoidCallback? onTap, // Add onTap parameter
    }) {
      return Expanded(
        child: InkWell(
          // Wrap Card with InkWell
          onTap: onTap,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            color: Color(int.parse(color)),
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
                      color: Color(int.parse(fontColor)),
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
                  Text(
                    footer,
                    style: TextStyle(
                      fontFamily: 'outfit',
                      fontSize: ResponsiveSize.text(10),
                      color: Color(int.parse(fontColor)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    void _showOccupancyDialog(BuildContext context, String occupancyRate) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog();
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCard(
                'Monthly Profit',
                formattedMonthlyProfit,
                '$shortMonth $year',
                '0xFF5092FF',
                '0xFFFFFFFF',
              ),
              const SizedBox(width: 8),
              buildCard(
                'Net Profit After POB',
                formattedNetProfit,
                '$shortMonth $year',
                '0xFF9EEAFF',
                '0xFF000000',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCard(
                '$year Accumulated Profit',
                formattedNetProfit,
                '$shortMonth $year',
                '0xFFFFE7B8',
                '0xFF000000',
              ),
              const SizedBox(width: 8),
              buildCard('Group Occupancy', formattedOcc, '$shortMonth $year',
                  '0xFFDBC7FF', '0xFF000000',
                  isCurrency: false, onTap: () {}
                  // => showDialog(
                  //   context: context,
                  //   barrierDismissible: false,
                  //   builder: (BuildContext context) => AlertDialog(
                  //     backgroundColor:
                  //         Colors.transparent, // Set transparent background
                  //     elevation: 0, // Remove dialog shadow
                  //     insetPadding: EdgeInsets.symmetric(
                  //       horizontal: ResponsiveSize.scaleWidth(20),
                  //       vertical: ResponsiveSize.scaleHeight(40),
                  //     ),
                  //     content: ChangeNotifierProvider.value(
                  //       value: dashboardModel,
                  //       child: OccupancyRateBox(
                  //         model: dashboardModel,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
