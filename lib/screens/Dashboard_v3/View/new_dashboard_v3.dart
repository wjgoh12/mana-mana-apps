import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/New_Dashboard/View/property_list.dart';
import 'package:mana_mana_app/screens/New_Dashboard/View/revenue_dashboard.dart';
import 'package:mana_mana_app/screens/New_Dashboard/View/statistic_table.dart';
import 'package:mana_mana_app/screens/New_Dashboard/View/user_info.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';

class NewDashboardV3 extends StatelessWidget {
  const NewDashboardV3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NewDashboardVM model = NewDashboardVM();
    model.fetchData();
    return ListenableBuilder(
        listenable: model,
        builder: (context, child) {
          return Scaffold(
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildBackgroundContainer(),
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const TopBar(),
                  automaticallyImplyLeading:
                      false, // This will remove the back button
                  toolbarHeight: !Responsive.isMobile(context) ? 160 : 50,
                ),
                Positioned(
                        top: 14.height,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification
                                is ScrollUpdateNotification) {
                              // You can add additional logic here if needed
                            }
                            return true;
                          },
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: RefreshIndicator(
                              onRefresh: () async {
                                await model.refreshData();
                              },
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 100.width,
                                      padding: EdgeInsets.all(7.width),
                                      decoration: const BoxDecoration(
                                        color:Color(0xFFFFFFFF),
                                        // borderRadius: BorderRadius.vertical(
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
                                                      fontSize: 40.fSize,
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
                                  // Add your settings button functionality here
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0XFFD9D9D9), 
                                  width: 2
                                  ),
                              ),
                            ),
                          ),

                          SizedBox(height: 2.height),
                          
                          Row(
                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: [
                                _buildSectionTitle('Overview'),
                                _seeAllButton(),
                        
                              

                            ],
                            
                          ),
                          

                          //statistic box is just visualize the summary of data:
                          //total property, total profit, accummulated profit, occupancy rate
                          //StatisticBox(model:model),

                          SizedBox(height: 2.height),
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('Your Properties'),
                              _seeAllButton(),
                            ],
                          ),

                          SizedBox(height: 2.height),
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('Newsletter'),
                              _seeAllButton(),
                            ],
                          ),
                          
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
          );
        });
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

Widget _seeAllButton() {
  return TextButton(
    onPressed: () {
      // Add your see all button functionality here
    },
    child: const Text(
      'See All',
    ),
  );
}

                                //           UserInfo(model: model),
                                //           RevenueDashboard(model: model),
                                //           SizedBox(height: 2.height),
                                //           _buildSectionTitle('Statistics'),
                                //           SizedBox(height: 2.height),
                                //           StatisticTable(model: model),
                                //           SizedBox(height: 2.height),
                                //           _buildSectionTitle('Properties'),
                                //           SizedBox(height: 2.height),
                                //           PropertyList(model: model),
                                //           SizedBox(height: 2.height),