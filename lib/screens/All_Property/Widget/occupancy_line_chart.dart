import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/resources/app_colors.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class OccupancyBarChart extends StatelessWidget {
  const OccupancyBarChart({
    super.key,
    required this.isShowingMainData,
    required this.period,
    this.model, // Add optional model parameter
  });

  final bool isShowingMainData;
  final String period;
  final NewDashboardVM_v3? model; // Optional model to use real data

  @override
  Widget build(BuildContext context) {
    return LineChart(
      isShowingMainData ? sampleData1 : sampleData2,
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        minX: 0,
        maxX: getMaxX(),
        maxY: 6,
        minY: 0,
      );

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        minX: 0,
        maxX: getMaxX(),
        maxY: 6,
        minY: 0,
      );

  double getMaxX() {
    switch (period) {
      case 'Quarterly':
        return 3; // Q1-Q4
      case 'Yearly':
        return 3; // last 4 years
      case 'Monthly':
      default:
        return 14; // keep current monthly
    }
  }

  List<FlSpot> getSpots() {
    switch (period) {
      case 'Quarterly':
        return const [
          FlSpot(0, 2),
          FlSpot(1, 3),
          FlSpot(2, 1.5),
          FlSpot(3, 4),
        ];
      case 'Yearly':
        return const [
          FlSpot(0, 1.5),
          FlSpot(1, 3),
          FlSpot(2, 2),
          FlSpot(3, 4.5),
        ];
      case 'Monthly':
      default:
        return const [
          FlSpot(0, 0),
          FlSpot(2, 3),
          FlSpot(7, 2),
          FlSpot(12, 2.5),
        ];
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontFamily: 'outfit',
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    switch (period) {
      case 'Quarterly':
        const labels = ['Q1', 'Q2', 'Q3', 'Q4'];
        return SideTitleWidget(
          axisSide: AxisSide.bottom,
          space: 10,
          child: Text(labels[value.toInt() % 4], style: style),
        );
      case 'Yearly':
        return SideTitleWidget(
          axisSide: AxisSide.bottom,
          space: 10,
          child: Text('${2020 + value.toInt()}', style: style),
        );
      case 'Monthly':
      default:
        String text;
        switch (value.toInt()) {
          case 2:
            text = 'SEPT';
            break;
          case 7:
            text = 'OCT';
            break;
          case 12:
            text = 'NOV';
            break;
          default:
            text = '';
            break;
        }
        return SideTitleWidget(
          axisSide: AxisSide.bottom,
          space: 10,
          child: Text(text, style: style),
        );
    }
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
            // Add these properties for better tooltip display
            //tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final percentage = barSpot.y * 20;
                final index = barSpot.spotIndex;
                String label = '';
                final xValue = barSpot.x;

                switch (period) {
                  case 'Monthly':
                    switch (xValue.toInt()) {
                      case 2:
                        label = 'SEPT';
                        break;
                      case 7:
                        label = 'OCT';
                        break;
                      case 12:
                        label = 'NOV';
                        break;
                      default:
                        label = '';
                    }
                    break;
                  case 'Quarterly':
                    const quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
                    label = quarters[index % 4];
                    break;
                  case 'Yearly':
                    label = 'Year ${2020 + index}';
                    break;
                }

                return LineTooltipItem(
                  '$label\n${percentage.toStringAsFixed(1)}%',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).toList();
            }),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        //lineChartBarData1_1,
        // lineChartBarData1_2,
        // lineChartBarData1_3,
        LineChartBarData(
          isCurved: true,
          color: const Color(0XFF8C71E7),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
          spots: getSpots(),
        ),
      ];

  LineTouchData get lineTouchData2 => const LineTouchData(
        enabled: false,
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData2 => [
        // lineChartBarData2_1,
        // lineChartBarData2_2,
        // lineChartBarData2_3,
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontFamily: 'outfit',
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 1:
        text = '20';
        break;
      case 2:
        text = '40';
        break;
      case 3:
        text = '60';
        break;
      case 4:
        text = '80';
        break;
      case 5:
        text = '100';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: AxisSide.left,
      space: 0,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: (value, meta) {
          return leftTitleWidgets(value, meta);
        },
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  // Widget bottomTitleWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     fontWeight: FontWeight.bold,
  //     fontSize: 12,
  //   );
  //   Widget text;
  //   switch (value.toInt()) {
  //     case 0:
  //       text = const Text('', style: style);
  //       break;
  //     case 2:
  //       text = const Text('SEPT', style: style);
  //       break;
  //     case 7:
  //       text = const Text('OCT', style: style);
  //       break;
  //     case 12:
  //       text = const Text('NOV', style: style);
  //       break;
  //     default:
  //       text = const Text('');
  //       break;
  //   }

  //   return SideTitleWidget(
  //     axisSide: AxisSide.bottom,
  //     //meta: meta,
  //     space: 10,
  //     child: text,
  //   );
  // }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
              width: 2),
          left: const BorderSide(color: Colors.black12, width: 1),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: const Color(0XFF8C71E7),
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(0, 0),
          FlSpot(2, 3),
          // FlSpot(5, 1.4),
          FlSpot(7, 2),
          // FlSpot(12, 2.2),
          FlSpot(12, 2.5),
        ],
      );

  // LineChartBarData get lineChartBarData1_2 => LineChartBarData(
  //       isCurved: true,
  //       color: AppColors.contentColorPink,
  //       barWidth: 8,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: false),
  //       belowBarData: BarAreaData(
  //         show: false,
  //         color: AppColors.contentColorPink.withOpacity(0),
  //       ),
  //       spots: const [
  //         FlSpot(1, 1),
  //         FlSpot(3, 2.8),
  //         FlSpot(7, 1.2),
  //         FlSpot(10, 2.8),
  //         FlSpot(12, 2.6),
  //         FlSpot(13, 3.9),
  //       ],
  //     );

  // LineChartBarData get lineChartBarData1_3 => LineChartBarData(
  //       isCurved: true,
  //       color: AppColors.contentColorCyan,
  //       barWidth: 8,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: false),
  //       belowBarData: BarAreaData(show: false),
  //       spots: const [
  //         FlSpot(1, 2.8),
  //         FlSpot(3, 1.9),
  //         FlSpot(6, 3),
  //         FlSpot(10, 1.3),
  //         FlSpot(13, 2.5),
  //       ],
  //     );

  // LineChartBarData get lineChartBarData2_1 => LineChartBarData(
  //       isCurved: true,
  //       curveSmoothness: 0,
  //       color: Color(0xFF8C71E7).withOpacity(0.5),
  //       barWidth: 4,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: true),
  //       belowBarData: BarAreaData(show: false),
  //       spots: const [
  //         FlSpot(1, 1),
  //         FlSpot(3, 4),
  //         FlSpot(5, 1.8),
  //         FlSpot(7, 5),
  //         FlSpot(10, 2),
  //         FlSpot(12, 2.2),
  //         FlSpot(13, 1.8),
  //       ],
  //     );

  // LineChartBarData get lineChartBarData2_2 => LineChartBarData(
  //       isCurved: true,
  //       color: AppColors.contentColorPink.withOpacity(0.5),
  //       barWidth: 4,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: false),
  //       belowBarData: BarAreaData(
  //         show: true,
  //         color: AppColors.contentColorPink.withOpacity(0.2),
  //       ),
  //       spots: const [
  //         FlSpot(1, 1),
  //         FlSpot(3, 2.8),
  //         FlSpot(7, 1.2),
  //         FlSpot(10, 2.8),
  //         FlSpot(12, 2.6),
  //         FlSpot(13, 3.9),
  //       ],
  //     );

  // LineChartBarData get lineChartBarData2_3 => LineChartBarData(
  //       isCurved: true,
  //       curveSmoothness: 0,
  //       color: AppColors.contentColorCyan.withOpacity(0.5),
  //       barWidth: 2,
  //       isStrokeCapRound: true,
  //       dotData: const FlDotData(show: true),
  //       belowBarData: BarAreaData(show: false),
  //       spots: const [
  //         FlSpot(1, 3.8),
  //         FlSpot(3, 1.9),
  //         FlSpot(6, 5),
  //         FlSpot(10, 3.3),
  //         FlSpot(13, 4.5),
  //       ],
  //     );
}

class LineChart1 extends StatefulWidget {
  const LineChart1({super.key});

  @override
  State<StatefulWidget> createState() => LineChart1State();
}

class LineChart1State extends State<LineChart1> {
  late bool isShowingMainData;
  String selectedPeriod = 'Monthly';

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 37,
              ),
              Text(
                'Occupancy Rate',
                style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'outfit',
                  fontSize: ResponsiveSize.text(32),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 37,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 6),
                  child: OccupancyBarChart(
                    isShowingMainData: isShowingMainData,
                    period: selectedPeriod,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white.withOpacity(isShowingMainData ? 1.0 : 0.5),
            ),
            onPressed: () {
              setState(() {
                isShowingMainData = !isShowingMainData;
              });
            },
          )
        ],
      ),
    );
  }
}
