import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/personal_millerz_square.dart';
import 'package:mana_mana_app/widgets/bar_chart.dart';
import 'package:mana_mana_app/widgets/overall_revenue_container.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class NewDashboardPage extends StatelessWidget {
  var height, width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            alignment: Alignment.topCenter,
            width: 100.width,
            height: 100.height,
            color: Color(0XFF4313E9),
            padding: EdgeInsets.only(
              top: 2.height,
            ),
            child: SizedBox(
              height: 6.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset('assets/images/mana2logo.png'),
                  Text(
                    'DASHBOARD',
                    style: TextStyle(
                        fontSize: 20.fSize,
                        color: Colors.white,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w800,
                        shadows: const [
                          Shadow(
                              color: Color(0XFF120051),
                              blurRadius: 0.5,
                              offset: Offset(0.25, 0.5))
                        ]),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                      width: 6.width,
                      height: 6.width,
                      child: Image.asset(
                        'assets/images/notifications.png',
                        fit: BoxFit.cover,
                      ))
                ],
              ),
            ),
          ),
          Positioned(
              top: -5.height,
              child: SizedBox(
                  width: 110.width,
                  height: 18.height,
                  child: Image.asset(
                    'assets/images/mana2_patterns.png',
                    fit: BoxFit.cover,
                  ))),
          Positioned(
            top: 10.height,
            child: Container(
              width: 100.width,
              height: 90.height,
              padding: EdgeInsets.all(7.width),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                          width: 8.width,
                          height: 8.width,
                          child: Image.asset(
                            'assets/images/dashboard_gem.png',
                            fit: BoxFit.cover,
                          )),
                      SizedBox(
                        width: 5.width,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Azeem Mohd Fahmi',
                            style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 16.fSize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0XFF4313E9)),
                          ),
                          Text(
                            'Property Owner',
                            style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 12.fSize,
                                fontWeight: FontWeight.w300,
                                color: const Color(0XFF555555),
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 8.width,
                        height: 8.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: const LinearGradient(
                                colors: [
                                  Color(0XFF2900B7),
                                  Color.fromARGB(255, 114, 96, 180)
                                ],
                                begin: AlignmentDirectional.topCenter,
                                end: Alignment.bottomCenter)),
                        child: const Icon(
                          Icons.keyboard_arrow_right_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1.height,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(children: [
                        Divider(
                          color: const Color(0XFF888888).withOpacity(0.55),
                        ),
                        SizedBox(
                          height: 1.height,
                        ),
                        const OverallRevenueContainer(
                          text1: 'Overall Revenue',
                          text2: 'RM 9,999.99',
                          text3: '100%',
                          text4: 'Overall Rental Income',
                          text5: 'RM 8,888.88',
                          text6: '88%',
                          color: Color(0XFFFFFFFF),
                          backgroundColor: Color(0XFF4313E9),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Statistics',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 20.fSize,
                                fontWeight: FontWeight.w800,
                                color: Color(0XFF4313E9),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 12.width,
                              height: 14.width,
                              child: Image.asset(
                                'assets/images/patterns.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              width: 5.width,
                            )
                          ],
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 6.width, right: 3.width),
                          child: Row(
                            children: [
                              Text(
                                'Monthly Overall Earnings',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 8.fSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0XFF4313E9),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 2.width,
                                height: 2.width,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: gradientColor1,
                                ),
                              ),
                              SizedBox(width: 1.width),
                              Text(
                                'Overall Revenue',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 8.fSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0XFF888888),
                                ),
                              ),
                              SizedBox(width: 2.width),
                              Container(
                                width: 2.width,
                                height: 2.width,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: gradientColor2,
                                ),
                              ),
                              SizedBox(width: 1.width),
                              Text(
                                'Overall Revenue',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 8.fSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0XFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const Alignment(-0.8, 0),
                          child: Text(
                            '(Ringgit in thousands)',
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontSize: 6.fSize,
                              fontWeight: FontWeight.w600,
                              color: const Color(0XFF4313E9),
                            ),
                          ),
                        ),
                        BarChartSample7(),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 6.width, right: 5.width, top: 1.height),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 20.width),
                                  SizedBox(width: 5.width),
                                  SizedBox(
                                    width: 25.width,
                                    child: Text(
                                      'Monthly Revenue',
                                      style: TextStyle(
                                        color: const Color(0XFF888888),
                                        fontSize: 8.fSize,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Open Sans',
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 25.width,
                                    child: Text(
                                      'Monthly Rental Income',
                                      style: TextStyle(
                                        color: const Color(0XFF888888),
                                        fontSize: 8.fSize,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Open Sans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              revenueChartRow('April 2024', 'RM 0', 'RM 0'),
                              Divider(
                                color: Color(0XFF888888),
                                thickness: 0.5.fSize,
                              ),
                              revenueChartRow(
                                  'Mar 2024', 'RM 4,562.40', 'RM 4,562.40'),
                              Divider(
                                color: Color(0XFF888888),
                                thickness: 0.5.fSize,
                              ),
                              revenueChartRow(
                                  'Feb 2024', 'RM 100,562.40', 'RM 100,562.40'),
                              Divider(
                                color: Color(0XFF888888),
                                thickness: 0.5.fSize,
                              ),
                              revenueChartRow(
                                  'Jan 2024', 'RM 60,562.40', 'RM 60,562.40'),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Property(s)',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 20.fSize,
                                fontWeight: FontWeight.w800,
                                color: Color(0XFF4313E9),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 12.width,
                              height: 14.width,
                              child: Image.asset(
                                'assets/images/patterns.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              width: 5.width,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20.height,
                          child: ListView(
                            // This next line does the trick.
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Container(
                                width: 160,
                                color: Colors.red,
                              ),
                              Container(
                                width: 160,
                                color: Colors.blue,
                              ),
                              Container(
                                width: 160,
                                color: Colors.green,
                              ),
                              Container(
                                width: 160,
                                color: Colors.yellow,
                              ),
                              Container(
                                width: 160,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Highlights',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 20.fSize,
                                fontWeight: FontWeight.w800,
                                color: Color(0XFF4313E9),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 12.width,
                              height: 14.width,
                              child: Image.asset(
                                'assets/images/patterns.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              width: 5.width,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: SizedBox(
                                width: 40.width,
                                height: 20.height,
                                child: Image.asset(
                                  'assets/images/Promotions.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Spacer(),
                             ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: SizedBox(
                                width: 40.width,
                                height: 20.height,
                                child: Image.asset(
                                  'assets/images/Discounts.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.height,
                        ),
                        Row(
                          children: [
                             ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: SizedBox(
                                width: 40.width,
                                height: 20.height,
                                child: Image.asset(
                                  'assets/images/Exchange.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Spacer(),
                           ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: SizedBox(
                                width: 40.width,
                                height: 20.height,
                                child: Image.asset(
                                  'assets/images/Earn Points.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
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
