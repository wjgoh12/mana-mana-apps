import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/occupancy_text.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PropertyListV3 extends StatelessWidget {
  final ScrollController controller;
  final NewDashboardVM_v3 model;
  PropertyListV3({required this.model, required this.controller, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (model.isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
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
            height: 450.fSize,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notif) {
                if (notif is ScrollStartNotification &&
                    notif.metrics.axis == Axis.horizontal) {
                  // e.g. disable outer scroll if needed
                  return true;
                }
                return false; // allow notifications to continue
              },
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
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
                            const SizedBox(width: 40),
                          ])
                      .toList(),
                  const SizedBox(width: 5),
                  // ViewAllProperty(model: model),
                ],
              ),
            ),
          );
  }
}

class PropertyImageStack extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;

  const PropertyImageStack({
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
    String locationRoad = '';
    switch (locationByMonth[0]['location'].toUpperCase()) {
      case "EXPRESSIONZ":
        locationRoad = "Jalan Tun Razak";
        break;
      case "CEYLONZ":
        locationRoad = "Persiaran Raja Chulan";
        break;
      case "SCARLETZ":
        locationRoad = "Jalan Yap Kwan Seng";
        break;
      case "MILLERZ":
        locationRoad = "Old Klang Road";
        break;
      case "MOSSAZ":
        locationRoad = "Empire City";
        break;
      case "PAXTONZ":
        locationRoad = "Empire City";
        break;
      default:
        locationRoad = "";
        break;
    }
    final NewDashboardVM_v3 model = NewDashboardVM_v3();
    model.fetchData();

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isMobile =
            sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        final width = isMobile ? 350.fSize : 340.fSize;
        final height = 207.fSize;
        // final position = 25.height;
        final containerWidth = isMobile ? 370.fSize : 360.fSize;
        final containerHeight = 410.fSize;
        final smallcontainerWidth = isMobile ? 180.fSize : 90.width;
        final smallcontainerHeight = 35.fSize;
        //final arrowTop = 30.height;
        //final arrowLeft = isMobile ? 37.5.width : 27.5.width;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: containerWidth,
              height: containerHeight,
              margin: const EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3E51FF).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image at top
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: Image.asset(
                              'assets/images/${locationByMonth.first['location'].toString().toUpperCase()}.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: (containerHeight - smallcontainerHeight) / 2,
                        left: (containerWidth - smallcontainerWidth) / 2 - 15,
                        child: Container(
                          width: smallcontainerWidth + 31,
                          height: smallcontainerHeight,
                          padding: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/PropertiesGroup.png',
                                width: 17.fSize,
                                height: 17.fSize,
                              ),
                              SizedBox(width: 2.width),
                              Text(
                                '${locationByMonth.first['totalUnits'] ?? (locationByMonth.first['owners'] as List?)?.map((owner) => owner['unitNo']).toSet().length ?? 0} Total ',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Show occupancy rate using async widget
                              OccupancyText(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/Group.png',
                          width: 24.fSize,
                          height: 24.fSize,
                        ),
                        SizedBox(width: 2.width),
                        Text(
                          'Owner(s)',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: 13.fSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10.fSize),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var owner
                                    in locationByMonth.first['owners'] ??
                                        []) ...[
                                  // Main owner avatar
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Tooltip(
                                      message:
                                          owner['ownerName'] ?? 'Unknown Owner',
                                      child: CircleAvatar(
                                        radius: 13,
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          getInitials(owner['ownerName'] ?? ''),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Co-owner avatar if exists
                                  if (owner['coOwnerName'] != null &&
                                      owner['coOwnerName']
                                          .toString()
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Tooltip(
                                        message: owner['coOwnerName'],
                                        child: CircleAvatar(
                                          radius: 13,
                                          backgroundColor: Colors.green,
                                          child: Text(
                                            getInitials(owner['coOwnerName']),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 5),
                    child: Text(
                      locationByMonth.first['location'] ?? '',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(children: [
                      Image.asset('assets/images/map_pin.png',
                          width: 14.fSize, height: 17.fSize),
                      const SizedBox(width: 2),
                      Text(
                        '$locationRoad',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ]),
                  ),

                  //divider
                  Container(
                    height: 1,
                    color: Colors.grey,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 2),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Image.asset('assets/images/Wallet.png',
                                  width: 45.fSize, height: 45.fSize),
                            ),
                            const SizedBox(width: 2),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Net After POB',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  'RM ${locationByMonth.first['total']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ), //totalNetAfterPob
                              ],
                            ),
                            const Spacer(),
                            Container(
                              margin:
                                  const EdgeInsets.only(right: 10, bottom: 3),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            property_detail_v3(
                                                locationByMonth: [
                                              locationByMonth.first
                                            ]),
                                      ));
                                },
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                      const Size(20, 30)),
                                  side: WidgetStateProperty.all(
                                      const BorderSide(
                                          color: Color(0xFF4CAF50))),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Details',
                                      style: TextStyle(
                                          fontSize: 15.fSize,
                                          color: Colors.black),
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/arrow.png',
                                          width: 15.fSize,
                                          height: 11.fSize,
                                        ),
                                        Text(
                                          'Jom',
                                          style: TextStyle(fontSize: 9.fSize),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]))
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String getInitials(String name) {
  if (name.isEmpty) return '';

  List<String> words = name.split(' ');
  List<String> initials = words.map((word) => word[0].toUpperCase()).toList();

  return initials.join('');
}

class ViewAllProperty extends StatelessWidget {
  final NewDashboardVM_v3 model;
  const ViewAllProperty({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
