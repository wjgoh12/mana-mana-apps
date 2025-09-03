import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';

class OverviewCard extends StatelessWidget {
  final NewDashboardVM_v3 model;
  const OverviewCard({required this.model, super.key});

  String getTotalProfit() {
    final profit = model.overallProfit.toString();
    return profit;
  }

  String getOccupancyRate() {
    PropertyListRepository propertyrepo = PropertyListRepository();
    try {
      //get from all_property occupancy
      //calc units average from every location, then calc location avege occupancy rate

      // Calculate total properties
      final uniqueLocations =
          model.locationByMonth.map((e) => e['slocation']).toSet().toList();
      final totalProperties = uniqueLocations.length;

      //model.totalByMonth.map((e) => e['slocation']).toSet().toList();
      //final totalProperties = uniqueLocations.length;

      if (totalProperties == 0) return '0';

      // Calculate active properties (adjust this logic based on your data structure)
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
    String monthNumberToName(int month) {
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
        'Dec'
      ];
      if (month >= 1 && month <= 12) {
        return months[month - 1];
      } else {
        return 'Unknown';
      }
    }

    DateTime now = DateTime.now();
    String shortMonth = monthNumberToName(now.month);
    String year = now.year.toString();
    final uniqueLocations =
        model.totalByMonth.map((e) => e['slocation']).toSet().toList();

    final locationCount = uniqueLocations.length;
    final activeLocations = model.totalByMonth.where(
        (e) => e['unitstatus'] == 'Active' || e['unitstatus'] == 'ACTIVE');

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(context);

    final cardWidth = isMobile ? screenWidth * 0.42 : screenWidth * 0.45;
    final cardHeightSmall = isMobile ? screenWidth * 0.20 : screenWidth * 0.13;
    final cardHeightLarge = isMobile ? screenWidth * 0.28 : screenWidth * 0.21;

    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height

    ResponsiveSize.init(context);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? 500.fSize : 1000.fSize,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //1st
                    Card(
                      margin: EdgeInsets.only(bottom: responsiveHeight(10)),
                      child: Container(
                        width: cardWidth,
                        height: cardHeightLarge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/overviewContainer1.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(children: [
                                Positioned(
                                  left: 10,
                                  top: 10,
                                  child: CircleAvatar(
                                    radius: 20.fSize,
                                    backgroundColor: Colors.white,
                                    child: Image.asset(
                                      'assets/images/OverviewProperty.png',
                                      width: 18.fSize,
                                      height: 22.fSize,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Text(
                                          '$locationCount',
                                          //call total number of locations
                                          //total Properties

                                          style: TextStyle(
                                            fontSize: 40.fSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )),
                                    const SizedBox(
                                        width:
                                            1), // spacing between text and image
                                  ],
                                )
                              ]),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Total Properties',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.fSize,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Managed: ${locationCount} ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.fSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ),

                    //2nd
                    Card(
                      margin: EdgeInsets.only(bottom: responsiveHeight(10)),
                      color: const Color(0xFFFFE7B8),
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeightSmall,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10),
                                    child: CircleAvatar(
                                      radius: 19.fSize,
                                      backgroundColor: Colors.white,
                                      child: Image.asset(
                                        'assets/images/OverviewOccupancy.png',
                                        width: 30.fSize,
                                        height: 20.fSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8, top: 10),
                                  child: Text(
                                    'Occupancy Rate',
                                    style: TextStyle(
                                      fontSize: 8.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                //hard coded
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: FutureBuilder<String>(
                                    future: model.locationByMonth.isNotEmpty
                                        ? model
                                            .calculateTotalOccupancyForLocation(
                                                model.locationByMonth
                                                    .first['location'])
                                        : Future.value('0.0'),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text(
                                          'Loading...',
                                          style: TextStyle(
                                            fontSize: ResponsiveSize.text(15),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return const Text(
                                          'Error',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                      final occupancy = snapshot.data ?? '0.0';
                                      return Text(
                                        '$occupancy%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Text(
                                    'As of Month ${model.propertyOccupancy.isNotEmpty && model.propertyOccupancy.values.first['units'] != null && model.propertyOccupancy.values.first['units'].values.first != null && model.propertyOccupancy.values.first['units'].values.first is Map<String, dynamic> ? '${monthNumberToName(model.propertyOccupancy.values.first['units'].values.first['month'])} ${model.propertyOccupancy.values.first['units'].values.first['year']}' : '$shortMonth $year'}',
                                    style: const TextStyle(
                                      fontSize: 7.0,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: responsiveWidth(7)), // spacing between columns

                // Right Column
                Flexible(
                  child: Column(
                    children: [
                      //3rd
                      Card(
                        margin: EdgeInsets.only(bottom: responsiveHeight(10)),
                        color: const Color(0xFF9EEAFF),
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeightSmall,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  radius: 23.fSize,
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    'assets/images/OverviewMonthlyProfit.png',
                                    width: 30.fSize,
                                    height: 28.fSize,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10, top: 10),
                                    child: Text(
                                      'Monthly Profit',
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (model.monthlyBlcOwner.isNotEmpty) {
                                        // Get the latest month entry (assuming list is sorted newest first)
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
                                                        fontFamily: 'Open Sans',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: formatted,
                                                  style: TextStyle(
                                                    fontSize:
                                                        ResponsiveSize.text(15),
                                                    fontFamily: 'Open Sans',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            'RM0.00',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Open Sans',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      '$shortMonth $year',
                                      style: const TextStyle(
                                        fontSize: 8.0,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      //4th
                      Card(
                        //margin: const EdgeInsets.only(bottom: 20),
                        color: const Color(0xFFDBC7FF),
                        child: Container(
                          width: cardWidth,
                          height: cardHeightLarge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                12), // Match card's border radius
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/overviewContainer4.png'),
                              fit: BoxFit.cover,
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
                                    model: model),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

    final cardWidth = isMobile ? screenWidth * 0.42 : screenWidth * 0.5;
    final cardHeightSmall = isMobile ? screenWidth * 0.20 : screenWidth * 0.13;
    final cardHeightLarge = isMobile ? screenWidth * 0.28 : screenWidth * 0.21;

    final screenHeight = MediaQuery.of(context).size.height;

    double responsivePadding = isMobile ? 10 : 20;
    return SizedBox(
      width: cardWidth,
      height: cardHeightLarge,
      child: Stack(
        children: [
          GestureDetector(
            // onTap: () => model.updateOverallRevenueAmount(),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsivePadding),
                child: Column(
                  children: [
                    SizedBox(
                      height: (0.5).height,
                    ),
                    _buildTitleRow(),
                    //SizedBox(height: (1.5).height),
                    _buildAmountText(context),
                    _buildDateRow(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 20.fSize,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            'assets/images/OverviewAccumulatedProfit.png',
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
    String monthNumberToName(int month) {
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
        'Dec'
      ];
      if (month >= 1 && month <= 12) {
        return months[month - 1];
      } else {
        return 'Unknown';
      }
    }

    DateTime now = DateTime.now();
    String shortMonth = monthNumberToName(now.month);
    String year = now.year.toString();
    return Row(
      children: [
        // SizedBox(width: 3.width),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Open Sans',
            // fontSize: 12.fSize,
            fontSize: 10.fSize,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildDateRow() {
    String monthNumberToName(int month) {
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
        'Dec'
      ];
      if (month >= 1 && month <= 12) {
        return months[month - 1];
      } else {
        return 'Unknown';
      }
    }

    DateTime now = DateTime.now();
    String shortMonth = monthNumberToName(now.month);
    String year = now.year.toString();
    return Row(
      children: [
        Text(
          '$shortMonth $year',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 10.fSize,
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
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // SizedBox(width: 1.width),
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
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveSize.text(15),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
