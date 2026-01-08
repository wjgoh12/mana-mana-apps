import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/New_Dashboard_old/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

const gradientColor1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0XFFFEBD74), Color(0XFFFB6764)]);
const gradientColor2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0XFF8C71E7), Color(0XFF4313E9)]);

// ignore: must_be_immutable
class BarChartSample extends StatelessWidget {
  final NewDashboardVM model;
  BarChartSample({required this.model, Key? key}) : super(key: key);

  final shadowColor = const Color(0xFFCCCCCC);
  final labelColor1 = const Color(0XFFFEBD74);
  final labelColor2 = const Color(0XFF8C71E7);

  final List<Color> monthColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    Colors.grey,
    Colors.black,
  ];
  final monthColor =
      LinearGradient(colors: [Color(0xFF2900B7), Color(0xFF120051)]);

  BarChartGroupData generateBarGroup(
    int x,
    double value1,
    double value2,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barsSpace: 2,
      barRods: [
        BarChartRodData(
          toY: value1 + value2,
          width: 20,
          borderRadius: BorderRadius.zero,
          rodStackItems: [
            BarChartRodStackItem(0, value1, Colors.blue),
            BarChartRodStackItem(
                value1, value1 + value2, Colors.red), // Second value
          ],
        ),
      ],
    );
  }

  int touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        model.monthlyProfitOwner.isNotEmpty || model.monthlyBlcOwner.isNotEmpty;

    final List<String> monthNames = List.generate(12, (index) {
      String month;
      if (index < model.monthlyBlcOwner.length) {
        month = model.monthlyBlcOwner[index]['month'].toString();
      } else if (index < model.monthlyProfitOwner.length) {
        month = model.monthlyProfitOwner[index]['month'].toString();
      } else {
        month = '0';
      }

      switch (month) {
        case '1':
          return 'Jan';
        case '2':
          return 'Feb';
        case '3':
          return 'Mar';
        case '4':
          return 'Apr';
        case '5':
          return 'May';
        case '6':
          return 'Jun';
        case '7':
          return 'Jul';
        case '8':
          return 'Aug';
        case '9':
          return 'Sep';
        case '10':
          return 'Oct';
        case '11':
          return 'Nov';
        case '12':
          return 'Dec';
        default:
          return '';
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 80.width,
        height: 20.height,
        child: AspectRatio(
          aspectRatio: 1.4,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 700,
              child: Stack(
                children: [
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceBetween,
                      borderData: FlBorderData(
                        show: true,
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: const Color(0XFF999999).withOpacity(0.2),
                          ),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          drawBelowEverything: true,
                          sideTitles: SideTitles(
                            showTitles: false,
                            reservedSize: 35.fSize,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50.fSize,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final int index = value.toInt();
                              int year = index < model.monthlyBlcOwner.length
                                  ? model.monthlyBlcOwner[index]['year']
                                  : DateTime.now().year;
                              return ColoredSideTitleWidget(
                                axisSide: meta.axisSide,
                                value: value,
                                monthNames: monthNames,
                                monthColors: monthColor,
                                year: year,
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: const Color(0XFF999999).withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: List.generate(12, (index) {
                        final profit = index < model.monthlyProfitOwner.length
                            ? model.monthlyProfitOwner[index]['total']
                                .toDouble()
                            : 0.0;
                        final blc = index < model.monthlyBlcOwner.length
                            ? model.monthlyBlcOwner[index]['total'].toDouble()
                            : 0.0;
                        return generateBarGroup(index, profit, blc);
                      }).toList(),
                      barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.transparent,
                          tooltipMargin: 0,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toString(),
                              TextStyle(
                                fontWeight: FontWeight.bold,
                                color: rod.color,
                                fontFamily: 'Open Sans',
                                fontSize: 15.fSize,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 150),
                    swapAnimationCurve: Curves.linear,
                  ),
                  if (!hasData)
                    const Center(
                      child: Text(
                        'No Records',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _BarData {
  const _BarData(this.color, this.value, this.shadowValue);
  final LinearGradient color;
  final double value;
  final double shadowValue;
}

class ColoredSideTitleWidget extends StatelessWidget {
  final double value;
  final List<String> monthNames;
  final LinearGradient monthColors;
  final AxisSide axisSide;
  final int year;

  const ColoredSideTitleWidget({
    super.key,
    required this.value,
    required this.monthNames,
    required this.monthColors,
    required this.axisSide,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final int index = value.toInt();
    return SideTitleWidget(
      axisSide: axisSide,
      child: Column(
        children: [
          GradientText1(
            text: monthNames[index],
            style: TextStyle(fontSize: 15.fSize),
            gradient: monthColors,
          ),
          if (monthNames[index].isNotEmpty)
            GradientText1(
              text: year.toString(),
              style: TextStyle(fontSize: 12.fSize),
              gradient: monthColors,
            ),
        ],
      ),
    );
  }
}
