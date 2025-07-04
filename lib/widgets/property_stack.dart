import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';


class PropertyStack extends StatelessWidget {
  
  
  const PropertyStack
  ({
    super.key,
    required this.image,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.total,
    });
  
  final String image;
  final String text1;
  final String text2;
  final String text3;
  final double total;
  // final double width;
  // final double height;

  
  @override
  Widget build(BuildContext context) {
    final NewDashboardVM model=NewDashboardVM();
    model.fetchData();

    //  if (model.isLoading) {
    //       return Container(
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //         padding: const EdgeInsets.all(16),
    //         child: const Center(
    //           child: CircularProgressIndicator(), 
    //         ),
    //       );
    //     }

        // if(model.locationByMonth.isEmpty) {
        //   return Container(
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //         padding: const EdgeInsets.all(16),
        //         child: const Center(
        //           child: Text('No properties available'),
        //         ),
        //       );
        // } 
        // else{
              return ResponsiveBuilder(
     builder: (context, sizingInformation) {
      final isMobile =
            sizingInformation.deviceScreenType == DeviceScreenType.mobile;
      final width = isMobile ? 350.fSize : 340.fSize;
        final height = 207.fSize;
       // final position = 25.height;
        final containerWidth = isMobile ? 370.fSize : 360.fSize;
        final containerHeight = 405.fSize;
        final smallcontainerWidth = isMobile? 320.fSize:90.width;
        final smallcontainerHeight = 35.fSize;
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
                      'assets/images/${
                        image.toString().toUpperCase()}.png',
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
                          'assets/images/map_pin.png',
                           width: 17.fSize, 
                           height: 17.fSize
                           ),
                           Text(text2,
                           style:const TextStyle(
                            fontSize: 9),
                            ),
                            SizedBox
                            (
                              width: 1.width,
                              height: 30.fSize,
                            ),
                            const VerticalDivider(
                              color: Colors.grey,
                              thickness: 1,

                            ),

                        Image.asset(
                          'assets/images/PropertiesGroup.png',
                          width: 17.fSize,
                          height: 17.fSize,
                        ),
                        SizedBox(width: 2.width),
                        Text(
                          '${text3.toString()} Total'
                          ,style:const TextStyle(
                            fontSize: 9),
                          ),
                      ],

                    ),
                  ),
                ),
              ],
            ),

            // Group icon and text
            Padding(
              padding: const EdgeInsets.only(left:10, top: 10),
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
              padding: const EdgeInsets.only(left: 12, top: 5),
              child: Text(
                text1.toString() ?? '',
                style: const TextStyle(
                  fontFamily: 'Open Sans',
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
            margin: const EdgeInsets.only(left:10, right: 10),
           ),
            Padding(
              padding:const EdgeInsets.only(left:10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:1),
                    child: Image.asset('assets/images/Wallet.png', width: 45.fSize, height: 45.fSize),
                  ),

                  const SizedBox(width: 5),
                   Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Net After POB',
                    style: TextStyle(fontSize:11,
                    ),
                    ),
                    Text('RM$total',
                    style: const TextStyle(
                      fontSize:15,
                      fontWeight: FontWeight.bold,
                    ),
                    ),//totalNetAfterPob
                  ],
                ),
                const Spacer(),
                //after pressed button, it will navigate to property detail page
                Container(
                  margin: const EdgeInsets.only(right: 10,bottom:8, top:10),
                   child: TextButton(
                    
                      onPressed: (){
                         Navigator.push(context,
                         MaterialPageRoute(builder: (context) => PropertyDetail(locationByMonth: model.locationByMonth),
                         ));
                      },
                      style:ButtonStyle(
                        minimumSize: WidgetStateProperty.all(const Size(20,30)),
                        side: WidgetStateProperty.all(const BorderSide(color: Color(0xFF4CAF50))),
                      ),
                      child: Row(
                        
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         Text(
                           'Details',
                           style: TextStyle(
                            fontSize: 15.fSize,
                            color: Colors.black
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
              ]
            )
          )
          ],
        ),
          )
          
        ],
        
         );
     }
   );
              }
  }
// }




// children: [
//       Align(
//         alignment: Alignment.center,
//         child: Container(
//           width: width,
//           height: height,
//           clipBehavior: Clip.hardEdge,
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//           child: ColorFiltered(
//           colorFilter: ColorFilter.mode(
//             Color(0xFF4313E9).withOpacity(0.2), // Adjust opacity as needed            
//             BlendMode.srcOver,
//           ),
//           child: Image.asset(
//             'assets/images/${image.toUpperCase()}2.png',
//             fit: BoxFit.cover,
//           ),
//           ),
//         ),
//       ),
//       Center(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 2.height,
//             ),
//             Text(
//               '$text1',
//               style: TextStyle(
//                   color: const Color(0XFFFFFFFF),
//                   fontFamily: 'Open Sans',
//                   fontWeight: FontWeight.w800,
//                   shadows: [
//                     Shadow(
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                         color: const Color(0XFF120051).withOpacity(0.75))
//                   ],
//                   fontSize: 30.fSize),
//             ),
//             const SizedBox(
//               height: 5,
//             ),
//             Text(
//               '$text2',
//               style: TextStyle(
//                   color: const Color(0XFFFFFFFF),
//                   fontFamily: 'Open Sans',
//                   fontStyle: FontStyle.italic,
//                   fontWeight: FontWeight.w600,
//                   shadows: [
//                     Shadow(
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                         color: const Color(0XFF120051).withOpacity(0.75))
//                   ],
//                   fontSize: 15.fSize),
//             ),
//             // const SizedBox(
//             //   height: 10,
//             // ),
//             // const TypeDropdownButton()
//           ],
//         ),
//       ),
//     ],