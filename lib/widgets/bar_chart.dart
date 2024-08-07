import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Dashboard/ViewModel/dashboardVM.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
const gradientColor1=LinearGradient(begin: Alignment.topCenter,end: Alignment.bottomCenter,colors: [Color(0XFFFEBD74),Color(0XFFFB6764)]);
const gradientColor2=LinearGradient(begin: Alignment.topCenter,end: Alignment.bottomCenter,colors: [Color(0XFF8C71E7),Color(0XFF4313E9)]);
class BarChartSample7 extends StatefulWidget {
  BarChartSample7({super.key});
  
  final shadowColor = const Color(0xFFCCCCCC);
  final labelColor1=const Color(0XFFFEBD74);
  final labelColor2=const Color(0XFF8C71E7);
  
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
  final monthColor=LinearGradient(colors: [Color(0xFF2900B7), Color(0xFF120051)]);
  @override
  State<BarChartSample7> createState() => _BarChartSample7State();
}

class _BarChartSample7State extends State<BarChartSample7> {
  final List<String> monthNames = [
    'May',
    'Jun',
    'Jul',
    'Aug',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  BarChartGroupData generateBarGroup(
    int x,
    LinearGradient color,
    double value,
    double shadowValue,
  ) {
    return BarChartGroupData(
      x: x,
      barsSpace: 1.width,
      barRods: [
        BarChartRodData(
          toY: value,
          gradient: color,
          color: widget.labelColor1,
          width: 3.width,
        ),
        BarChartRodData(
          toY: shadowValue,
          gradient: gradientColor2,
          color: widget.labelColor2,
          width: 2.width,
        ),
      ],
      showingTooltipIndicators: touchedGroupIndex == x ? [0,1] : [],
    );
  }

  int touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DashboardVM(),
      builder: (context, _) {
    final dataList = [
     _BarData(gradientColor1, DashboardVM().totalByMonth.isEmpty ? 0 : DashboardVM().totalByMonth[0]['total'], 0),
    _BarData(gradientColor1, 0, 0),
    _BarData(gradientColor1, 0, 0),
    _BarData(gradientColor1, 0, 0),
    // _BarData(gradientColor1, 160, 125),
    // _BarData(gradientColor1, 170, 110),
  ];
  
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(width: 80.width,
      height: 15.height,
        child: AspectRatio(
          aspectRatio: 1.4,
          child: BarChart(
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
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        textAlign: TextAlign.left,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36.fSize,
                    getTitlesWidget: (double value, TitleMeta meta) {
                  return ColoredSideTitleWidget(
                    axisSide: meta.axisSide,
                    value: value,
                    monthNames: monthNames,
                    monthColors: widget.monthColor,
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
              barGroups: dataList.asMap().entries.map((e) {
                final index = e.key;
                final data = e.value;
                return generateBarGroup(
                  index,
                  data.color,
                  data.value,
                  data.shadowValue,
                );
              }).toList(),            
              barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.transparent,
                  tooltipMargin: 0,
                  getTooltipItem: (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
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
                touchCallback: (event, response) {
                  if (event.isInterestedForInteractions &&
                      response != null &&
                      response.spot != null) {
                    setState(() {
                      touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                    });
                  } else {
                    setState(() {
                      touchedGroupIndex = -1;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
      });
  }
}

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

  const ColoredSideTitleWidget({
    super.key,
    required this.value,
    required this.monthNames,
    required this.monthColors,
    required this.axisSide,
  });

  @override
  Widget build(BuildContext context) {
    final int index = value.toInt();
    return SideTitleWidget(
      axisSide: axisSide,
      child: GradientText1(
        text:monthNames[index],
        style: TextStyle(fontSize: 15.fSize),
        gradient: monthColors,
        ),
      );
  }
}
