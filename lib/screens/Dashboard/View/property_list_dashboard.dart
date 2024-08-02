import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/personal_millerz_square.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';

class BuildPropertyList extends StatelessWidget {
  const BuildPropertyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          PropertyImageStack(
            image: 'Millerz_square2',
            label: 'MILLERZ SQUARE',
            location: '@ Old Klang Road',
            amount: '3,300.00',
            onTap: 'MILLERZ SQUARE'
          ),
          SizedBox(width: 5),
          PropertyImageStack(
            image: 'expression_suites_property',
            label: 'EXPRESSIONZ SUITES',
            location: '@ Jalan Tun Razak',
            amount: '2,045.19',
            onTap: ''
          ),
          SizedBox(width: 5),
          PropertyImageStack(
            image: 'ceylonz_suites',
            label: 'CEYLONZ SUITES',
            location: '@ Bukit Ceylon',
            amount: '5,400.00',
            onTap: ''
          ),
          SizedBox(width: 5),
          ViewAllProperty(),
        ],
      ),
    );
  }
}

class PropertyImageStack extends StatelessWidget {
  const PropertyImageStack({
    Key? key,
    required this.image,
    required this.label,
    required this.location,
    required this.amount,
    required this.onTap,
  }) : super(key: key);

  final String image;
  final String label;
  final String location;
  final String amount;
  final String onTap;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
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
                'assets/images/$image.png',
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
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 2.height, left: 2.width),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 20.fSize,
                          color: const Color(0XFF4313E9),
                        ),
                      ),
                      Text(
                        location,
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
                            amount,
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
                        'Total Owner Profit Of The Month',
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
                  if (onTap == 'MILLERZ SQUARE'){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalMillerzSquare1Screen()));
                  }else{
                    print('onTap == ''');
                  }
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => MillerzSquare1Screen()));
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