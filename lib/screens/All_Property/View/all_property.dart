import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/property_dropdown.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:provider/provider.dart';

class AllPropertyScreen extends StatelessWidget {
  const AllPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewDashboardVM_v3()..fetchData(),
      child: Consumer<NewDashboardVM_v3>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: const Color(0XFFFFFFFF),
            appBar: propertyAppBar(
              context,
              () => Navigator.of(context).pop(),
            ),
            body: model.isLoading
                ? const Center(
                    child: CircularProgressIndicator()) // Show loading
                : Column(
                    children: [
                      // Add PropertyTitleDropdown shere
                      const Padding(
                        padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            PropertyTitleDropdown(currentPage: 'Property List'),
                          ],
                        ),
                      ),
                      // Main content
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          children: [
                            GestureDetector(
                              child: SizedBox(
                                child: Column(
                                  children: model.locationByMonth
                                      .map((property) => property['location'])
                                      .toSet()
                                      .map((uniqueLocation) {
                                    final property = model.locationByMonth
                                        .firstWhere((p) =>
                                            p['location'] == uniqueLocation);
                                    return SizedBox(
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            child: _buildPropertyStack(
                                              locationByMonth: [property],
                                              context: context,
                                              model: model,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 1),
          );
        },
      ),
    );
  }

  Widget _buildPropertyStack({
    required List<Map<String, dynamic>> locationByMonth,
    required BuildContext context,
    required NewDashboardVM_v3 model,
  }) {
    final latestMonth = model.unitLatestMonth;
    final latestYear = model.locationByMonth
        .map((p) => p['year'])
        .reduce((a, b) => a > b ? a : b);

    final latestLocationByMonth = model.locationByMonth
        .where((p) => p['year'] == latestYear && p['month'] == latestMonth)
        .toList();

    //print("Filtered data passed to PropertyStack:");
    for (var item in latestLocationByMonth) {
      print(
          "Location: ${item['location']}, Month: ${item['month']}, Owners: ${item['owners']}, TotalUnits: ${item['totalUnits']}");
    }
    print("locationByMonth length: ${model.locationByMonth.length}");

    // String locationRoad = '';
    // switch (locationByMonth[0]['location'].toUpperCase()) {
    //   case "EXPRESSIONZ":
    //     locationRoad = "Jalan Tun Razak";
    //     break;
    //   case "CEYLONZ":
    //     locationRoad = "Persiaran Raja Chulan";
    //     break;
    //   case "SCARLETZ":
    //     locationRoad = "Jalan Yap Kwan Seng";
    //     break;
    //   case "MILLERZ":
    //     locationRoad = "Old Klang Road";
    //     break;
    //   case "MOSSAZ":
    //     locationRoad = "Empire City";
    //     break;
    //   case "PAXTONZ":
    //     locationRoad = "Empire City";
    //     break;
    //   default:
    //     locationRoad = "";
    //     break;
    // }
    return Column(
      children: [
        ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 40),

          scrollDirection: Axis.vertical,

          // shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            // ...model.locationByMonth
            //     .where((property) =>
            //         property['year'] ==
            //             model.locationByMonth
            //                 .map((p) => p['year'])
            //                 .reduce((a, b) => a > b ? a : b) &&
            //         property['month'] == model.unitLatestMonth)
            //     .expand((property) => [
            //           PropertyImageStack(
            //             locationByMonth: [property],
            //           ),
            //           const SizedBox(width: 20),
            //         ])

            ...model.locationByMonth
                .where((property) => property['year'] == latestYear)
                .toList()
              ..sort((a, b) => (b['month'] as int)
                  .compareTo(a['month'] as int)) // 👈 sort by month descending
          ]
              .expand((property) => [
                    PropertyStack(locationByMonth: [property]),
                    const SizedBox(width: 20),
                  ])
              .toList(),
          // ViewAllProperty(model: model),
        ),
      ],
    );
  }
}
