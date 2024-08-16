import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Dashboard/ViewModel/dashboardVM.dart';
import 'package:mana_mana_app/widgets/bar_chart.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class StatisticTable extends StatelessWidget {
  const StatisticTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DashboardVM model = DashboardVM();
    model.monthlyBlcOwner = [];
    model.monthlyProfitOwner = [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0XFF120051).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
            spreadRadius: -1.0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 6.width, right: 3.width, top: 2.height, bottom: 2.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Overall Earnings',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 12.fSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0XFF2900B7),
                  ),
                ),
                Text(
                  '(Ringgit in thousands)',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 6.fSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0XFF4313E9),
                  ),
                ),
                _buildLegend(),
                BarChartSample7(),
                _buildRevenueTable(),
              ],
            ),
          ),
          ..._buildBackgroundImages(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildLegendItem(gradientColor1, 'Overall Monthly Profit'),
        SizedBox(width: 2.width),
        _buildLegendItem(gradientColor2, 'Overall Net After POB'),
      ],
    );
  }

  Widget _buildLegendItem(Gradient gradient, String text) {
    return Row(
      children: [
        Container(
          width: 2.width,
          height: 2.width,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
          ),
        ),
        SizedBox(width: 1.width),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 8.fSize,
            fontWeight: FontWeight.w600,
            color: const Color(0XFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueTable() {
    DashboardVM model = DashboardVM();
    String getMonthName(int month) {
  const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return monthNames[month - 1];
}
    return ListenableBuilder(
      listenable: DashboardVM(),
      builder: (context, _) {
        
        return Column(
          children: model.monthlyBlcOwner.map((entry) {
            final year = entry['year'];  // Extract year
            final month = entry['month'];  // Extract month
            final totalBlc = entry['total'];  // Extract total balance for the month

            // Find the corresponding profit for the same year and month
            final profitEntry = model.monthlyProfitOwner.firstWhere(
              (profit) => profit['year'] == year && profit['month'] == month,
              orElse: () => {'total': 0.00},
            );
            final totalProfit = profitEntry['total'];  // Extract total profit for the month

            // Convert month number to a name (e.g., 5 -> May)
            final monthName = getMonthName(month);

            return Column(
              children: [
                _buildTableHeader(),
                _buildTableRow(
                  '$monthName $year',
                  'RM ${totalBlc.toStringAsFixed(2)}',
                  'RM ${totalProfit.toStringAsFixed(2)}',
                ),
                _buildDivider(),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        const Spacer(flex: 4),
        Expanded(
          flex: 4,
          child: _buildHeaderText('Monthly Balance To Owner'),
        ),
        Expanded(
          flex: 3,
          child: _buildHeaderText('Monthly Profit'),
        ),
      ],
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0XFF888888),
        fontSize: 8.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'Open Sans',
      ),
    );
  }

  Widget _buildTableRow(String month, String revenue, String rentalIncome) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            month,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              fontSize: 12.fSize,
              color: const Color(0XFF888888),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: _buildRevenueText(revenue),
        ),
        Expanded(
          flex: 3,
          child: _buildRevenueText(rentalIncome),
        ),
      ],
    );
  }

  Widget _buildRevenueText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0XFF4313E9),
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Open Sans',
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0XFF888888),
      thickness: 0.5.fSize,
    );
  }

  List<Widget> _buildBackgroundImages() {
    return [
      _buildBackgroundImage(left: 0, top: -5.height),
      _buildBackgroundImage(right: 0, top: 1.height),
      _buildBackgroundImage(bottom: 1.height, left: 1.width),
      _buildBackgroundImage(right: 0, bottom: -5.height),
    ];
  }

  Widget _buildBackgroundImage({double? left, double? right, double? top, double? bottom}) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: SizedBox(
        width: 27.width,
        height: 16.height,
        child: Opacity(
          opacity: 0.2,
          child: Image.asset(
            'assets/images/patterns_faded.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}