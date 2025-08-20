import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Newsletter/all_newsletter.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter_read_details.dart';
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
    // Do not fetch here to avoid repeated fetches and potential duplicates

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
        : Builder(builder: (context) {
            final screenHeight = MediaQuery.of(context).size.height;
            final isMobile = MediaQuery.of(context).size.width < 600;
            final sectionHeight =
                (isMobile ? screenHeight * 0.45 : screenHeight * 0.35) + 12.0;

            // Determine latest year in dataset
            final int latestYear = model.locationByMonth
                .map((p) => p['year'] as int)
                .reduce((a, b) => a > b ? a : b);

            // Filter by latest year and latest month
            final List<Map<String, dynamic>> filtered = model.locationByMonth
                .where((property) =>
                    property['year'] == latestYear &&
                    property['month'] == model.unitLatestMonth)
                .cast<Map<String, dynamic>>()
                .toList();

            // Deduplicate by location (normalized) so a location appears at most once
            final Set<String> seenLocations = <String>{};
            final List<Map<String, dynamic>> uniqueByLocation = [];
            for (final prop in filtered) {
              final String loc =
                  (prop['location'] ?? '').toString().trim().toUpperCase();
              if (seenLocations.add(loc)) {
                uniqueByLocation.add(prop);
              }
            }

            // Show only one newsletter card
            final List<Map<String, dynamic>> items =
                uniqueByLocation.take(1).toList();

            return SizedBox(
              height: sectionHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) =>
                      NewsletterImageStack(locationByMonth: [items[index]]),
                  separatorBuilder: (_, __) => const SizedBox(width: 40),
                  itemCount: items.length,
                ),
              ),
            );
          });
  }
}

class NewsletterImageStack extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;
  const NewsletterImageStack({required this.locationByMonth, Key? key})
      : super(key: key);

  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      final isMobile =
          sizingInformation.deviceScreenType == DeviceScreenType.mobile;
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      final containerWidth = isMobile ? screenWidth * 0.85 : screenWidth * 0.43;
      final containerHeight =
          isMobile ? screenHeight * 0.45 : screenHeight * 0.35;

      final imageWidth = containerWidth * 0.95;
      final imageHeight = containerHeight * 0.5;

      final smallcontainerWidth = isMobile ? 50.fSize : 40.fSize;
      final smallcontainerHeight = isMobile ? 65.fSize : 60.fSize;
      final horizontalPadding = screenWidth * 0.01;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(right: horizontalPadding),
            child: Container(
              width: containerWidth,
              height: containerHeight,
              margin: const EdgeInsets.only(left: 5),
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
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: imageWidth,
                            height: imageHeight,
                            child: Image.asset(
                              'assets/images/newsletter_image.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
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
                                      color: Colors.white,
                                      fontSize: 20.5.fSize)),
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
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

                  Stack(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
