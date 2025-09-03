import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/occupancy_text.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PropertyListV3 extends StatelessWidget {
  final ScrollController controller;
  final NewDashboardVM_v3 model;
  PropertyListV3({required this.model, required this.controller, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('total assets: ${model.locationByMonth.length}');
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

    List<Map<String, dynamic>> sequencedProperties =
        _getPropertiesSequencedByLatestTransactions();
    return sequencedProperties.isEmpty
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
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: _computeSectionHeight(context) + 20,
            ),
            // Match the section height to the actual card height to avoid extra gap

            child: Align(
              alignment: Alignment.centerLeft,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    //   ...model.locationByMonth
                    //       .where((property) => property['year'] == latestYear)
                    //       .toList()
                    //     ..sort((a, b) =>
                    //         (b['month'] as int).compareTo(a['month'] as int))
                    // ]
                    //     .expand((property) => [
                    //           PropertyImageStack(locationByMonth: [property]),
                    //           const SizedBox(width: 20),
                    //         ])
                    //     .toList(),
                    // ViewAllProperty(model: model),
                    ...sequencedProperties.map((property) => PropertyImageStack(
                          locationByMonth: [property],
                          model: model,
                        )),
                  ]),
            ),
            // ),
          );
  }

  double _computeSectionHeight(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double screenHeight = MediaQuery.of(context).size.height;
    // Keep in sync with PropertyImageStack's containerHeight formula
    final double containerHeight =
        isMobile ? screenHeight * 0.42 : screenHeight * 0.35;
    // Add a small breathing space to prevent clipping
    return containerHeight;
  }

  int get latestYear => model.locationByMonth
      .map((p) => p['year'] as int)
      .reduce((a, b) => a > b ? a : b);

  int get latestMonth => model.locationByMonth
      .where((e) => e['year'] == latestYear)
      .map((e) => e['month'] as int)
      .reduce((a, b) => a > b ? a : b);

  /// Get all properties belonging to the owner, sequenced by latest transactions (left to right)
  List<Map<String, dynamic>> _getPropertiesSequencedByLatestTransactions() {
    if (model.locationByMonth.isEmpty) {
      return [];
    }

    final Map<String, List<Map<String, dynamic>>> propertiesByLocation = {};

    for (final property in model.locationByMonth) {
      final location = property['location'];
      if (!propertiesByLocation.containsKey(location)) {
        propertiesByLocation[location] = [];
      }
      propertiesByLocation[location]!.add(property);
    }

    final Map<String, Map<String, dynamic>> latestTransactionByLocation = {};

    propertiesByLocation.forEach((location, properties) {
      properties.sort((a, b) {
        final aDate = a['year'] * 100 + a['month'];
        final bDate = b['year'] * 100 + b['month'];
        return bDate.compareTo(aDate);
      });

      latestTransactionByLocation[location] = properties.first;
    });

    final List<Map<String, dynamic>> sequencedProperties =
        latestTransactionByLocation.values.toList();

    sequencedProperties.sort((a, b) {
      final aDate = a['year'] * 100 + a['month'];
      final bDate = b['year'] * 100 + b['month'];
      return bDate.compareTo(aDate); // Latest first (left to right)
    });

    return sequencedProperties;
  }
}

class PropertyImageStack extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;
  final NewDashboardVM_v3 model;

  const PropertyImageStack({
    Key? key,
    required this.locationByMonth,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Set<String> uniqueOwners = {};
    for (var owner in locationByMonth.first['owners'] ?? []) {
      if (owner['ownerName'] != null &&
          owner['ownerName'].toString().isNotEmpty) {
        uniqueOwners.add(owner['ownerName']);
      }
      if (owner['coOwnerName'] != null &&
          owner['coOwnerName'].toString().isNotEmpty) {
        uniqueOwners.add(owner['coOwnerName']);
      }
    }
    final location = locationByMonth.first['location'] ?? '';
    final totalUnits = model.ownerUnits
        .where((unit) => unit.location == location)
        .map((unit) => unit.unitno)
        .toSet()
        .length;

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
    print(
        '${model.ownerUnits.where((unit) => unit.location == location).map((unit) => unit.unitno).toSet()}');

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isMobile =
            sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final containerWidth =
            isMobile ? screenWidth * 0.87 : screenWidth * 0.43;
        final containerHeight =
            isMobile ? screenHeight * 0.4 : screenHeight * 0.35;

        final imageWidth = containerWidth * 0.95;
        final imageHeight = containerHeight * 0.48;

        final smallContainerWidth = containerWidth * 0.45;
        final smallContainerHeight = containerHeight * 0.08;
        final horizontalPadding = containerWidth * 0.035;

        ResponsiveSize.init(context);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(right: horizontalPadding),
              child: Container(
                width: containerWidth,
                // height: containerHeight,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image at top
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: imageWidth,
                              height: imageHeight,
                              child: Image.asset(
                                'assets/images/${locationByMonth.first['location'].toString().toUpperCase()}.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 3,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              // width: smallContainerWidth + containerWidth * 0.1,
                              height: smallContainerHeight,
                              margin: EdgeInsets.only(
                                  bottom: containerHeight * 0.01),
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/PropertiesGroup.png',
                                    width: ResponsiveSize.scaleWidth(20),
                                    height: ResponsiveSize.scaleHeight(20),
                                  ),
                                  SizedBox(width: 2.width),
                                  Text(
                                    '$totalUnits Total ',
                                    style: TextStyle(
                                      fontFamily: 'outfit',
                                      fontSize: ResponsiveSize.text(13),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Show occupancy rate using async widget
                                  FutureBuilder<String>(
                                    future: model
                                        .calculateTotalOccupancyForLocation(
                                            model.locationByMonth
                                                .first['location']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text('Loading...',
                                            style: TextStyle(
                                                fontFamily: 'outfit',
                                                fontSize:
                                                    ResponsiveSize.text(13)));
                                      }
                                      if (snapshot.hasError) {
                                        return const Text('Error');
                                      }
                                      final occupancy = snapshot.data ?? '0.0';
                                      return Text('($occupancy% Occupancy)',
                                          style: TextStyle(
                                              fontFamily: 'outfit',
                                              fontWeight: FontWeight.w300,
                                              fontSize:
                                                  ResponsiveSize.text(13)));
                                    },
                                  )
                                ],
                              ),
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
                            width: ResponsiveSize.scaleWidth(25),
                            height: ResponsiveSize.scaleHeight(25),
                          ),
                          SizedBox(width: ResponsiveSize.scaleWidth(2)),
                          Text(
                            'Owner(s)',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: ResponsiveSize.text(15),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff383838),
                            ),
                          ),
                          SizedBox(width: ResponsiveSize.scaleWidth(10)),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...uniqueOwners
                                      .map((ownerName) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: Tooltip(
                                              message: ownerName,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: locationByMonth
                                                          .first['owners']
                                                          .any((o) =>
                                                              o['ownerName'] ==
                                                              ownerName)
                                                      ? const Color(
                                                          0xff5092FF) // Main owner color
                                                      : const Color(
                                                          0xFF4CAF50), // Co-owner color
                                                  child: Text(
                                                    getInitials(ownerName),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
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
                        style: TextStyle(
                          fontFamily: 'outfit',
                          fontSize: ResponsiveSize.text(21),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      child: Row(
                        children: [
                          Image.asset('assets/images/map_pin.png',
                              width: 16, height: 19),
                          const SizedBox(width: 10),
                          Text(
                            locationRoad,
                            style: TextStyle(
                              fontFamily: 'outfit',
                              fontSize: ResponsiveSize.text(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFB82B7D),
                            Color(0xFF3E51FF),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Image.asset('assets/images/Wallet.png',
                                width: ResponsiveSize.scaleWidth(44.5),
                                height: ResponsiveSize.scaleHeight(44.5)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Net After POB',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: ResponsiveSize.text(13),
                                ),
                              ),
                              Text(
                                'RM ${locationByMonth.first['total']}',
                                style: TextStyle(
                                  fontSize: ResponsiveSize.text(15),
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.only(right: 10, bottom: 3),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => property_detail_v3(
                                        locationByMonth: [
                                          locationByMonth.first
                                        ],
                                        initialTab: 'overview',
                                        model: NewDashboardVM_v3(),
                                      ),
                                    ));
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
                                        fontSize: ResponsiveSize.text(12),
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/arrow.png',
                                        width: 16,
                                        height: 12,
                                      ),
                                      Text(
                                        'Jom',
                                        style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 12.fSize,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
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
