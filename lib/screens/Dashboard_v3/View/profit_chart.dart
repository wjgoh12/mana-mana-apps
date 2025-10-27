import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:math' show max;

class ProfitChart extends StatelessWidget {
  const ProfitChart({
    super.key,
    required this.period,
    this.model,
  });

  final String period;
  final dynamic model;

  @override
  Widget build(BuildContext context) {
    final series = _getSeries();
    final spots = _toSpots(series.values.toList());

    // Check if there's any data
    final hasData = series.values.any((value) => value > 0);
    if (!hasData) {
      return Center(
        child: Text(
          'No profit data available for ${period.toLowerCase()} view',
          style: const TextStyle(
            fontFamily: 'outfit',
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final maxX = _getMaxX();
    final maxY = _computeAutoMaxY(series.values);
    final leftInterval = _computeAutoInterval(maxY);

    // Check if we have only one data point
    final isSingleDataPoint = spots.length == 1;

    final titles = FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: bottomTitles),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: leftInterval,
          reservedSize: 50, // Reduced from 64
          getTitlesWidget: (value, meta) {
            final label = _formatCompact(value);
            return Text(
              label,
              style: const TextStyle(
                fontFamily: 'outfit',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 12,
          getTitlesWidget: (value, meta) => const SizedBox.shrink(),
        ),
      ),
    );

    final chart = LineChart(
      LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titles,
        borderData: borderData,
        clipData: const FlClipData(
          top: false,
          bottom: false,
          left: false,
          right: false,
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: !isSingleDataPoint,
            color: const Color(0XFFFFCF00),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (isSingleDataPoint) {
                  return FlDotCirclePainter(
                    radius: 8,
                    color: const Color(0XFFFFCF00),
                    strokeWidth: 3,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0XFFFFCF60),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: isSingleDataPoint,
              gradient: LinearGradient(
                colors: [
                  const Color(0XFFFFCF00).withOpacity(0.3),
                  const Color(0XFFFFCF00).withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            spots: spots,
            preventCurveOverShooting: true,
            curveSmoothness: 0.35,
          ),
        ],
        // Fit all data in view with padding
        minX: spots.isEmpty ? 0 : spots.first.x - 0.5,
        maxX: spots.isEmpty ? 0 : spots.last.x + 0.5,
        maxY: maxY,
        minY: 0,
        extraLinesData: isSingleDataPoint
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: spots.first.y,
                    color: const Color(0XFFFFCF60).withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ],
              )
            : null,
      ),
      duration: const Duration(milliseconds: 250),
    );

    // Add annotation for single data point
    final chartWithAnnotation = isSingleDataPoint
        ? Stack(
            children: [
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0XFFFFCF00),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0XFFFFCF00).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'RM ${NumberFormat('#,##0.00').format(spots.first.y)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'outfit',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              chart,
            ],
          )
        : chart;

    return chartWithAnnotation;
  }

  double _getMaxX() {
    final series = _getSeries();
    if (series.isEmpty) {
      return 0;
    }
    int lastNonZeroIndex = series.keys.reduce((a, b) => series[b]! > 0 ? b : a);
    return lastNonZeroIndex.toDouble();
  }

  Map<int, double> _getSeries() {
    final now = DateTime.now();
    final currentYear = now.year;
    final Map<int, double> values = {};

    if (model == null) return values;

    switch (period) {
      case 'Monthly':
        for (int m = 1; m <= 12; m++) {
          final total = model!.totalByMonth
              .where((e) =>
                  e['transcode'] == 'NOPROF' &&
                  e['year'] == currentYear &&
                  e['month'] == m)
              .fold<double>(
                  0.0,
                  (double sum, dynamic e) =>
                      sum + (e['total'] as num).toDouble());
          if (total > 0) {
            values[m - 1] = total;
          }
        }
        break;

      case 'Quarterly':
        for (int q = 1; q <= 4; q++) {
          final months = _getQuarterMonths(q);
          final total = model!.totalByMonth
              .where((e) =>
                  e['transcode'] == 'NOPROF' &&
                  e['year'] == currentYear &&
                  months.contains(e['month']))
              .fold<double>(
                  0.0,
                  (double sum, dynamic e) =>
                      sum + (e['total'] as num).toDouble());
          if (total > 0) {
            values[q - 1] = total;
          }
        }
        break;

      case 'Yearly':
        int index = 0;
        for (int i = 0; i < 4; i++) {
          final y = currentYear - 3 + i;
          final total = model!.revenueDashboard
              .where((e) => e['transcode'] == 'NOPROF' && e['year'] == y)
              .fold<double>(
                  0.0,
                  (double sum, dynamic e) =>
                      sum + (e['total'] as num).toDouble());
          if (total > 0) {
            values[index++] = total;
          }
        }
        break;
    }

    return _zeroFill(values);
  }

  Map<int, double> _zeroFill(Map<int, double> m) {
    switch (period) {
      case 'Monthly':
        for (int i = 0; i < 12; i++) {
          m[i] = (m[i] ?? 0.0).toDouble();
        }
        break;
      case 'Quarterly':
      case 'Yearly':
        for (int i = 0; i < 4; i++) {
          m[i] = (m[i] ?? 0.0).toDouble();
        }
        break;
    }
    return m;
  }

  double _computeAutoMaxY(Iterable<double> values) {
    final maxValue =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final target = maxValue <= 0 ? 1000.0 : maxValue * 1.5;
    return _niceCeil(target);
  }

  double _computeAutoInterval(double maxY) {
    final raw = maxY / 5.0;
    return _niceCeil(raw);
  }

  List<FlSpot> _toSpots(List<double> values) {
    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      if (values[i] > 0) {
        spots.add(FlSpot(i.toDouble(), values[i]));
      }
    }
    return spots;
  }

  double _niceCeil(double value) {
    if (value <= 0) return 1;
    final power =
        math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
    final n = value / power;
    double nice;
    if (n <= 1) {
      nice = 1;
    } else if (n <= 2) {
      nice = 2;
    } else if (n <= 5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * power;
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

    final nearest = value.round();
    if ((value - nearest).abs() > 0.01) {
      return const SizedBox.shrink();
    }

    final series = _getSeries();
    final dataPoints = series.entries.where((e) => e.value > 0).toList();

    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final firstIndex = dataPoints.first.key;
    final lastIndex = dataPoints.last.key;

    switch (period) {
      case 'Quarterly':
        const labels = ['Q1', 'Q2', 'Q3', 'Q4'];
        final i = nearest;
        // Show only first and last
        if (i == firstIndex || i == lastIndex) {
          if (i >= 0 && i < labels.length) {
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(labels[i], style: style),
            );
          }
        }
        break;

      case 'Yearly':
        final currentYear = DateTime.now().year;
        final i = nearest;

        // Count how many years have data
        final yearsWithData = dataPoints.length;

        if (yearsWithData <= 4) {
          // Show all years if 4 or fewer
          if (series.containsKey(i) && series[i]! > 0) {
            final displayYear =
                currentYear - 3 + series.keys.toList().indexOf(i);
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text('$displayYear', style: style),
            );
          }
        } else {
          // Show only first and last if more than 4
          if (i == firstIndex || i == lastIndex) {
            final displayYear =
                currentYear - 3 + series.keys.toList().indexOf(i);
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text('$displayYear', style: style),
            );
          }
        }
        break;

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
        final i = nearest;
        // Show only first and last month with data
        if (i == firstIndex || i == lastIndex) {
          if (i >= 0 && i < months.length) {
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(months[i], style: style),
            );
          }
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

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => Color(0xFF606060).withOpacity(0.8),
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (spots) {
            return spots.map((barSpot) {
              final label = _labelForXInstance(barSpot.x, period);
              final rm = NumberFormat('#,##0.00').format(barSpot.y);
              return LineTooltipItem(
                '$label  RM$rm',
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

String _labelForXInstance(double x, String period) {
  final currentYear = DateTime.now().year;
  switch (period) {
    case 'Quarterly':
      const labels = ['Q1', 'Q2', 'Q3', 'Q4'];
      final i = x.round();
      if (i >= 0 && i < labels.length) return labels[i];
      return '';
    case 'Yearly':
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

String _formatCompact(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }
  return value.toStringAsFixed(0);
}
