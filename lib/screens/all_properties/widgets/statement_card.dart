import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class StatementCard extends StatelessWidget {
  final String month;
  final String statementDate;
  final String statementAmount;
  final VoidCallback onTap;

  const StatementCard({
    Key? key,
    required this.month,
    required this.statementDate,
    required this.statementAmount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isWeb = false;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveSize.scaleWidth(16),
        vertical: ResponsiveSize.scaleHeight(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveSize.scaleWidth(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$month Statement',
                      style: TextStyle(
                        fontFamily: AppFonts.outfit,
                        fontSize: AppDimens.fontSizeBig,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGrey,
                      ),
                    ),
                    SizedBox(height: ResponsiveSize.scaleHeight(2)),
                    Text(
                      statementAmount,
                      style: TextStyle(
                        fontFamily: AppFonts.outfit,
                        fontSize: AppDimens.fontSizeSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: ResponsiveSize.scaleHeight(32),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGrey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: onTap,
                    child: Row(
                      children: [
                        Text(
                          'Statement',
                          style: TextStyle(
                            fontFamily: AppFonts.outfit,
                            fontSize: AppDimens.fontSizeSmall,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: ResponsiveSize.scaleWidth(4)),
                        Image.asset(
                          'assets/images/statement_download.png',
                          width: ResponsiveSize.scaleWidth(16),
                          height: ResponsiveSize.scaleHeight(16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
