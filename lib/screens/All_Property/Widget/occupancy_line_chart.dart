import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/occupancy_rate.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';

class OccupancyLineChart extends StatelessWidget {
  const OccupancyLineChart({
    super.key,
    required this.period,
    this.model,
    this.global,
  });

  final String period;
  final NewDashboardVM_v3? model;
  final GlobalDataManager? global;

  @override
  Widget build(BuildContext context) {
    _currentPeriod = period;
    final data = _getZeroFilledData(
        global?.getOccupancyDataForPeriod(period) ?? const <OccupancyRate>[]);
    final spots = _convertApiDataToSpots(data);

    final extendedMaxX = getExtendedMaxX();

    final chart = LineChart(
      LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: const Color(0XFF8C71E7),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
            spots: spots,
          ),
        ],
        minX: 0,
        maxX: extendedMaxX,
        maxY: 5,
        minY: 0,
      ),
      duration: const Duration(milliseconds: 250),
    );

    if (period == 'Monthly') {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(right: 24),
          child: SizedBox(
            width: 900,
            child: chart,
          ),
        ),
      );
    }

    return chart;
  }

  double getMaxX() {
    switch (period) {
      case 'Quarterly':
        return 3;
      case 'Yearly':
        return 3;
      case 'Monthly':
      default:
        return 11;
    }
  }

  double getExtendedMaxX() {
    switch (period) {
      case 'Monthly':
        return getMaxX() + 0.5; // add padding to show DEC fully
      case 'Quarterly':
      case 'Yearly':
        return getMaxX() + 0.2; // slight padding for last label
      default:
        return getMaxX();
    }
  }

  List<OccupancyRate> _getZeroFilledData(List<OccupancyRate> apiData) {
    final currentYear = DateTime.now().year;

    switch (period) {
      case 'Monthly':
        final map = <int, double>{};
        for (final r in apiData.where((r) => r.year == currentYear)) {
          map[r.month] = r.amount;
        }
        final filled = <OccupancyRate>[];
        for (int m = 1; m <= 12; m++) {
          filled.add(
              OccupancyRate(year: currentYear, month: m, amount: map[m] ?? 0));
        }
        return filled;

      case 'Quarterly':
        final quarters = <int, double>{};
        final counts = <int, int>{};
        for (final r in apiData.where((r) => r.year == currentYear)) {
          final q = ((r.month - 1) ~/ 3) + 1;
          quarters[q] = (quarters[q] ?? 0.0) + r.amount;
          counts[q] = (counts[q] ?? 0) + 1;
        }
        final filledQ = <OccupancyRate>[];
        for (int q = 1; q <= 4; q++) {
          final has = (counts[q] ?? 0) > 0;
          final avg =
              has ? ((quarters[q] ?? 0.0) / (counts[q] ?? 1)).toDouble() : 0.0;
          filledQ
              .add(OccupancyRate(year: currentYear, month: q * 3, amount: avg));
        }
        return filledQ;

      case 'Yearly':
        final startYear = currentYear - 3;
        final yearToAmount = <int, double>{};
        final yearToCount = <int, int>{};
        for (final r in apiData) {
          if (r.year >= startYear && r.year <= currentYear) {
            yearToAmount[r.year] = (yearToAmount[r.year] ?? 0) + r.amount;
            yearToCount[r.year] = (yearToCount[r.year] ?? 0) + 1;
          }
        }
        final filledY = <OccupancyRate>[];
        for (int i = 0; i < 4; i++) {
          final y = startYear + i;
          double value = 0;
          if ((yearToCount[y] ?? 0) > 0) {
            value = (yearToAmount[y] ?? 0) / (yearToCount[y] ?? 1);
          }
          filledY.add(OccupancyRate(year: y, month: 12, amount: value));
        }
        return filledY;
    }

    return apiData;
  }

  List<FlSpot> _convertApiDataToSpots(List<OccupancyRate> apiData) {
    final spots = <FlSpot>[];

    switch (period) {
      case 'Monthly':
        final currentYear = DateTime.now().year;
        final monthlyData = apiData
            .where((rate) => rate.year == currentYear)
            .toList()
          ..sort((a, b) => a.month.compareTo(b.month));

        for (var rate in monthlyData) {
          spots.add(FlSpot((rate.month - 1).toDouble(), rate.amount / 20));
        }
        break;

      case 'Quarterly':
        final currentYear = DateTime.now().year;
        final yearData =
            apiData.where((rate) => rate.year == currentYear).toList();

        for (int q = 1; q <= 4; q++) {
          final quarterMonths = _getQuarterMonths(q);
          final qData =
              yearData.where((r) => quarterMonths.contains(r.month)).toList();

          if (qData.isNotEmpty) {
            final avg = qData.map((r) => r.amount).reduce((a, b) => a + b) /
                qData.length;
            spots.add(FlSpot((q - 1).toDouble(), avg / 20));
          }
        }
        break;

      case 'Yearly':
        final currentYear = DateTime.now().year;
        for (int i = 0; i < 4; i++) {
          final year = currentYear - 3 + i;
          final yData = apiData.where((r) => r.year == year).toList();
          if (yData.isNotEmpty) {
            final avg = yData.map((r) => r.amount).reduce((a, b) => a + b) /
                yData.length;
            spots.add(FlSpot(i.toDouble(), avg / 20));
          } else {
            spots.add(FlSpot(i.toDouble(), 0));
          }
        }
        break;
    }
    return spots;
  }

  List<int> _getQuarterMonths(int quarter) {
    switch (quarter) {
      case 1:
        return [1, 2, 3];
      case 2:
        return [4, 5, 6];
      case 3:
        return [7, 8, 9];
      case 4:
        return [10, 11, 12];
      default:
        return [];
    }
  }

  // === Axis Titles ===
  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: bottomTitles),
        leftTitles: AxisTitles(sideTitles: leftTitles),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontFamily: 'outfit',
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    // Only render labels on whole-number ticks to avoid duplicates near the end padding
    final isWholeNumber = (value % 1).abs() < 1e-6;
    if (!isWholeNumber) {
      return const SizedBox.shrink();
    }

    switch (period) {
      case 'Quarterly':
        const labels = ['Q1', 'Q2', 'Q3', 'Q4'];
        final i = value.toInt();
        if (i >= 0 && i < labels.length) {
          return SideTitleWidget(
              axisSide: meta.axisSide, child: Text(labels[i], style: style));
        }
        break;

      case 'Yearly':
        final currentYear = DateTime.now().year;
        final displayYear = currentYear - 3 + value.toInt();
        return SideTitleWidget(
            axisSide: meta.axisSide, child: Text('$displayYear', style: style));

      case 'Monthly':
      default:
        const months = [
          'JAN',
          'FEB',
          'MAR',
          'APR',
          'MAY',
          'JUN',
          'JUL',
          'AUG',
          'SEP',
          'OCT',
          'NOV',
          'DEC'
        ];
        final i = value.toInt();
        if (i >= 0 && i < months.length) {
          return SideTitleWidget(
              axisSide: meta.axisSide, child: Text(months[i], style: style));
        }
    }

    return const SizedBox.shrink();
  }

  SideTitles get leftTitles => SideTitles(
        showTitles: true,
        interval: 1,
        reservedSize: 40,
        getTitlesWidget: (value, meta) {
          const style = TextStyle(
            fontFamily: 'outfit',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );
          switch (value.toInt()) {
            case 0:
              return Text('0', style: style);
            case 1:
              return Text('20', style: style);
            case 2:
              return Text('40', style: style);
            case 3:
              return Text('60', style: style);
            case 4:
              return Text('80', style: style);
            case 5:
              return Text('100', style: style);
          }
          return const SizedBox.shrink();
        },
      );

  // === Touch Tooltip ===
  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => Colors.blueGrey.withOpacity(0.8),
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (spots) {
            return spots.map((barSpot) {
              final percentage = barSpot.y * 20;
              final label = _labelForX(barSpot.x);
              return LineTooltipItem(
                '$label  ${percentage.toStringAsFixed(1)}%',
                const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              );
            }).toList();
          },
        ),
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.5), width: 2),
          left: const BorderSide(color: Colors.black12, width: 1),
          right: BorderSide.none,
          top: BorderSide.none,
        ),
      );
}

String _labelForX(double x) {
  switch (_currentPeriod) {
    case 'Quarterly':
      const labels = ['Q1', 'Q2', 'Q3', 'Q4'];
      final i = x.round();
      if (i >= 0 && i < labels.length) return labels[i];
      return '';
    case 'Yearly':
      final currentYear = DateTime.now().year;
      final year = currentYear - 3 + x.round();
      return '$year';
    case 'Monthly':
    default:
      const months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC'
      ];
      final i = x.round();
      if (i >= 0 && i < months.length) return months[i];
      return '';
  }
}

// Since _labelForX is outside the widget, expose the current period via a
// top-level getter/setter linked to the chart instance lifecycle.
// Simpler approach: store last-used period before building chart.
String _currentPeriod = 'Monthly';
