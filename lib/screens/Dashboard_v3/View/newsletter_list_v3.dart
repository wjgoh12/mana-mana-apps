import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Newsletter/all_newsletter.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter_read_details.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:like_button/like_button.dart';

class NewsletterListV3 extends StatelessWidget {
  final NewDashboardVM_v3 model;
  final ScrollController controller;
  const NewsletterListV3(
      {required this.model, required this.controller, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const AllNewsletter allNewsletter = AllNewsletter();
    model.fetchData();

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
                    notif.metrics.axis == Axis.horizontal) {}
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
                            NewsletterImageStack(
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

class NewsletterImageStack extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;
  const NewsletterImageStack({required this.locationByMonth, Key? key})
      : super(key: key);

  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final isMobile =
          sizingInformation.deviceScreenType == DeviceScreenType.mobile;
      final width = isMobile ? 350.fSize : 340.fSize;
      final height = 207.fSize;
      // final position = 25.height;
      final containerWidth = isMobile ? screenWidth * 0.85 : screenWidth * 0.43;
      final containerHeight =
          isMobile ? screenHeight * 0.4 : screenHeight * 0.55;
      final smallcontainerWidth = isMobile ? 50.fSize : 40.fSize;
      final smallcontainerHeight = 60.fSize;
      final horizontalPadding = screenWidth * 0.05;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: containerWidth,
            height: containerHeight,
            //margin: const EdgeInsets.only(left: 5),
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
                            'assets/images/newsletter_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    //date container
                    Positioned(
                        left: 20,
                        bottom: 20,
                        child: Container(
                          width: smallcontainerWidth,
                          height: smallcontainerHeight,
                          decoration: const BoxDecoration(
                            color: Color(0XFF3E51FF),
                          ),
                          child: Column(children: [
                            Text(DateTime.now().day.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.5.fSize)),
                            Text(
                              [
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
                              ][DateTime.now().month - 1],
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11.fSize),
                            )
                          ]),
                        ))
                  ],
                ),

                // Group icon and text
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 2),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/newsletter_icon.png',
                        width: 24.fSize,
                        height: 24.fSize,
                      ),
                      SizedBox(width: 2.width),
                      Text(
                        'Anis Shazwani',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 13.fSize,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Scarletz Suites: Your Chic Urban Stay in the Heart of Kuala Lumpur',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                  ),
                ),

                Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('60 Views',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              )),

                          const Text(
                            '10 Comments',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),

                          //like button
                          PostLike(),

                          //after pressed button, it will navigate to property detail page
                          Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NewsletterReadDetails(),
                                    ));
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Read More',
                                    style: TextStyle(
                                        fontSize: 12.fSize,
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
          )
        ],
      );
    });
  }
}

class PostLike extends StatefulWidget {
  @override
  _PostLikeState createState() => _PostLikeState();
}

class _PostLikeState extends State<PostLike> {
  bool isLiked = false;
  int _likeCount = 0;

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      size: 18.0,
      likeCount: _likeCount,
      likeCountPadding: const EdgeInsets.only(left: 4),
      likeBuilder: (liked) => Icon(Icons.favorite,
          color: liked ? Colors.red : Colors.grey, size: 20),
      countBuilder: (count, liked, text) =>
          Text(text, style: TextStyle(color: liked ? Colors.red : Colors.grey)),
      onTap: (liked) async {
        setState(() {
          isLiked = !liked;
          _likeCount += isLiked ? 1 : -1;
        });
        return isLiked;
      },
    );
  }
}
