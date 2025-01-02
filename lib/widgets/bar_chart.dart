import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Dashboard/ViewModel/dashboardVM.dart';
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

class BarChartSample7 extends StatefulWidget {
  BarChartSample7({super.key});

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
  @override
  State<BarChartSample7> createState() => _BarChartSample7State();
}

class _BarChartSample7State extends State<BarChartSample7> {
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
      showingTooltipIndicators: touchedGroupIndex == x ? [0, 1] : [],
    );
  }

  int touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    DashboardVM model = DashboardVM();
    return ListenableBuilder(
        listenable: DashboardVM(),
        builder: (context, _) {
          final dataList = [
            ...List.generate(
                12,
                (index) => _BarData(
                    gradientColor1,
                    index < model.monthlyProfitOwner.length
                        ? model.monthlyProfitOwner[index]['total']
                        : 0,
                    index < model.monthlyBlcOwner.length
                        ? model.monthlyBlcOwner[index]['total']
                        : 0
                    // index < model.monthlyProfitOwner.length && model.monthlyProfitOwner[index]['year'] == DateTime.now().year ? model.monthlyProfitOwner[index]['total'] : 0,
                    // index < model.monthlyBlcOwner.length && model.monthlyBlcOwner[index]['year'] == DateTime.now().year ? model.monthlyBlcOwner[index]['total'] : 0
                    )),
          ];

          final List<String> monthNames = List.generate(12, (index) {
            String month;
            if (index < model.monthlyBlcOwner.length) {
              month = model.monthlyBlcOwner[index]['month'].toString();
            } else if (index < model.monthlyProfitOwner.length) {
              month = model.monthlyProfitOwner[index]['month'].toString();
            } else {
              month = '0';
            }
            // if (index < model.monthlyBlcOwner.length && model.monthlyBlcOwner[index]['year'] == DateTime.now().year) {
            //   month = model.monthlyBlcOwner[index]['month'].toString();
            // } else if (index < model.monthlyProfitOwner.length && model.monthlyProfitOwner[index]['year'] == DateTime.now().year) {
            //   month = model.monthlyProfitOwner[index]['month'].toString();
            // } else {
            //   month = '0';
            // }

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
          // _BarData(gradientColor1, 160, 125),
          // _BarData(gradientColor1, 170, 110),

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
                    width: 700, // Adjust this value as needed
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
                                  monthColors: widget.monthColor,
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
                          enabled: false,
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
                        ),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 150),
                      swapAnimationCurve: Curves.linear,
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
          if (monthNames[index].isNotEmpty) // Only show year if month exists
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

