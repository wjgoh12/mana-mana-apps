import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:mana_mana_app/screens/all_properties/widgets/occupancy_rate_dropdown.dart';
import 'package:mana_mana_app/screens/all_properties/widgets/occupancy_line_chart.dart';
import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';

const labelColor1 = AppColors.primaryBlue;
const barBackgroundColor = Color(0xFFDDD7FF);

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
  Widget build(BuildContext context) {
    final model = widget.model ?? context.read<NewDashboardVM_v3>();
    final global = context.mounted
        ? Provider.of<GlobalDataManager?>(context, listen: false)
        : null;

    const width = 350.0;
    const height = 280.0;

    return Column(
      mainAxisSize: MainAxisSize.min, // Important: prevents extra space
      children: [
        Container(
          width: width,
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
                        'Occupancy Rate',
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
                  child: OccupancyLineChart(
                    // isShowingMainData: true,
                    period: selectedPeriod,
                    model: model,
                    global: global,
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
              fontFamily: AppFonts.outfit,
              fontSize: AppDimens.fontSizeBig,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _BarData {
  const _BarData(this.color, this.value, this.maxValue);
  final Color color;
  final double value;
  final double maxValue;
}
