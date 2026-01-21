import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/screens/all_properties/view/all_properties_view.dart';
import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/core/utils/responsive.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';
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

          default:
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
        prevMonth = 12;
        year -= 1;
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

    getPreviousMonthYear(DateTime.now());

    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 450) screenWidth = 450;
    double screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight > 850) screenHeight = 850;
    final isMobile = Responsive.isMobile(context);

    double responsiveWidth(double value) => (value / 375.0) * screenWidth;
    double responsiveHeight(double value) => (value / 812.0) * screenHeight;

    ResponsiveSize.init(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final gapBetweenColumns = responsiveWidth(8);

        final cardWidth = (availableWidth - gapBetweenColumns) / 2;

        final cardHeightSmall =
            isMobile ? screenWidth * 0.20 : screenWidth * 0.13;
        final cardHeightLarge =
            isMobile ? screenWidth * 0.28 : screenWidth * 0.21;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: responsiveHeight(5)),
                        child: Container(
                          width: double.infinity,
                          height: cardHeightLarge +
                              cardHeightSmall +
                              responsiveHeight(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primaryYellow,
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
                                      radius: ResponsiveSize.scaleWidth(20),
                                      backgroundColor: AppColors.primaryGrey,
                                      child: Image.asset(
                                        'assets/images/OverviewProperty.png',
                                        width: ResponsiveSize.scaleWidth(24),
                                        height: ResponsiveSize.scaleHeight(24),
                                        color: AppColors.primaryYellow,
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
                                                  fontSize: AppDimens
                                                      .fontSizeExtraLarge,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryGrey,
                                                ),
                                              );
                                            }
                                            if (snapshot.hasError) {
                                              return Text(
                                                '0',
                                                style: TextStyle(
                                                  fontSize: AppDimens
                                                      .fontSizeExtraLarge,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryGrey,
                                                ),
                                              );
                                            }
                                            final totalCount =
                                                snapshot.data ?? 0;
                                            return Text(
                                              '$totalCount',
                                              style: TextStyle(
                                                fontSize: AppDimens
                                                    .fontSizeExtraLarge,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryGrey,
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
                                  context.read<NewDashboardVM>();
                                  Navigator.pushReplacement(
                                      context,
                                      _createRoute(const AllPropertyNewScreen(),
                                          transitionType: 'fade'));
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: ResponsiveSize.scaleHeight(20)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          'Total Properties',
                                          style: TextStyle(
                                            fontFamily: 'outfit',
                                            color: AppColors.primaryGrey,
                                            fontSize: ResponsiveSize.text(12),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: [
                                            FutureBuilder<int>(
                                                future: PropertyListRepository
                                                    .getTotalPropertyCount(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Text(
                                                      '0',
                                                      style: TextStyle(
                                                        fontSize:
                                                            ResponsiveSize.text(
                                                                18),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryGrey,
                                                      ),
                                                    );
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                      '0',
                                                      style: TextStyle(
                                                        fontSize:
                                                            ResponsiveSize.text(
                                                                18),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryGrey,
                                                      ),
                                                    );
                                                  }
                                                  final totalCount =
                                                      snapshot.data ?? 0;
                                                  return Text(
                                                    'Managed: $totalCount',
                                                    style: TextStyle(
                                                      fontFamily: 'Outfit',
                                                      fontSize:
                                                          AppDimens.fontSizeBig,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                          0xFF606060),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: gapBetweenColumns),
                SizedBox(
                  width: cardWidth,
                  child: Column(
                    children: [
                      Card(
                        margin: EdgeInsets.only(bottom: responsiveHeight(5)),
                        color: AppColors.primaryGrey,
                        child: SizedBox(
                          width: double.infinity,
                          height: cardHeightSmall,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  radius: ResponsiveSize.scaleWidth(20),
                                  backgroundColor: AppColors.primaryYellow,
                                  child: Image.asset(
                                    'assets/images/OverviewMonthlyProfit.png',
                                    color: AppColors.primaryGrey,
                                    width: ResponsiveSize.scaleWidth(28),
                                    height: ResponsiveSize.scaleHeight(24),
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
                                        fontSize: AppDimens.fontSizeSmall,
                                        fontFamily: AppFonts.outfit,
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
                                                        fontFamily:
                                                            AppFonts.outfit,
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
                                                        AppDimens.fontSizeBig,
                                                    fontFamily: AppFonts.outfit,
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
                                              fontSize: AppDimens.fontSizeBig,
                                              fontFamily: AppFonts.outfit,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: cardHeightLarge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primaryGrey,
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
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 450) screenWidth = 450;

    final cardHeightLarge = isMobile ? screenWidth * 0.28 : screenWidth * 0.21;

    double responsivePadding = isMobile ? 10 : 20;
    return SizedBox(
      width: double.infinity,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: ResponsiveSize.scaleWidth(20),
                          backgroundColor: Color(0xFFFFCF00),
                          child: Image.asset(
                            'assets/images/OverviewAccumulatedProfit.png',
                            color: AppColors.primaryGrey,
                            width: ResponsiveSize.scaleWidth(24),
                            height: ResponsiveSize.scaleHeight(24),
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
            fontFamily: AppFonts.outfit,
            fontSize: AppDimens.fontSizeSmall,
            color: Colors.white,
          ),
        ),
        const Spacer(),
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
                      fontSize: AppDimens.fontSizeSmall,
                      fontFamily: AppFonts.outfit,
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
                  fontFamily: AppFonts.outfit,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimens.fontSizeBig,
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
