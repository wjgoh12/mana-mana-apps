import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
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
      'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    // Listen to both models for changes
    final propertyModel = Provider.of<PropertyDetailVM>(context);
    final dashboardModel = Provider.of<NewDashboardVM_v3>(context);

    final properties = dashboardModel.ownerUnits
        .map((unit) => unit.location)
        .where((location) => location != null)
        .toSet()
        .toList();

    // Get the currently selected property and unit
    final selectedProperty = propertyModel.selectedProperty;
    final selectedUnit = propertyModel.selectedUnitNo;

    // Get units for selected property
    final units = selectedProperty != null
        ? dashboardModel.ownerUnits
            .where((unit) => unit.location == selectedProperty)
            .map((unit) => unit.unitno)
            .where((unitno) => unitno != null)
            .toSet()
            .toList()
        : <String>[];

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

    // Get occupancy rate from the property detail model
    double occupancyRate = 0.0;
    if (selectedUnit != null && selectedProperty != null) {
      // Try to get occupancy from the dashboard model first
      String occString = dashboardModel.getUnitOccupancyFromCache(
          selectedProperty, selectedUnit);
      occupancyRate = double.tryParse(occString.replaceAll('%', '')) ?? 0.0;

      // Fallback to property model if needed
      if (occupancyRate == 0.0 && propertyModel.locationByMonth.isNotEmpty) {
        final currentLocation = propertyModel.locationByMonth.firstWhere(
          (location) => location['location'] == selectedProperty,
          orElse: () => {},
        );

        if (currentLocation.containsKey('units')) {
          final units = currentLocation['units'] as Map<String, dynamic>;
          if (units.containsKey(selectedUnit)) {
            occupancyRate = units[selectedUnit]['occupancy'] ?? 0.0;
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
