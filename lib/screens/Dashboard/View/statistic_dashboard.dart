import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/bar_chart.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class StatisticTable extends StatelessWidget {
  const StatisticTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        _buildLegendItem(gradientColor1, 'Overall Revenue'),
        SizedBox(width: 2.width),
        _buildLegendItem(gradientColor2, 'Overall Rental Revenue'),
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
    return Column(
      children: [
        _buildTableHeader(),
        _buildTableRow('April 2024', 'RM 0', 'RM 0'),
        _buildDivider(),
        _buildTableRow('Mar 2024', 'RM 4,562.40', 'RM 4,562.40'),
        _buildDivider(),
        _buildTableRow('Feb 2024', 'RM 100,562.40', 'RM 100,562.40'),
        _buildDivider(),
        _buildTableRow('Jan 2024', 'RM 60,562.40', 'RM 60,562.40'),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        const Spacer(flex: 4),
        Expanded(
          flex: 4,
          child: _buildHeaderText('Monthly Revenue'),
        ),
        Expanded(
          flex: 3,
          child: _buildHeaderText('Monthly Rental Income'),
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