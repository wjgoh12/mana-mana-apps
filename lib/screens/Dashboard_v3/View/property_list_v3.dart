import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PropertyListV3 extends StatelessWidget {
  final NewDashboardVM model;
  const PropertyListV3({required this.model, Key? key}) : super(key: key);

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
        ViewAllProperty(model: model),
      ],
    ),
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
        final width = isMobile ? 350.fSize : 340.fSize;
        final height = 207.fSize;
        final position = 25.height;
        final containerWidth = isMobile ? 370.fSize : 360.fSize;
        final containerHeight = 405.fSize;
        final smallcontainerWidth = isMobile? 180.fSize:90.width;
        final smallcontainerHeight = 35.fSize;
        //final arrowTop = 30.height;
        //final arrowLeft = isMobile ? 37.5.width : 27.5.width;

        return Stack(
  clipBehavior: Clip.none,
  children: [
    GestureDetector(
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
        margin: const EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
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

    // Overlay small label on pic
    Positioned(
      top: (containerHeight-smallcontainerHeight)/2 ,
      left: (containerWidth-smallcontainerWidth)/2,
      
      child: Container(
        
        width: smallcontainerWidth,
        height: smallcontainerHeight,
        padding: const EdgeInsets.only(left:10),
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
            Text('${locationByMonth.length} Total'),
          ],
        ),
      ),
    ),
  ],
),


            // Group icon and text
            Padding(
              padding: EdgeInsets.only(left:10, top: 15),
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
                      fontSize: 15.fSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(
                locationByMonth.first['location'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    ),

    // Overlayed image (if necessary)
    Positioned(
      top: 5,
      left: 5,
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
        // child: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(6),
        //     child: SizedBox(
        //       width: width,
        //       height: height,
        //       child: Image.asset(
        //         'assets/images/${locationByMonth.first['location'].toUpperCase()}.png',
        //         fit: BoxFit.cover,
        //       ),
        //     ),
        //   ),
        // ),
      ),
    ),

    // Placeholder or optional overlay
    Positioned(
      top: position,
      left: 0,
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
        child: Container(), // Empty or add additional info
      ),
    ),
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
            MaterialPageRoute(builder: (context) => AllPropertyScreen(locationByMonth: model.locationByMonth)));
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
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(
        //       'VIEW ALL',
        //       style: TextStyle(
        //         fontFamily: 'Open Sans',
        //         fontWeight: FontWeight.w700,
        //         fontSize: 20.fSize,
        //         color: const Color(0XFF4313E9),
        //       ),
        //     ),
        //     Text(
        //       '@ Your Properties',
        //       style: TextStyle(
        //         fontFamily: 'Open Sans',
        //         fontWeight: FontWeight.w300,
        //         fontSize: 10.fSize,
        //         fontStyle: FontStyle.italic,
        //         color: const Color(0XFF4313E9),
        //       ),
        //     ),
        //     SizedBox(height: 2.height),
        //     Container(
        //       width: 7.width,
        //       height: 7.width,
        //       decoration: const BoxDecoration(color: Color(0XFF4313E9)),
        //       child: const Icon(
        //         Icons.keyboard_arrow_right_rounded,
        //         color: Colors.white,
        //       ),
        //     )
        //   ],
        // ),
      ),
    );
  }
}
