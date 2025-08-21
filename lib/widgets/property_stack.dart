import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:mana_mana_app/widgets/occupancy_text.dart';

class PropertyStack extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;
  const PropertyStack({
    super.key,
    required this.locationByMonth,
  });

  String getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> words = name.split(' ');
    List<String> initials = words.map((word) => word[0].toUpperCase()).toList();
    return initials.join('');
  }

  @override
  Widget build(BuildContext context) {
    print('locationByMonth length: ${locationByMonth.length}');
    print('First item keys: ${locationByMonth.first.keys}');
    print('First item: ${locationByMonth.first}');

    if (locationByMonth.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
    //final NewDashboardVM_v3 model = NewDashboardVM_v3();
    //model.fetchData();

    return ResponsiveBuilder(builder: (context, sizingInformation) {
      final isMobile =
          sizingInformation.deviceScreenType == DeviceScreenType.mobile;
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      double responsiveWidth(double value) =>
          (value / 375.0) * screenWidth; // base width
      double responsiveHeight(double value) =>
          (value / 812.0) * screenHeight; // base height
      double responsiveFont(double value) =>
          (value / 812.0) * screenHeight; // font scaling

      final containerWidth = isMobile ? screenWidth * 0.9 : screenWidth * 0.5;
      final containerHeight =
          isMobile ? screenHeight * 0.4 : screenHeight * 0.45;

      final imageWidth = containerWidth * 0.95;
      final imageHeight = containerHeight * 0.45;

      final smallContainerWidth = containerWidth * 0.45;
      final smallContainerHeight = containerHeight * 0.08;

      final horizontalPadding = isMobile ? 16.0 : 40.0;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: containerWidth,
            height: containerHeight,
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF3E51FF).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: imageWidth,
                          height: imageHeight,
                          child: Image.asset(
                            'assets/images/${(locationByMonth.first['location'] ?? '').toString().toUpperCase()}.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.02,
                      // left: (containerWidth - smallContainerWidth) / 2 -
                      //     smallContainerWidth * 0.25,
                      child: Container(
                        width: responsiveWidth(
                            smallContainerWidth + containerWidth * 0.2),
                        height: smallContainerHeight,
                        margin: EdgeInsets.only(bottom: containerHeight * 0.02),
                        // padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/map_pin.png',
                                width: 15.fSize, height: 15.fSize),
                            Text(
                              '$locationRoad',
                              style: TextStyle(fontSize: responsiveFont(8)),
                            ),
                            SizedBox(
                              width: 1.width,
                              height: 30.fSize,
                            ),
                            const VerticalDivider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                            Image.asset(
                              'assets/images/PropertiesGroup.png',
                              width: 15.fSize,
                              height: 15.fSize,
                            ),
                            SizedBox(width: 1.fSize),
                            Text(
                              '${locationByMonth.first['totalUnits'] ?? (locationByMonth.first['owners'] as List?)?.map((owner) => owner['unitNo']).toSet().length ?? 0} Total ',
                              style: TextStyle(fontSize: responsiveFont(8)),
                            ),
                            OccupancyText(
                                location: locationByMonth.first['location'],
                                unitNo: locationByMonth.first['unitNo'],
                                showTotal: true),
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
                        width: responsiveWidth(24),
                        height: responsiveHeight(24),
                      ),
                      SizedBox(width: 2.width),
                      Text(
                        'Owner(s)',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: responsiveFont(13),
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
                                  in locationByMonth.first['owners'] ?? []) ...[
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsiveFont(12),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Co-owner avatar if exists
                                if (owner['coOwnerName'] != null &&
                                    owner['coOwnerName'].toString().isNotEmpty)
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

                SizedBox(height: 2.height),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    locationByMonth.first['location'] ?? '',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                //divider
                Container(
                  height: 1,
                  color: Colors.grey,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          children: [
                            Image.asset('assets/images/Wallet.png',
                                width: 45.fSize, height: 45.fSize),
                            const SizedBox(width: 2),
                            SizedBox(
                              child: Column(
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
                                    'RM ${locationByMonth.first['total'] ?? 0.0}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      //SizedBox(width: 25.width),
                      //after pressed button, it will navigate to property detail page
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => property_detail_v3(
                                locationByMonth: [locationByMonth.first],
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          minimumSize:
                              WidgetStateProperty.all(const Size(20, 30)),
                          side: WidgetStateProperty.all(
                              const BorderSide(color: Color(0xFF4CAF50))),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                  fontSize: 15.fSize, color: Colors.black),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              child: Column(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}
