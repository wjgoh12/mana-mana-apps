import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/Dashboard/ViewModel/dashboardVM.dart';
import 'package:mana_mana_app/screens/personal_millerz_square.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';

class BuildPropertyList extends StatelessWidget {
  const BuildPropertyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DashboardVM model = DashboardVM();
    model.locationByMonth = [];
    

    return ListenableBuilder(
  listenable: DashboardVM(),
  builder: (context, _) {
    if (model.isLoading) { // Check if data is still loading
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
                    .where((property) => property['year'] == DateTime.now().year && property['month'] == model.unitLatestMonth)
                    .expand((property) => [
                          PropertyImageStack(
                            locationByMonth: [property],
                          ),
                          const SizedBox(width: 8),
                        ])
                    .toList(),
                const SizedBox(width: 5),
                const ViewAllProperty(),
              ],
            ),
          );
  },
);
  }
}

class PropertyImageStack extends StatelessWidget {
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
  
  List<Map<String, dynamic>> locationByMonth;

  @override
  Widget build(BuildContext context) {
    print(locationByMonth.first['total']);
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
            SizedBox(
              width: width,
              height: height,
              child: Image.asset(
                'assets/images/${locationByMonth.first['location']}.png',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: position,
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
                  borderRadius:
                      const BorderRadius.only(bottomLeft: Radius.circular(10)),
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
                        locationByMonth.first['location'] ?? '',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w300,
                          fontSize: 10.fSize,
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
                            locationByMonth.first['total'].toString(),
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
                        'Total Owner Balance Of The Month',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 8.fSize,
                          color: const Color(0XFF4313E9),
                        ),
                      ),
                    ],
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
                      builder: (context) => PersonalMillerzSquare1Screen(
                          locationByMonth
                          ),
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
  const ViewAllProperty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MillerzSquare1Screen()));
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
              '@ Your Property(s)',
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
