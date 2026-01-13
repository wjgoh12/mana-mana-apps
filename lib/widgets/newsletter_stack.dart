import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';

// ignore: camel_case_types
class newsletterStack extends StatelessWidget {
  const newsletterStack(
      {super.key,
      required this.image,
      required this.text1,
      required this.text2});

  final String image;
  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ResponsiveBuilder(builder: (context, sizingInformation) {
          final isMobile =
              sizingInformation.deviceScreenType == DeviceScreenType.mobile;

          final width = isMobile ? 150.fSize : 140.fSize;
          final height = 150.fSize;
          final containerWidth = isMobile ? 400.fSize : 390.fSize;
          final containerHeight = isMobile ? 170.fSize : 240.fSize;
          final smallcontainerWidth = isMobile ? 50.fSize : 40.fSize;
          final smallcontainerHeight = isMobile ? 65.fSize : 60.fSize;

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
                      color: Color(0xFF3E51FF).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        Positioned(
                          left: 15,
                          bottom: 15,
                          child: Container(
                            width: smallcontainerWidth,
                            height: smallcontainerHeight,
                            decoration: const BoxDecoration(
                              color: Color(0XFF3E51FF),
                            ),
                            child: Column(children: [
                              Text(DateTime.now().day.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: AppDimens.fontSizeBig,
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
                                  color: Colors.white,
                                  fontSize: AppDimens.fontSizeSmall,
                                ),
                              )
                            ]),
                          ),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(children: [
                            Image.asset(
                              'assets/images/newsletter_icon.png',
                              width: 24.fSize,
                              height: 24.fSize,
                            ),
                            SizedBox(width: 2.fSize),
                            Text('Anis Shazwani',
                                style: TextStyle(fontSize: AppDimens.fontSizeBig
                          ]),
                        ),
                        const SizedBox(height: 2),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: 225.fSize, maxHeight: 50.fSize),
                          child: const Text(
                            'Scarletz Suites: Your Chic Urban Stay in the Heart of Kuala Lumpur with a Touch of Luxury',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: AppDimens.fontSizeSmall,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 220.fSize,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      'Read More',
                                      style: TextStyle(
                                        fontSize: AppDimens.fontSizeSmall,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/arrow.png',
                                          width: 15.fSize,
                                          height: 9.fSize,
                                        ),
                                        Text(
                                          'Jom',
                                          style: TextStyle(
                                            fontSize: AppDimens.fontSizeSmall,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 0.5,
                          width: 215.fSize,
                          color: Colors.grey,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('60 Views',
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeSmall,
                                  )),
                              SizedBox(width: 2.fSize),
                              const Text(
                                '10 Comments',
                                style: TextStyle(
                                  fontSize: AppDimens.fontSizeSmall,
                                ),
                              ),
                              SizedBox(width: 2.fSize),
                              PostLike(),
                            ]),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        }),
      ],
    );
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
      size: 15.0,
      likeCount: _likeCount,
      likeCountPadding: const EdgeInsets.only(left: 4),
      likeBuilder: (liked) => Icon(Icons.favorite,
          color: liked ? Colors.red : Colors.grey, size: 15),
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
