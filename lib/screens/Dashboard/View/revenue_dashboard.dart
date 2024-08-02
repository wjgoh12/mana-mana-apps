import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class BuildRevenueContainers extends StatelessWidget {
  const BuildRevenueContainers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _RevenueContainer(
            title: 'Overall Revenue',
            icon: Icons.account_balance_wallet_outlined),
        Spacer(),
        _RevenueContainer(
            title: 'Overall Rental Income', icon: Icons.home_outlined),
      ],
    );
  }
}

class _RevenueContainer extends StatelessWidget {
  final String title;
  final IconData icon;

  const _RevenueContainer({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.width,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(1.height),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
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
                _buildTitleRow(),
                SizedBox(height: 1.height),
                _buildContentRow(),
              ],
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
        SizedBox(width: 1.width),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
            fontSize: 12.fSize,
            color: const Color(0XFF3E51FF),
          ),
        ),
        const Spacer(),
        Container(
          width: 3.width,
          height: 3.width,
          alignment: Alignment.center,
          child: Icon(
            Icons.arrow_outward_rounded,
            color: const Color(0xff3E51FF),
            size: 3.width,
          ),
        ),
      ],
    );
  }

  Widget _buildContentRow() {
    return Row(
      children: [
        SizedBox(width: 1.width),
        Container(
          width: 8.width,
          height: 8.width,
          decoration: const BoxDecoration(
            color: Color(0XFFF9F8FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0XFF2900B7),
            size: 4.width,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAmountText(),
            _buildPercentageText(),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountText() {
    return Text.rich(
      TextSpan(
        text: 'RM',
        style: TextStyle(
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w700,
          fontSize: 12.fSize,
          color: const Color(0XFF2900B7),
        ),
        children: <InlineSpan>[
          WidgetSpan(child: SizedBox(width: 1.width)),
          TextSpan(
            text: '9,999.99',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
              fontSize: 20.fSize,
              color: const Color(0XFF2900B7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageText() {
    return Text.rich(
      TextSpan(
        text: '100%',
        style: TextStyle(
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w400,
          fontSize: 10.fSize,
          color: const Color(0XFF2900B7),
        ),
        children: <InlineSpan>[
          WidgetSpan(
            child: Icon(
              Icons.arrow_drop_up,
              color: const Color(0XFF42C18B),
              size: 2.height,
            ),
          ),
        ],
      ),
    );
  }
}
