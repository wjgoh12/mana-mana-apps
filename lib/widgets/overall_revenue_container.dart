import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

class OverallRevenueContainer extends StatelessWidget{
  const OverallRevenueContainer({super.key,required this.color,required this.backgroundColor,required this.text1,required this.text2,required this.text3,required this.text4,required this.text5,required this.text6});
final String text1;
final String text2;
final String text3;
final String text4;
final String text5;
final String text6;
final Color color;
final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SizedBox(
              width: 86.width,
              height: 10.height,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(width: 86.width,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: const Color(0XFFBBBCBE)),
                          color: backgroundColor),
                      child: Image.asset(
                        'assets/images/revenue_pattern.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(width: 86.width,
                      height: 6.height,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 4.height,
                            Icons.account_balance_wallet_outlined,
                            color: color,
                          ),
                          SizedBox(
                            width: 4.width,
                          ),
                          SizedBox(width: 25.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text1,
                                  style: TextStyle(
                                      color: color,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.w400,
                                      fontSize: AppDimens.fontSizeSmall,
                                ),
                                Text(
                                  text2,
                                  style: TextStyle(
                                      color: color,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppDimens.fontSizeBig,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      text3,
                                      style: TextStyle(
                                          color: color,
                                          fontFamily: 'Open Sans',
                                          fontWeight: FontWeight.w400,
                                          fontSize: AppDimens.fontSizeSmall,
                                    ),
                                    Icon(
                                      Icons.arrow_drop_up,
                                      color: const Color(0XFF42C18B),
                                      size: 1.height,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            color: Color(0XFFBBBCBE),
                          ),        
                          Icon(
                            size: 4.height,
                            Icons.home_outlined,
                            color: color,
                          ),
                          SizedBox(
                            width: 4.width,
                          ),
                          SizedBox(width: 25.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text4,
                                  style: TextStyle(
                                      color: color,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.w400,
                                      fontSize: AppDimens.fontSizeSmall,
                                ),
                                Text(
                                  text5,
                                  style: TextStyle(
                                      color: color,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppDimens.fontSizeBig,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      text6,
                                      style: TextStyle(
                                          color: color,
                                          fontFamily: 'Open Sans',
                                          fontWeight: FontWeight.w400,
                                          fontSize: AppDimens.fontSizeSmall,
                                    ),
                                    Icon(
                                      Icons.arrow_drop_up,
                                      color: const Color(0XFF42C18B),
                                      size: 1.height,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
    
  }
}