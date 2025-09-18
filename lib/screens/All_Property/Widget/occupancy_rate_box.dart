import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_rate_dropdown.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_line_chart.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:provider/provider.dart';

final labelColor1 = const Color(0xFF8C71E7);
final barBackgroundColor = const Color(0xFFDDD7FF);

class OccupancyRateBox extends StatefulWidget {
  final NewDashboardVM_v3? model; // Optional model parameter

  const OccupancyRateBox({super.key, this.model});

  @override
  State<OccupancyRateBox> createState() => _OccupancyRateBoxState();
}

class _OccupancyRateBoxState extends State<OccupancyRateBox> {
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
  Widget build(BuildContext context) {
    // Get the model from Provider or use the passed model
    final model = widget.model ?? context.read<NewDashboardVM_v3>();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // scale factors (adjust as you like)
    final width = screenWidth * 0.92; // 90% of screen width
    final height =
        screenHeight * 0.3; // Reduced from 0.4 to 0.3 for shorter height
    final fontScale = screenWidth / 390; // relative to your original 390 width

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10 * fontScale),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3E51FF).withOpacity(0.15),
                blurRadius: 10 * fontScale,
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
                      padding: EdgeInsets.only(
                          left: 10 * fontScale, top: 15 * fontScale),
                      child: Text(
                        'Occupancy Rate',
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
              SizedBox(height: 10 * fontScale),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0 * fontScale),
                  child: OccupancyBarChart(
                    isShowingMainData: true,
                    period: selectedPeriod,
                    model: model, // Pass the model to the chart
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8C71E7),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Close',
            style: TextStyle(
              fontFamily: 'outfit',
              fontSize: ResponsiveSize.text(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BarData {
  const _BarData(this.color, this.value, this.maxValue);
  final Color color;
  final double value;
  final double maxValue;
}
