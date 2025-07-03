import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/property_list_v3.dart';
import 'package:mana_mana_app/screens/New_Dashboard/View/revenue_dashboard.dart';
import 'package:mana_mana_app/screens/New_Dashboard/View/statistic_table.dart';
import 'package:mana_mana_app/screens/New_Dashboard/View/user_info.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';
import 'package:mana_mana_app/widgets/overview_card.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';

class NewDashboardV3 extends StatelessWidget {
  const NewDashboardV3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) {
      final model = NewDashboardVM();
      model.fetchData();
      return model;
    },
    child: Consumer<NewDashboardVM>(
      builder: (context, model, child) {

    final ScrollController scrollController = ScrollController();
    //tracks the scroll position of the scroll view,check how far the user scrolled
    final ValueNotifier<bool> showDashboardTitle = ValueNotifier<bool>(false);
    
    scrollController.addListener(() {
      if (scrollController.offset > 100) { // Change threshold as needed
        showDashboardTitle.value = true;
      } else {
        showDashboardTitle.value = false;
      }
    });

    return ListenableBuilder(
        listenable: model,
        builder: (context, child) {
          
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.light,
  ),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                
                clipBehavior: Clip.none,
                children: [
                  _buildBackgroundContainer(),
                  ValueListenableBuilder<bool>(
                    valueListenable: showDashboardTitle,
                    builder: (context, showTitle, child) {
                      return Column(
      children: [
        if (showTitle)
          AppBar(
            automaticallyImplyLeading: false,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            title: Center(
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 18.fSize,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          )else
          topBar(context,(){}), // <- custom widget outside AppBar
      ],
    );
                    },
                  ),
                  Positioned(
                          top: 10.height,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              if (scrollNotification
                                  is ScrollUpdateNotification) {
                                // Update scroll position
                                if (scrollNotification.metrics.pixels > 100) {
                                  showDashboardTitle.value = true;
                                } else {
                                  showDashboardTitle.value = false;
                                }
                              }
                              return true;
                            },
                            child: ClipRRect(
                              // borderRadius: 
                              // const BorderRadius.vertical(
                              //     top: Radius.circular(20)),
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  await model.refreshData();
                                },
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100.width,
                                        padding: EdgeInsets.all(7.width),
                                        decoration: const BoxDecoration(
                                          color:Color(0xFFFFFFFF),
                                          //  borderRadius: BorderRadius.vertical(
                                          //     top: Radius.circular(20)),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                                mainAxisAlignment:MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Hey, ${model.userNameAccount}👋',
                                                  style: TextStyle(
                                                    fontSize: 16.fSize,
                                                    fontFamily: 'Open Sans',
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                  ),
                                                ]
                                            ),
                                            SizedBox(height: 2.height),
                                             Row(
                                               children: [
                                                 ShaderMask(
                                                  shaderCallback: (bounds)=>
                                                  const LinearGradient(
                                                    colors: 
                                                    [Color(0xFFB82B7D),Color.fromRGBO(62, 81, 255, 1)],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    ).createShader(bounds),
                                                    child: Text(
                                                      'Simple, Timeless \nAssets Management',
                                                      style: TextStyle(
                                                        fontSize: 33.fSize,
                                                        fontFamily: 'Open Sans',
                                                        fontWeight: FontWeight.w900,
                                                        color: const Color(0xFFFFFFFF),
                                                       ),
                                                     ),
                                                 ),
                                               ],
                                             ),
                                             SizedBox(height: 4.height),
                            //search bar
                           TextField(
                                decoration: InputDecoration(
                                prefixIcon: SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset('assets/images/searchIcon.png'),
                              ),
                                hintText: 'Search Your Properties',
                                hintStyle: TextStyle(
                                  fontSize: 15.fSize,
                                ),
                                //put settings button image at the end of the text field
                                suffixIcon: IconButton(
                                  icon: Image.asset(
                                    'assets/images/Settingsbutton.png',
                                  width: 20,
                                  height: 20,
                                  ),
                                  onPressed: () {
                                    
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0XFFD9D9D9), 
                                    width: 1.5,
                                    ),
                                ),
                              ),
                            ),
            
                            SizedBox(height: 2.height),
                            
                            Row(
                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: [
                                  _buildSectionTitle('Overview'),
                                  _seeAllButton(//onPressed: (){
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(builder: (context) => ),
                                  //   );
                                  // }
                                    
                                  ),
            
                              ],
                              
                            ),
                                                    //overview card widgets here
                             const OverviewCard(),
                            
            
                            //SizedBox(height: 2.height),
                            Row(
                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionTitle('Your Properties'),
                                _seeAllButton(onPressed:(){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: 
                                    (context) => 
                                    AllPropertyScreen(locationByMonth: model.locationByMonth)),
                                    
                                  );
                                }),
                              ],
                            ),
                            PropertyListV3(model: model),
                            SizedBox(height: 2.height),
                            SizedBox(
                              height: 40.fSize,
                            child:Row(
                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: _buildSectionTitle('Newsletter'),
                                ),
                                _seeAllButton(
                                  onPressed: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => 
                                      Newsletter()),
                                    );
                                  }
                              
                                ),
                                
                               //height 200
                               
            
                               
                              ],
                            ),
                            ),
                            SizedBox(height: 100),
                            
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              ),
            
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const BottomNavBar(currentIndex: 0,),
              extendBody: true,
            ),
          );
        }
        );
      }
      ),
    );
  }
}

Widget _buildBackgroundContainer() {
  return Container(
    alignment: Alignment.topCenter,
    width: 100.width,
    height: 100.height,
    color: const Color(0xFFFFFFFF),
    padding: EdgeInsets.only(top: 2.height),
  
  );
}

Widget _buildSectionTitle(String title) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: TextStyle(
        fontFamily: 'Open Sans',
        fontSize: 20.fSize,
        fontWeight: FontWeight.w800,
        color: const Color(0XFF000000),
      ),
    ),
  );
}

Widget _seeAllButton({VoidCallback? onPressed}) {
  return TextButton(
  onPressed: onPressed,
    child: const Text(
      'See All',
      ),
    );
}
