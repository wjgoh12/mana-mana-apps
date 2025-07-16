
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OccupancyBarChart extends StatelessWidget {
  final List<OccupancyData> data;

  const OccupancyBarChart({required this.data, Key? key}) : super(key: key);

  BarChartGroupData makeGroup(int x, OccupancyData d) {
  return BarChartGroupData(
    x: x.toInt(),
    barsSpace: 0,
    barRods: [
      // Full 100% background
      BarChartRodData(toY: 100.0, color: Color(0xFFDDD7FF), width: 20),
      // Actual occupancy
      BarChartRodData(toY: d.occupancyRate.toDouble(), color: Color(0xFF8C71E7), width: 20),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    final groups = data.asMap().entries.map((e) => makeGroup(e.key, e.value)).toList();

    return SizedBox(
      height: 190,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: data.length * 40.0,
          child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: 100,
                    barGroups: groups,
                    alignment: BarChartAlignment.spaceBetween,
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true, 
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(data[index].month),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 20),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),

        ),
      ),
    );
  }
}



class OccupancyData{
  final String month;
  final int occupancyRate;

  OccupancyData(this.month, this.occupancyRate);
}