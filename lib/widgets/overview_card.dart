import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
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
      return (month >= 1 && month <= 12) ? months[month - 1] : 'Unknown';
    }

    DateTime now = DateTime.now();
    String shortMonth = monthNumberToName(now.month);
    String year = now.year.toString();

    final uniqueLocations =
        model.totalByMonth.map((e) => e['slocation']).toSet().toList();

    final locationCount = uniqueLocations.length;
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 🔑 Responsive multipliers
    final cardWidth = isMobile ? screenWidth * 0.9 : screenWidth * 0.45;
    final smallCardHeight = screenHeight * 0.12; // ~12% of height
    final largeCardHeight = screenHeight * 0.25; // ~25% of height

    return SizedBox(
      width: double.infinity,
      child: isMobile
          ? Column(
              // 📱 stack on mobile
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeftColumn(context, cardWidth, smallCardHeight,
                    largeCardHeight, locationCount, shortMonth, year),
                const SizedBox(height: 20),
                _buildRightColumn(context, cardWidth, smallCardHeight,
                    largeCardHeight, shortMonth, year),
              ],
            )
          : Row(
              // 💻 side by side on larger screens
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeftColumn(context, cardWidth, smallCardHeight,
                    largeCardHeight, locationCount, shortMonth, year),
                const SizedBox(width: 20),
                Flexible(
                  child: _buildRightColumn(context, cardWidth, smallCardHeight,
                      largeCardHeight, shortMonth, year),
                ),
              ],
            ),
    );
  }

  /// Left Column
  Widget _buildLeftColumn(
      BuildContext context,
      double cardWidth,
      double smallCardHeight,
      double largeCardHeight,
      int locationCount,
      String shortMonth,
      String year) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1st big card
        Card(
          margin: const EdgeInsets.only(bottom: 20),
          child: Container(
            width: cardWidth,
            height: largeCardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/images/overviewContainer1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Positioned(
                      left: 10,
                      top: 10,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'assets/images/OverviewProperty.png',
                          width: 18,
                          height: 22,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            '$locationCount',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 1),
                      ],
                    )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Total Properties',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Managed: $locationCount ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2nd small card
        Card(
          margin: const EdgeInsets.only(bottom: 20),
          color: const Color(0xFFFFE7B8),
          child: SizedBox(
            width: cardWidth,
            height: smallCardHeight,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/OverviewOccupancy.png',
                      width: 30,
                      height: 20,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('Occupancy Rate',
                          style: TextStyle(fontSize: 10)),
                    ),
                    Text(
                      '${model.getTotalOccupancyRate()}%',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text('As of $shortMonth $year',
                        style: const TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Right Column
  /// Right Column
  Widget _buildRightColumn(
    BuildContext context,
    double cardWidth,
    double smallCardHeight,
    double largeCardHeight,
    String shortMonth,
    String year,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Monthly Profit Card
        Card(
          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          color: const Color(0xFF9EEAFF),
          child: SizedBox(
            width: cardWidth, // responsive width
            height: smallCardHeight, // responsive height
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.025),
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/OverviewMonthlyProfit.png',
                      width: 30,
                      height: 20,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.025, top: screenHeight * 0.015),
                      child: const Text(
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
                          final latestEntry = model.monthlyBlcOwner.first;
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
                              (profitEntry['total'] ?? 0.0).toDouble();
                          final formatted =
                              totalProfit.toStringAsFixed(2).replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]},',
                                  );

                          return Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.025),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: Transform.translate(
                                      offset: const Offset(0, -4),
                                      child: const Text(
                                        'RM',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Open Sans',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatted,
                                    style: const TextStyle(
                                      fontSize: 15,
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
                          return Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.025),
                            child: const Text(
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
                      padding: EdgeInsets.only(left: screenWidth * 0.025),
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

        // 4th big card (example, adjust content if needed)
        Card(
          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          color: const Color(0xFFDBC7FF),
          child: Container(
            width: cardWidth,
            height: largeCardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/images/overviewContainer4.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: RevenueContainer(
                title: '${model.revenueLastestYear} Accumulated Profit',
                icon: Icons.home_outlined,
                overallRevenue: false,
                model: model,
              ),
            ),
          ),
        ),
      ],
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
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width:
          Responsive.isMobile(context) ? screenWidth * 0.9 : screenWidth * 0.4,
      height:
          Responsive.isMobile(context) ? screenWidth * 0.8 : screenWidth * 0.5,
      child: Stack(
        children: [
          GestureDetector(
            // onTap: () => model.updateOverallRevenueAmount(),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(),
                  SizedBox(height: 8),
                  //SizedBox(height: (1.5).height),
                  _buildAmountText(),
                  _buildDateRow(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Transform.translate(
                            offset: Offset(0, -6),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: CircleAvatar(
                                radius: 20.fSize,
                                backgroundColor: Colors.white,
                                child: Image.asset(
                                  'assets/images/OverviewAccumulatedProfit.png',
                                  width: 30.fSize,
                                  height: 20.fSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
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

  Widget _buildAmountText() {
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
                  child: const Text(
                    'RM',
                    style: TextStyle(
                      fontSize: 11,
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
                  fontSize: 15.fSize,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
