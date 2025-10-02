import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_rate_dropdown.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_line_chart.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/profit_chart.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:provider/provider.dart';

final labelColor1 = const Color(0xFF8C71E7);
final barBackgroundColor = const Color(0xFFDDD7FF);

class ProfitBox extends StatefulWidget {
  final NewDashboardVM_v3? model; // Optional model parameter

  const ProfitBox({super.key, this.model});

  @override
  State<ProfitBox> createState() => _ProfitBoxState();
}

class _ProfitBoxState extends State<ProfitBox> {
  String selectedPeriod = 'Monthly';
  int touchedGroupIndex = -1;

  BarChartGroupData generateBarGroup(
    int x,
    Color color,
    double value,
  ) {
    return BarChartGroupData(
      x: x,
      barsSpace: 0.7.width,
      barRods: [
        BarChartRodData(
          toY: value,
          color: labelColor1,
          width: 3.width,
        ),
      ],
      showingTooltipIndicators: touchedGroupIndex == x ? [0, 1] : [],
    );
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    final model = widget.model ?? context.read<NewDashboardVM_v3>();

    final width = 350.0;
    final height = 280.0;
    final fontScale = 1.0;

    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important: prevents extra space
          children: [
            Container(
              // width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3E51FF).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          child: Text(
                            'Accumulated Profit',
                            style: TextStyle(
                              fontFamily: 'outfit',
                              fontSize: ResponsiveSize.text(15),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: OccupancyPeriodDropdown(
                          selectedValue: selectedPeriod,
                          onChanged: (value) {
                            setState(() {
                              selectedPeriod = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ProfitChart(
                        period: selectedPeriod,
                        model: model,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ));
  }
}

class _BarData {
  const _BarData(this.color, this.value, this.maxValue);
  final Color color;
  final double value;
  final double maxValue;
}
