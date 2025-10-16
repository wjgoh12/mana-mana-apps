import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property_new.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:provider/provider.dart';

class OverviewCard extends StatelessWidget {
  final NewDashboardVM_v3 model;
  const OverviewCard({required this.model, super.key});

  String getTotalProfit() {
    final profit = model.overallProfit.toString();
    return profit;
  }

  PageRouteBuilder _createRoute(Widget page,
      {String transitionType = 'slide'}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case 'fade':
            return FadeTransition(opacity: animation, child: child);

          case 'scale':
            return ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );

          case 'slideUp':
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );

          case 'slideLeft':
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );

          default: // 'slide' - slide from right
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );
        }
      },
    );
  }

  String getOccupancyRate() {
    PropertyListRepository propertyrepo = PropertyListRepository();
    try {
      final uniqueLocations =
          model.locationByMonth.map((e) => e['slocation']).toSet().toList();
      final totalProperties = uniqueLocations.length;
      if (totalProperties == 0) return '0';

      final activeProperties = model.locationByMonth
          .where(
              (e) => e['unitstatus'] == 'Active' || e['unitstatus'] == 'ACTIVE')
          .map((e) => e['slocation'])
          .toSet()
          .length;

      final percentage = (activeProperties / totalProperties * 100).round();
      return percentage.toString();
    } catch (e) {
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> getPreviousMonthYear(DateTime now) {
      int prevMonth = now.month - 1;
      int year = now.year;

      if (prevMonth == 0) {
        prevMonth = 12; // December
        year -= 1; // Go back one year
      }

      const months = [
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
        'Dec',
      ];

      return {
        "month": months[prevMonth - 1],
        "year": year.toString(),
      };
    }

    final prev = getPreviousMonthYear(DateTime.now());

    String shortMonth = prev["month"]!;
    String year = prev["year"]!;
    // Calculate active/managed units count
    final managedUnitsCount = model.totalByMonth
        .where(
            (e) => e['unitstatus'] == 'Active' || e['unitstatus'] == 'ACTIVE')
        .map((e) => e['sunit'])
        .toSet()
        .length;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = Responsive.isMobile(context);

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width (for gaps only)
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height

    ResponsiveSize.init(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the ACTUAL available width inside the parent (after padding).
        final availableWidth = constraints.maxWidth;

        // Single place to control the inter-column gap.
        final gapBetweenColumns = responsiveWidth(8);

        // Compute each column width so that left/right outer gaps are equal.
        final cardWidth = (availableWidth - gapBetweenColumns) / 2;

        // Heights can remain proportional; no change needed here.
        final cardHeightSmall =
            isMobile ? screenWidth * 0.20 : screenWidth * 0.13;
        final cardHeightLarge =
            isMobile ? screenWidth * 0.28 : screenWidth * 0.21;

        return Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (fixed position, exact width)
                SizedBox(
                  width: cardWidth,
                  child: Column(
                    children: [
                      // 1st - Updated to show total properties count
                      Container(
                        margin: EdgeInsets.only(bottom: responsiveHeight(5)),
                        child: Container(
                          width: double.infinity, // fill column width
                          height: cardHeightLarge +
                              cardHeightSmall +
                              responsiveHeight(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage(
                                  'assets/images/dashboardcardview1.png'),
                              fit: BoxFit.fill, // Changed from cover to fill
                              alignment: Alignment.center,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: [
                                  Positioned(
                                    left: 10,
                                    top: 10,
                                    child: CircleAvatar(
                                      radius: 20.fSize,
                                      backgroundColor: Color(0xFF000241),
                                      child: Image.asset(
                                        'assets/images/OverviewProperty.png',
                                        width: ResponsiveSize.scaleWidth(18),
                                        height: ResponsiveSize.scaleHeight(20),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const SizedBox(width: 1),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: FutureBuilder<int>(
                                          future: PropertyListRepository
                                              .getTotalPropertyCount(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text(
                                                '0',
                                                style: TextStyle(
                                                  fontSize:
                                                      ResponsiveSize.text(50),
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF000241),
                                                ),
                                              );
                                            }
                                            if (snapshot.hasError) {
                                              return Text(
                                                '0',
                                                style: TextStyle(
                                                  fontSize:
                                                      ResponsiveSize.text(50),
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF000241),
                                                ),
                                              );
                                            }
                                            final totalCount =
                                                snapshot.data ?? 0;
                                            return Text(
                                              '$totalCount',
                                              style: TextStyle(
                                                fontSize:
                                                    ResponsiveSize.text(50),
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF000241),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  final newDashboardVM =
                                      context.read<NewDashboardVM>();
                                  Navigator.pushReplacement(
                                      context,
                                      _createRoute(const AllPropertyNewScreen(),
                                          transitionType: 'fade'));
                                },
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: ResponsiveSize.scaleHeight(20)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            'Total Properties',
                                            style: TextStyle(
                                              fontFamily: 'outfit',
                                              color: Color(0xFF000241),
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Managed:', // Show managed units count
                                                style: TextStyle(
                                                  fontFamily: 'outfit',
                                                  color: Color(0xFF000241),
                                                  fontSize:
                                                      ResponsiveSize.text(14),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              FutureBuilder<int>(
                                                  future: PropertyListRepository
                                                      .getTotalPropertyCount(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Text(
                                                        '0',
                                                        style: TextStyle(
                                                          fontSize:
                                                              ResponsiveSize
                                                                  .text(14),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF000241),
                                                        ),
                                                      );
                                                    }
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                        '0',
                                                        style: TextStyle(
                                                          fontSize:
                                                              ResponsiveSize
                                                                  .text(14),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF000241),
                                                        ),
                                                      );
                                                    }
                                                    final totalCount =
                                                        snapshot.data ?? 0;
                                                    return Text(
                                                      '$totalCount',
                                                      style: TextStyle(
                                                        fontSize:
                                                            ResponsiveSize.text(
                                                                14),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF000241),
                                                      ),
                                                    );
                                                  })
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Gap between columns
                SizedBox(width: gapBetweenColumns),

                // Right Column (exact same width)
                SizedBox(
                  width: cardWidth,
                  child: Column(
                    children: [
                      // 3rd - Monthly Profit Card (unchanged)
                      Card(
                        margin: EdgeInsets.only(bottom: responsiveHeight(5)),
                        color: const Color(0xFF000241),
                        child: SizedBox(
                          width: double.infinity,
                          height: cardHeightSmall,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  radius: 23.fSize,
                                  backgroundColor: Color(0xFFFFCF00),
                                  child: Image.asset(
                                    'assets/images/OverviewMonthlyProfit.png',
                                    color: Color(0xFF000241),
                                    width: 30.fSize,
                                    height: 28.fSize,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: Text(
                                      'Monthly Profit',
                                      style: TextStyle(
                                        fontSize: ResponsiveSize.text(10),
                                        fontFamily: 'outfit',
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (model.monthlyBlcOwner.isNotEmpty) {
                                        final latestEntry =
                                            model.monthlyBlcOwner.first;
                                        final year = latestEntry['year'];
                                        final month = latestEntry['month'];

                                        final profitEntry =
                                            model.monthlyProfitOwner.firstWhere(
                                          (profit) =>
                                              profit['year'] == year &&
                                              profit['month'] == month,
                                          orElse: () => {'total': 0.00},
                                        );

                                        final totalProfit =
                                            (profitEntry['total'] ?? 0.0)
                                                .toDouble();
                                        final formatted = totalProfit
                                            .toStringAsFixed(2)
                                            .replaceAllMapped(
                                              RegExp(
                                                  r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                              (m) => '${m[1]},',
                                            );

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  alignment:
                                                      PlaceholderAlignment
                                                          .baseline,
                                                  baseline:
                                                      TextBaseline.alphabetic,
                                                  child: Transform.translate(
                                                    offset: const Offset(0, -4),
                                                    child: Text(
                                                      'RM',
                                                      style: TextStyle(
                                                        fontSize:
                                                            ResponsiveSize.text(
                                                                11),
                                                        fontFamily: 'outfit',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: formatted,
                                                  style: TextStyle(
                                                    fontSize:
                                                        ResponsiveSize.text(15),
                                                    fontFamily: 'outfit',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            'RM0.00',
                                            style: TextStyle(
                                              fontSize: ResponsiveSize.text(15),
                                              fontFamily: 'outfit',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(left: 10),
                                  //   child: Text(
                                  //     '$shortMonth $year',
                                  //     style: TextStyle(
                                  //       fontFamily: 'outfit',
                                  //       fontSize: ResponsiveSize.text(8),
                                  //       fontStyle: FontStyle.normal,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 4th - Accumulated Profit Card (unchanged)
                      Container(
                        width: double.infinity,
                        height: cardHeightLarge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: AssetImage(
                                'assets/images/dashboardcardview2.png'),
                            fit: BoxFit.fill, // Changed from fitWidth to fill
                            alignment: Alignment.center,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              RevenueContainer(
                                title:
                                    '${model.revenueLastestYear} Accumulated Profit​',
                                icon: Icons.home_outlined,
                                overallRevenue: false,
                                model: model,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class RevenueContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool overallRevenue;
  final NewDashboardVM_v3 model;
  const RevenueContainer({
    Key? key,
    required this.title,
    required this.icon,
    required this.overallRevenue,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final cardHeightLarge = isMobile ? screenWidth * 0.28 : screenWidth * 0.21;

    double responsivePadding = isMobile ? 10 : 20;
    return SizedBox(
      width: double.infinity, // will fill the parent column width
      height: cardHeightLarge,
      child: Stack(
        children: [
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsivePadding),
                child: Column(
                  children: [
                    SizedBox(height: (0.5).height),
                    _buildTitleRow(),
                    _buildAmountText(context),
                    // _buildDateRow(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 20.fSize,
                          backgroundColor: Color(0xFFFFCF00),
                          child: Image.asset(
                            'assets/images/OverviewAccumulatedProfit.png',
                            color: Color(0xFF000241),
                            width: 26.fSize,
                            height: 24.fSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'outfit',
            fontSize: ResponsiveSize.text(9),
            color: Colors.white,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildDateRow() {
    Map<String, String> getPreviousMonthYear(DateTime now) {
      int prevMonth = now.month - 1;
      int year = now.year;

      if (prevMonth == 0) {
        prevMonth = 12; // December
        year -= 1; // Go back one year
      }

      const months = [
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
        'Dec',
      ];

      return {
        "month": months[prevMonth - 1],
        "year": year.toString(),
      };
    }

    final prev = getPreviousMonthYear(DateTime.now());

    String shortMonth = prev["month"]!;
    String year = prev["year"]!;
    return Row(
      children: [
        Text(
          '$shortMonth $year',
          style: TextStyle(
            fontFamily: 'outfit',
            fontSize: ResponsiveSize.text(10),
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: Text(
                    'RM',
                    style: TextStyle(
                      fontSize: ResponsiveSize.text(11),
                      fontFamily: 'outfit',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
                  fontFamily: 'outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveSize.text(15),
                  color: Colors.white,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

// Small helper to replace literal text in a const Text with dynamic content
extension _TextReplace on Text {
  Widget buildWithText(String newText) {
    return Text(
      newText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
