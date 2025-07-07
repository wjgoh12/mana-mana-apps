import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter_read_details.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';


class newsletterStack extends StatelessWidget {
  const newsletterStack({super.key,required this.image,required this.text1,required this.text2});
  
  final String image;
  final String text1;
  final String text2;
  // final double width;
  // final double height;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Stack(
    children: [
      ResponsiveBuilder(
     builder: (context, sizingInformation) {
      final isMobile =
            sizingInformation.deviceScreenType == DeviceScreenType.mobile;
      final width = isMobile ? 150.fSize : 140.fSize;
        final height = 150.fSize;
       // final position = 25.height;
        final containerWidth = isMobile ? 400.fSize : 390.fSize;
        final containerHeight = 170.fSize;
        final smallcontainerWidth = isMobile? 40.fSize: 30.width;
        final smallcontainerHeight = 50.fSize;
         final Map<String,int> locationByMonth = {};
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
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
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

              Positioned(
                left:20,
                bottom:20,
                child:Container(
                  width: smallcontainerWidth,
                  height: smallcontainerHeight,
                  decoration: const BoxDecoration(
                    color: Color(0XFF3E51FF),
                  ),
                  child: Column(
                    children: [
                      Text(DateTime.now().day.toString(),
                      style:TextStyle(
                        color: Colors.white,
                        fontSize: 23.fSize
                      )
                      ),
                     Text(
                        [
                          'January', 'February', 'March', 'April', 'May', 'June',
                          'July', 'August', 'September', 'October', 'November', 'December'
                        ][DateTime.now().month - 1],
                      style:TextStyle(
                        color: Colors.white,
                        fontSize: 11.fSize,
                        ),
                      )
                    ]
                         ),
                ),
                
                 )

              
              ],
            ),
            Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Padding(
                  padding: const EdgeInsets.only(top:10 ),
                  child: Row(

                   children:[
                    Image.asset(
                    'assets/images/newsletter_icon.png',
                        width: 24.fSize,
                        height: 24.fSize,
                     ),
                     SizedBox(width: 2.fSize),
                     Text('Anis Shazwani',
                     style:TextStyle(
                      fontSize: 14.fSize
                     )
                     )
                   ]
                  ),
                ),
                const SizedBox(height: 2),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 225.fSize, maxHeight: 50.fSize),
                  child: const Text(
                    'Scarletz Suites: Your Chic Urban Stay in the Heart of Kuala Lump...',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                 ),
                ),


                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (){}, 
                    child: Row(
                      mainAxisAlignment:  MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Read More',
                        style: TextStyle(
                          fontSize: 15.fSize,
                        ),
                        ),
                        
                         const SizedBox(width: 5),
                         Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Image.asset(
                              'assets/images/arrow.png',
                              width:15.fSize,
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
                //divider
                Container(
                  height: 1,
                  width:215.fSize,
                  color: Colors.grey,
                ),

             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '60 Views',
                    style: TextStyle(
                      fontSize: 15,
                    )
                  ),
                  SizedBox(width: 5.fSize),
                  
                  const Text(
                    '10 Comments',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  ),
                  SizedBox(width: 5.fSize),
                  //like button
                  PostLike(),
                ]
              ),
                  


              ],
            )
          ],
        ),
          )
          
        ],
        
         );
     }
   ),
      
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
      size: 20.0,
      likeCount: _likeCount,
      likeCountPadding: const EdgeInsets.only(left: 4),
      likeBuilder: (liked) => Icon(
        Icons.favorite, 
        color: liked ? Colors.red : Colors.grey, 
        size: 20
        ),
      countBuilder: (count, liked, text) => 
      Text(
        text, 
        style: TextStyle(color: liked ? Colors.red : Colors.grey)
        ),
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
