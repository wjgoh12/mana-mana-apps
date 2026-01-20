import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/core/utils/responsive.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

class RevenueDashboard extends StatelessWidget {
  final NewDashboardVM model;
  const RevenueDashboard({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RevenueContainer(
              title: '${model.revenueLastestYear} Accumulated Profit​',
              icon: Icons.home_outlined,
              overallRevenue: false,
              model: model),
        ),
      ],
    );
  }
}

class RevenueContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool overallRevenue;
  final NewDashboardVM model;
  const RevenueContainer({
    Key? key,
    required this.title,
    required this.icon,
    required this.overallRevenue,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.width,
      height: 11.height,
      child: Stack(
        children: [
          GestureDetector(
            child: Container(
              padding: !Responsive.isMobile(context)
                  ? EdgeInsets.only(
                      left: 1.height, top: 1.height, right: 1.height)
                  : EdgeInsets.all(1.height),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffC3B9FF).withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: (0.5).height,
                  ),
                  _buildTitleRow(),
                  SizedBox(height: (1.5).height),
                  _buildContentRow(),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/patterns_unit_revenue.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        SizedBox(width: 3.width),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
            fontSize: AppDimens.fontSizeBig,
            color: const Color(0xFF4313E9),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildContentRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: 3.width),
        Container(
          width: 8.width,
          height: 8.width,
          decoration: const BoxDecoration(
            color: Color(0XFFF9F8FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.blue,
            size: 4.width,
          ),
        ),
        SizedBox(width: 3.width),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAmountText(),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'RM',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
            fontSize: AppDimens.fontSizeBig,
            color: AppColors.blue,
          ),
        ),
        SizedBox(width: 1.width),
        FutureBuilder<dynamic>(
          future: overallRevenue ? model.overallBalance : model.overallProfit,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final value = snapshot.data ?? 0.00;
              return Text(
                NumberFormat('#,##0.00').format(value),
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimens.fontSizeBig,
                  color: AppColors.blue,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
