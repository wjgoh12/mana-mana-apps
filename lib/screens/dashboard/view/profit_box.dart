import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:mana_mana_app/screens/all_properties/widgets/occupancy_rate_dropdown.dart';
import 'package:mana_mana_app/screens/dashboard/view/profit_chart.dart';
import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:provider/provider.dart';

const labelColor1 = Color(0xFF8C71E7);
const barBackgroundColor = Color(0xFFDDD7FF);

class ProfitBox extends StatefulWidget {
  final NewDashboardVM_v3? model;

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

    const height = 280.0;

    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                          padding: const EdgeInsets.only(left: 10, top: 15),
                          child: Text(
                            'Accumulated Profit',
                            style: TextStyle(
                              fontFamily: AppFonts.outfit,
                              fontSize: AppDimens.fontSizeBig,
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
            const SizedBox(height: 16),
          ],
        ));
  }
}

// ignore: unused_element
class _BarData {
  const _BarData(this.color, this.value, this.maxValue);
  final Color color;
  final double value;
  final double maxValue;
}
