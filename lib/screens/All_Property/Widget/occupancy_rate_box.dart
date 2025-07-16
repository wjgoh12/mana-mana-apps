  import 'package:dropdown_button2/dropdown_button2.dart';
  import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_rate_dropdown.dart';
  import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_bar_chart.dart';
  import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
  import 'package:flutter/material.dart';
  import 'package:fl_chart/fl_chart.dart';
  import 'package:mana_mana_app/widgets/size_utils.dart';


    final labelColor1 = const Color(0xFF8C71E7);
    final barBackgroundColor = const Color(0xFFDDD7FF);
  class OccupancyRateBox extends StatefulWidget{
    final model=NewDashboardVM_v3();
  
    OccupancyRateBox({super.key});


    BarChartGroupData generateBarGroup(
      int x,
      Color color,
      double value,
    ){
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
      int touchedGroupIndex = -1;

    @override
    State<OccupancyRateBox> createState() => _OccupancyRateBoxState();



  }

  class _OccupancyRateBoxState extends State<OccupancyRateBox> {
  
    @override
    Widget build(BuildContext context) {

      // final dataList=[
      //   ...List.generate(6,
      //   (index) => _BarData(labelColor1,60, 100))
      // ];

      return Container(
        alignment: Alignment.topLeft,
        width: 390,
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF3E51FF).withOpacity(0.15),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                  ),
                ),
                Flexible(
                  child: OccupancyPeriodDropdown(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: OccupancyBarChart(isShowingMainData: true),
              ),
            ),
          ],
        ),
      );
    }

  }



  class _BarData {
    const _BarData(this.color, this.value, this.maxValue);
    final Color color;
    final double value;
    final double maxValue;
  }