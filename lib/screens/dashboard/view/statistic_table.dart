import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/ViewModel/new_dashboardVM.dart';
// import 'package:mana_mana_app/widgets/new_type_barchart.dart';
import 'package:mana_mana_app/widgets/new_bar_chart.dart';

import 'package:mana_mana_app/core/utils/size_utils.dart';

class StatisticTable extends StatelessWidget {
  final NewDashboardVM model;
  const StatisticTable({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
                    fontSize: AppDimens.fontSizeBig,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(height: 1.height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildLegendItem(gradientColor1, 'Overall Monthly Profit'),
                    SizedBox(width: 2.width),
                    _buildLegendItem(gradientColor2, 'Overall Net After POB'),
                  ],
                ),
                BarChartSample(model: model),
                if (model.monthlyBlcOwner.length > 4)
                  SizedBox(
                    height: 22.height,
                    child: _buildRevenueTable(model),
                  ),
                if (model.monthlyBlcOwner.length > 4)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: Text(
                        "Scroll to view more data",
                        style: TextStyle(
                          color: Color(0XFF888888),
                          fontSize: AppDimens.fontSizeSmall,
                        ),
                      ),
                    ),
                  ),
                if (model.monthlyBlcOwner.length <= 4)
                  _buildRevenueTable(model),
              ],
            ),
          ),
          ..._buildBackgroundImages(),
        ],
      ),
    );
  }
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
          fontSize: AppDimens.fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: const Color(0XFF888888),
        ),
      ),
    ],
  );
}

Widget _buildRevenueTable(NewDashboardVM model) {
  String getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  return SingleChildScrollView(
    child: Column(
      children: [
        _buildTableHeader(),
        ...model.monthlyBlcOwner.map((entry) {
          final year = entry['year']; // Extract year
          final month = entry['month']; // Extract month
          final totalBlc =
              entry['total']; // Extract total balance for the month

          // Find the corresponding profit for the same year and month
          final profitEntry = model.monthlyProfitOwner.firstWhere(
            (profit) => profit['year'] == year && profit['month'] == month,
            orElse: () => {'total': 0.00},
          );

          final totalProfit =
              profitEntry['total']; // Extract total profit for the month

          // Convert month number to a name (e.g., 5 -> May)
          final monthName = getMonthName(month);

          return Column(
            children: [
              _buildTableRow(
                '$monthName $year',
                'RM ${totalProfit.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                'RM ${totalBlc.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              ),
              _buildDivider(),
            ],
          );
        }).toList(),
      ],
    ),
  );
}

Widget _buildTableHeader() {
  return Row(
    children: [
      const Spacer(flex: 4),
      Expanded(
        flex: 5,
        child: _buildHeaderText('Overall Monthly Profit'),
      ),
      Expanded(
        flex: 4,
        child: _buildHeaderText('Overall Net After POB'),
      ),
    ],
  );
}

Widget _buildHeaderText(String text) {
  return Text(
    text,
    style: TextStyle(
      color: const Color(0XFF888888),
      fontSize: AppDimens.fontSizeSmall,
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
            fontSize: AppDimens.fontSizeBig,
            color: const Color(0XFF888888),
          ),
        ),
      ),
      Expanded(
        flex: 5,
        child: _buildRevenueText(revenue),
      ),
      Expanded(
        flex: 4,
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
      fontSize: AppDimens.fontSizeBig,
      fontWeight: FontWeight.w600,
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

Widget _buildBackgroundImage(
    {double? left, double? right, double? top, double? bottom}) {
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
