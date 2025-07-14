import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PropertyList extends StatelessWidget {
  final NewDashboardVM model;
  const PropertyList({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
        if (model.isLoading) {
          // Check if data is still loading
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(), // Display a loading spinner
            ),
          );
        }

        return model.locationByMonth.isEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text('No properties available'),
                ),
              )
            : SizedBox(
                height: 38.height,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...model.locationByMonth
                        .where((property) =>
                            property['year'] ==
                                model.locationByMonth
                                    .map((p) => p['year'])
                                    .reduce((a, b) => a > b ? a : b) &&
                            property['month'] == model.unitLatestMonth)
                        .expand((property) => [
                              PropertyImageStack(
                                locationByMonth: [property],
                              ),
                              const SizedBox(width: 20),
                            ])
                        .toList(),
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
                    //     .toList(),
                    const SizedBox(width: 5),
                    ViewAllProperty(model: model),
                  ],
                ),
              );
      
  }
}

class PropertyImageStack extends StatelessWidget {
  List<Map<String, dynamic>> locationByMonth;
  PropertyImageStack({
    Key? key,
    // required this.image,
    // required this.label,
    // required this.location,
    // required this.amount,
    required this.locationByMonth,
  }) : super(key: key);

  // final String image;
  // final String label;
  // final String location;
  // final String amount;

  @override
  Widget build(BuildContext context) {
    String getMonthAbbreviation(int month) {
      switch (month) {
        case 1:
          return 'Jan';
        case 2:
          return 'Feb';
        case 3:
          return 'Mar';
        case 4:
          return 'Apr';
        case 5:
          return 'May';
        case 6:
          return 'Jun';
        case 7:
          return 'Jul';
        case 8:
          return 'Aug';
        case 9:
          return 'Sep';
        case 10:
          return 'Oct';
        case 11:
          return 'Nov';
        case 12:
          return 'Dec';
        default:
          return '';
      }
    }

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isMobile =
            sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        final width = isMobile ? 51.width : 40.width;
        final height = 30.height;
        final position = 20.height;
        final containerWidth = isMobile ? 41.width : 31.width;
        final containerHeight = 18.height;
        final arrowTop = 30.height;
        final arrowLeft = isMobile ? 37.5.width : 27.5.width;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetail(locationByMonth: locationByMonth),
                  ),
                );
              },
              child: SizedBox(
                width: width,
                height: height,
                child: Image.asset(
                  'assets/images/${locationByMonth.first['location'].toUpperCase()}.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: position,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetail(locationByMonth: locationByMonth),
                    ),
                  );
                },
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0XFF120051).withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                    color: const Color(0XFFFFFFFF),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.height, left: 2.width),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationByMonth.first['location'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 20.fSize,
                            color: const Color(0XFF4313E9),
                          ),
                        ),
                        Text(
                          '${getMonthAbbreviation(locationByMonth.first['month'])} ${locationByMonth.first['year']}',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w300,
                            fontSize: 11.fSize,
                            fontStyle: FontStyle.italic,
                            color: const Color(0XFF4313E9),
                          ),
                        ),
                        SizedBox(height: 2.height),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RM',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 10.fSize,
                                color: const Color(0XFF4313E9),
                              ),
                            ),
                            Text(
                              NumberFormat('#,##0.00').format(locationByMonth.first['total']),
                              // locationByMonth.first['total'].toString(),
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 20.fSize,
                                color: const Color(0XFF4313E9),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Total Net After POB​',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 10.fSize,
                            color: const Color(0XFF4313E9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: arrowTop,
              left: arrowLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetail(locationByMonth: locationByMonth),
                    ),
                  );
                },
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
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class ViewAllProperty extends StatelessWidget {
  final NewDashboardVM model;
  const ViewAllProperty({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AllPropertyScreen()));
      },
      child: Container(
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
              '@ Your Properties',
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
      ),
    );
  }
}
