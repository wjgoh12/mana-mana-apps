import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:mana_mana_app/screens/All_Property/resources/app_colors.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class ProfitChart extends StatelessWidget {
  const ProfitChart({
    super.key,
    required this.period,
    this.model,
  });

  final String period;
  final NewDashboardVM_v3? model;

  @override
  Widget build(BuildContext context) {
    final series = _getSeries();
    final spots = _toSpots(series.values.toList());

    final maxX = _getMaxX();
    // Auto scale Y: pick a nice max above data and a nice tick interval
    final maxY = _computeAutoMaxY(series.values);
    final leftInterval = _computeAutoInterval(maxY);

    final titles = FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: bottomTitles),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: leftInterval,
          reservedSize: 64,
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
            isCurved: true,
            color: const Color(0XFF2900B7),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
            spots: spots,
          ),
        ],
        // Nudge domain to keep last labels visible inside chart area
        minX: -0.2,
        maxX: maxX + 0.4,
        maxY: maxY,
        minY: 0,
      ),
      duration: const Duration(milliseconds: 250),
    );

    if (period == 'Monthly') {
      // Build a fixed left-axis chart (no data, only Y titles) and a scrollable plot-only chart
      final leftAxisOnly = LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: const BorderSide(color: Colors.black12, width: 1),
              bottom:
                  BorderSide(color: Colors.black.withOpacity(0.5), width: 2),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          clipData:
              const FlClipData(top: false, bottom: false, left: false, right: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: leftInterval,
                reservedSize: 64,
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
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 12,
                getTitlesWidget: (v, m) => const SizedBox.shrink(),
              ),
            ),
          ),
          minX: 0,
          maxX: 0,
          minY: 0,
          maxY: maxY,
          lineBarsData: const [],
        ),
      );

      final scrollableChart = LineChart(
        LineChartData(
          lineTouchData: lineTouchData,
          gridData: gridData,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: bottomTitles),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 12,
                getTitlesWidget: (v, m) => const SizedBox.shrink(),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom:
                  BorderSide(color: Colors.black.withOpacity(0.5), width: 2),
              left: BorderSide.none,
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          clipData:
              const FlClipData(top: false, bottom: false, left: false, right: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: const Color(0XFF2900B7),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
              spots: spots,
            ),
          ],
          minX: -0.2,
          maxX: maxX + 0.4,
          maxY: maxY,
          minY: 0,
        ),
        duration: const Duration(milliseconds: 250),
      );

      return Row(
        children: [
          SizedBox(width: 64, child: leftAxisOnly),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: SizedBox(width: 900, child: scrollableChart),
              ),
            ),
          ),
        ],
      );
    }

    return chart;
  }

  double _getMaxX() {
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

  // Build series values indexed by x (0..11 for months, 0..3 for quarters/years)
  Map<int, double> _getSeries() {
    final now = DateTime.now();
    final currentYear = now.year;
    final Map<int, double> values = {};

    if (model == null) return _zeroFill(values);

    switch (period) {
      case 'Monthly':
        // Sum NOPROF by month for current year, zero-fill 1..12
        for (int m = 1; m <= 12; m++) {
          final total = model!.totalByMonth
              .where((e) =>
                  e['transcode'] == 'NOPROF' &&
                  e['year'] == currentYear &&
                  e['month'] == m)
              .fold<double>(
                  0.0, (sum, e) => sum + (e['total'] as num).toDouble());
          values[m - 1] = total;
        }
        break;

      case 'Quarterly':
        // Sum NOPROF by quarter for current year, zero-fill Q1..Q4
        for (int q = 1; q <= 4; q++) {
          final months = _getQuarterMonths(q);
          final total = model!.totalByMonth
              .where((e) =>
                  e['transcode'] == 'NOPROF' &&
                  e['year'] == currentYear &&
                  months.contains(e['month']))
              .fold<double>(
                  0.0, (sum, e) => sum + (e['total'] as num).toDouble());
          values[q - 1] = total;
        }
        break;

      case 'Yearly':
        // Sum NOPROF by year for last 4 years, zero-fill
        for (int i = 0; i < 4; i++) {
          final y = currentYear - 3 + i;
          final total = model!.revenueDashboard
              .where((e) => e['transcode'] == 'NOPROF' && e['year'] == y)
              .fold<double>(
                  0.0, (sum, e) => sum + (e['total'] as num).toDouble());
          values[i] = total;
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
    final maxValue = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    // Headroom factor 1.5x; if no data, default to 1k
    final target = maxValue <= 0 ? 1000.0 : maxValue * 1.5;
    return _niceCeil(target);
  }

  double _computeAutoInterval(double maxY) {
    // Aim for ~5 ticks
    final raw = maxY / 5.0;
    return _niceCeil(raw);
  }

  List<FlSpot> _toSpots(List<double> values) {
    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }
    return spots;
  }

  // Round up to a "nice" number (1, 2, 5 multiples of powers of 10)
  double _niceCeil(double value) {
    if (value <= 0) return 1;
    final power = math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
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

    // Only show labels at (near) integer positions to avoid duplicates
    final nearest = value.round();
    if ((value - nearest).abs() > 0.01) {
      return const SizedBox.shrink();
    }

    switch (period) {
      case 'Quarterly':
        const labels = ['Q1', 'Q2', 'Q3', 'Q4'];
        final i = nearest;
        if (i >= 0 && i < labels.length) {
          final child = Text(labels[i], style: style);
          final isLast = i == labels.length - 1;
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: isLast
                ? Transform.translate(
                    offset: const Offset(-10, 0),
                    child: child,
                  )
                : child,
          );
        }
        break;

      case 'Yearly':
        final currentYear = DateTime.now().year;
        final i = nearest;
        if (i < 0 || i > 3) return const SizedBox.shrink();
        final displayYear = currentYear - 3 + i;
        {
          final isLast = i == 3; // last of 4 slots
          final child = Text('$displayYear', style: style);
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: isLast
                ? Transform.translate(
                    offset: const Offset(-12, 0),
                    child: child,
                  )
                : child,
          );
        }

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
        if (i >= 0 && i < months.length) {
          final child = Text(months[i], style: style);
          final isLast = i == months.length - 1; // DEC
          return SideTitleWidget(
            axisSide: meta.axisSide,
            child: isLast
                ? Transform.translate(
                    offset: const Offset(-10, 0),
                    child: child,
                  )
                : child,
          );
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

// Small helpers since dart:math's log only supports natural log
// (Removed unused helpers)
