import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class OverallRevenueContainer extends StatelessWidget{
  const OverallRevenueContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  SizedBox(
              width: 86.width,
              height: 12.height,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: const Color(0XFFBBBCBE)),
                          color: const Color(0XFF4313E9)),
                      child: Image.asset(
                        'assets/images/revenue_pattern.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 6.height,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 4.height,
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 4.width,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Revenue',
                                style: TextStyle(
                                    color: const Color(0XFFFFFFFF),
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10.fSize),
                              ),
                              Text(
                                'RM 9,999.99',
                                style: TextStyle(
                                    color: const Color(0XFFFFFFFF),
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.fSize),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '100%',
                                    style: TextStyle(
                                        color: const Color(0XFFFFFFFF),
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.fSize),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_up,
                                    color: Color(0XFF42C18B),
                                    size: 2.width,
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            width: 5.width,
                          ),
                          const VerticalDivider(
                            color: Color(0XFFBBBCBE),
                          ),
                          SizedBox(
                            width: 3.width,
                          ),
                          Icon(
                            size: 4.height,
                            Icons.home_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 4.width,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Rental Income',
                                style: TextStyle(
                                    color: const Color(0XFFFFFFFF),
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10.fSize),
                              ),
                              Text(
                                'RM 8,888.88',
                                style: TextStyle(
                                    color: const Color(0XFFFFFFFF),
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.fSize),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '88%',
                                    style: TextStyle(
                                        color: const Color(0XFFFFFFFF),
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.fSize),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_up,
                                    color: const Color(0XFF42C18B),
                                    size: 2.width,
                                  )
                                ],
                              )
                            ],
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