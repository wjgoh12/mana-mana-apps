import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/millerz_square1.dart';
import 'package:mana_mana_app/screens/personal_millerz_square.dart';
import 'package:mana_mana_app/widgets/bar_chart.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_grid/responsive_grid.dart' hide ResponsiveBuilder;
import 'package:responsive_builder/responsive_builder.dart';

class NewDashboardPage extends StatelessWidget {
  void navigateToPersonalMillerzSquare(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PersonalMillerzSquare1Screen(),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      clipBehavior: Clip.none,
      children: [
        _buildBackgroundContainer(),
        Column(
          children: [
            SizedBox(height: 2.height),
            _buildTopBar(context),
            SizedBox(height: 2.height),
            _buildUserInfo(),
          ],
        ),
        Positioned(
          top: 20.height,
          child: Container(
            width: 100.width,
            height: 80.height,
            padding: EdgeInsets.all(7.width),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0XFFFFFFFF), Color(0XFFDFD8FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRevenueContainers(),
                  SizedBox(height: 2.height),
                  _buildSectionTitle('Statistics'),
                  SizedBox(height: 2.height),
                  _statisticTable(),
                  SizedBox(height: 2.height),
                  _buildSectionTitle('Property(s)'),
                  SizedBox(height: 2.height),
                  _buildPropertyList(),
                  SizedBox(height: 2.height),
                  _buildSectionTitle('Highlights'),
                  SizedBox(height: 2.height),
                  _buildHighlights(),
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}

Widget _buildBackgroundContainer() {
  return Container(
    alignment: Alignment.topCenter,
    width: 100.width,
    height: 100.height,
    color: const Color(0XFF4313E9),
    padding: EdgeInsets.only(top: 2.height),
    child: Image.asset(
      'assets/images/mana2_patterns.png',
      width: 110.width,
      height: 30.height,
      fit: BoxFit.cover,
    ),
  );
}

Widget _buildTopBar(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      IconButton(
        onPressed: () => navigateToPersonalMillerzSquare(context),
        icon: Image.asset(
          'assets/images/dashboard_menu.png',
          width: 6.width,
          height: 3.height,
          fit: BoxFit.contain,
        ),
      ),
      Text(
        'Main Dashboard',
        style: TextStyle(
          fontSize: 20.fSize,
          color: Color(0xFFC3B9FF),
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w800,
          shadows: const [
            Shadow(color: Color(0XFFC3B9FF), blurRadius: 0.5, offset: Offset(0.25, 0.5))
          ],
        ),
      ),
      InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MillerzSquare1Screen())),
        child: Image.asset(
          'assets/images/notifications.png',
          width: 6.width,
          height: 3.height,
          fit: BoxFit.contain,
        ),
      ),
    ],
  );
}

Widget _buildUserInfo() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      SizedBox(width: 10.width),
      Image.asset(
        'assets/images/dashboard_gem.png',
        width: 8.width,
        height: 6.height,
        fit: BoxFit.contain,
      ),
      SizedBox(width: 5.width),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good day!',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 15.fSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            'Azeem Mohd Fahmi',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 20.fSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildRevenueContainers() {
  return Row(
    children: [
      _revenueContainer('Overall Revenue', Icons.account_balance_wallet_outlined),
      const Spacer(),
      _revenueContainer('Overall Rental Income', Icons.home_outlined),
    ],
  );
}

Widget _buildSectionTitle(String title) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: TextStyle(
        fontFamily: 'Open Sans',
        fontSize: 20.fSize,
        fontWeight: FontWeight.w800,
        color: Color(0XFF4313E9),
      ),
    ),
  );
}

Widget _buildPropertyList() {
  return SizedBox(
    height: 38.height,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        const _propertyImageStack(
          image: 'Millerz_square2',
          label: 'MILLERZ SQUARE',
          location: '@ Old Klang Road',
          amount: '3,300.00',
        ),
        SizedBox(width: 5.width),
        const _propertyImageStack(
          image: 'expression_suites_property',
          label: 'EXPRESSIONZ SUITES',
          location: '@ Jalan Tun Razak',
          amount: '2,045.19',
        ),
        SizedBox(width: 5.width),
        const _propertyImageStack(
          image: 'ceylonz_suites',
          label: 'CEYLONZ SUITES',
          location: '@ Bukit Ceylon',
          amount: '5,400.00',
        ),
        SizedBox(width: 5.width),
        _buildViewAllProperty(),
      ],
    ),
  );
}

Widget _buildViewAllProperty() {
  return Container(
    width: 51.width,
    height: 38.height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: const Color(0XFF120051).withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        )
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'VIEW ALL',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20.fSize,
            color: const Color(0XFF4313E9),
          ),
        ),
        Text(
          '@ Your Property(s)',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w300,
            fontSize: 10.fSize,
            fontStyle: FontStyle.italic,
            color: const Color(0XFF4313E9),
          ),
        ),
        SizedBox(height: 2.height),
        Container(
          width: 7.width,
          height: 7.width,
          decoration: const BoxDecoration(color: Color(0XFF4313E9)),
          child: const Icon(
            Icons.keyboard_arrow_right_rounded,
            color: Colors.white,
          ),
        )
      ],
    ),
  );
}

Widget _buildHighlights() {
  return Column(
    children: [
      ResponsiveGridRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGridCol(
            xs: 6,
            child: Image.asset('assets/images/Promotions.png'),
          ),
          ResponsiveGridCol(
            xs: 6,
            child: Image.asset('assets/images/Discounts.png'),
          ),
        ],
      ),
      SizedBox(height: 2.height),
      ResponsiveGridRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGridCol(
            xs: 6,
            child: Image.asset('assets/images/Exchange.png'),
          ),
          ResponsiveGridCol(
            xs: 6,
            child: Image.asset('assets/images/Earn Points.png'),
          ),
        ],
      ),
    ],
  );
}
  }

class _propertyImageStack extends StatelessWidget {
  //add responsive builder
  const _propertyImageStack(
      {super.key,
      required this.image,
      required this.label,
      required this.location,
      required this.amount});
  final String image;
  final String label;
  final String location;
  final String amount;

  @override
  Widget build(BuildContext context) {
    var width = 51.width;
    var height = 30.height;
    var position = 20.height;
    var containerWidth = 41.width;
    var containerHeight = 18.height;
    var arrowTop = 30.height;
    var arrowLeft = 37.5.width;
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
      } else {
        width = 40.width;
        height = 30.height;
        position = 20.height;
        containerWidth = 31.width;
        containerHeight = 18.height;
        arrowTop = 30.height;
        arrowLeft = 27.5.width;
      }
      return Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
              width: width,
              height: height,
              child: Image.asset(
                'assets/images/$image.png',
                fit: BoxFit.fill,
              )),
          Positioned(
            top: position,
            child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0XFF120051).withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                    color: const Color(0XFFFFFFFF),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10))),
                child: Padding(
                  padding: EdgeInsets.only(top: 2.height, left: 2.width),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 20.fSize,
                            color: const Color(0XFF4313E9)),
                      ),
                      Text(
                        location,
                        style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w300,
                            fontSize: 10.fSize,
                            fontStyle: FontStyle.italic,
                            color: const Color(0XFF4313E9)),
                      ),
                      SizedBox(
                        height: 2.height,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RM',
                            style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 10.fSize,
                                color: const Color(0XFF4313E9)),
                          ),
                          Text(
                            amount,
                            style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 20.fSize,
                                color: const Color(0XFF4313E9)),
                          ),
                        ],
                      ),
                      Text('Total Owner Profit Of The Month',
                          style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 8.fSize,
                              color: const Color(0XFF4313E9))),
                    ],
                  ),
                )),
          ),
          Positioned(
              top: arrowTop,
              left: arrowLeft,
              child: Container(
                alignment: Alignment.center,
                width: 7.width,
                height: 5.height,
                decoration: const BoxDecoration(
                  color: Color(0XFF4313E9),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: Colors.white,
                ),
              ))
        ],
      );
    });
  }
}


Widget _revenueContainer(title, icon) {
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
                    blurRadius: 4)
              ]),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 1.width,
                  ),
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
                  //here
                  Container(
                      width: 3.width,
                      height: 3.width,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        color: Color(0xff3E51FF),
                        size: 3.width,
                      ))
                ],
              ),
              SizedBox(height: 1.height),
              Row(
                children: [
                  SizedBox(
                    width: 1.width,
                  ),
                  Container(
                    width: 8.width,
                    height: 8.width,
                    decoration: const BoxDecoration(
                        color: Color(0XFFF9F8FF), shape: BoxShape.circle),
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
                      Text.rich(TextSpan(
                          text: 'RM',
                          style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 12.fSize,
                              color: const Color(0XFF2900B7)),
                          children: <InlineSpan>[
                            WidgetSpan(
                                child: SizedBox(
                              width: 1.width,
                            )),
                            TextSpan(
                              text: '9,999.99',
                              style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.fSize,
                                  color: const Color(0XFF2900B7)),
                            )
                          ])),
                      Text.rich(TextSpan(
                          text: '100%',
                          style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 10.fSize,
                              color: const Color(0XFF2900B7)),
                          children: <InlineSpan>[
                            WidgetSpan(
                                child: Icon(
                              Icons.arrow_drop_up,
                              color: const Color(0XFF42C18B),
                              size: 2.height,
                            )),
                          ])),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: SizedBox(
              child: Image.asset(
            'assets/images/patterns_unit_revenue.png',
            fit: BoxFit.cover,
          )),
        ),
      ],
    ),
  );
}

Widget _statisticTable() {
  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
            color: const Color(0XFFF9F8FF),
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.only(
              left: 6.width, right: 3.width, top: 2.height, bottom: 2.height),
          child: Column(children: [
            Row(
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
              ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                  'Overall Rental Revenue',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 8.fSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0XFF888888),
                  ),
                ),
              ],
            ),
            BarChartSample7(),
            Column(
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
                revenueChartRow('Mar 2024', 'RM 4,562.40', 'RM 4,562.40'),
                Divider(
                  color: Color(0XFF888888),
                  thickness: 0.5.fSize,
                ),
                revenueChartRow('Feb 2024', 'RM 100,562.40', 'RM 100,562.40'),
                Divider(
                  color: Color(0XFF888888),
                  thickness: 0.5.fSize,
                ),
                revenueChartRow('Jan 2024', 'RM 60,562.40', 'RM 60,562.40'),
              ],
            ),
          ]),
        ),
      ),
      Positioned(
        left: 0,
        top: -5.height,
        child: SizedBox(
          width: 27.width,
          height: 16.height,
          child: Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/images/patterns_faded.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      Positioned(
          right: 0,
          top: 1.height,
          child: SizedBox(
            width: 27.width,
            height: 16.height,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset('assets/images/patterns_faded.png'),
            ),
          )),
      Positioned(
          bottom: 1.height,
          left: 1.width,
          child: SizedBox(
            width: 27.width,
            height: 16.height,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset('assets/images/patterns_faded.png'),
            ),
          )),
      Positioned(
          right: 0,
          bottom: -5.height,
          child: SizedBox(
            width: 27.width,
            height: 16.height,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset('assets/images/patterns_faded.png'),
            ),
          )),
    ],
  );
}
