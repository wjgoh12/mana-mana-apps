import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/All_Property/View/property_summary.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/newsletter_list_v3.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/property_list_v3.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Newsletter/all_newsletter.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';
import 'package:mana_mana_app/widgets/overview_card.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewDashboardV3 extends StatelessWidget {
  const NewDashboardV3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final model = NewDashboardVM_v3();
        model.fetchData();
        return model;
      },
      child: Consumer<NewDashboardVM_v3>(
        builder: (context, model, child) {
          final ScrollController propertyScrollController = ScrollController();
          final ScrollController newsletterScrollController =
              ScrollController();
          final ValueNotifier<bool> isRefreshing = ValueNotifier(false);
          final isMobile = MediaQuery.of(context).size.width < 600;
          final screenWidth = MediaQuery.of(context).size.width;

          //final double horizontalPadding = isMobile ? 16.0 : 40.0;
          final horizontalPadding = screenWidth * 0.05; // 5% of screen width

          final screenHeight = MediaQuery.of(context).size.height;

          double responsiveWidth(double value) =>
              (value / 375.0) * screenWidth; // base width
          double responsiveHeight(double value) =>
              (value / 812.0) * screenHeight; // base height
          double responsiveFont(double value) =>
              (value / 812.0) * screenHeight; // font scaling

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.white,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    expandedHeight: _getExpandedHeight(context),
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    systemOverlayStyle: const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.dark,
                      statusBarBrightness: Brightness.light,
                    ),
                    title: innerBoxIsScrolled
                        ? Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 18.fSize,
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          )
                        : null,
                    centerTitle: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeaderContent(
                          context, model, isRefreshing, innerBoxIsScrolled),
                      collapseMode: CollapseMode.pin,
                    ),
                  ),
                ],
                body: RefreshIndicator(
                  onRefresh: () async {
                    isRefreshing.value = true;
                    await model.refreshData();
                    isRefreshing.value = false;
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          alignment: Alignment.center,
                          color: Colors.white,
                          child: Column(
                            children: [
                              // Greeting
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hey, ${model.userNameAccount} 👋',
                                    style: TextStyle(
                                      fontSize: responsiveFont(15),
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF383838),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.height),

                              // Gradient title
                              Row(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFFB82B7D),
                                        Color.fromRGBO(62, 81, 255, 1)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      'Simple, Timeless \nAssets Management',
                                      style: TextStyle(
                                        fontSize: responsiveFont(28),
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFFFFFFFF),
                                      ),
                                    ).animate(
                                      onPlay: (controller) {
                                        if (isRefreshing.value) {
                                          controller.repeat();
                                        } else {
                                          controller.stop();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.height),

                              // Search bar
                              TextField(
                                decoration: InputDecoration(
                                  prefixIcon: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Image.asset(
                                        'assets/images/searchIcon.png'),
                                  ),
                                  hintText: 'Search Your Properties',
                                  hintStyle: const TextStyle(fontSize: 15),
                                  suffixIcon: IconButton(
                                    icon: Image.asset(
                                      'assets/images/Settingsbutton.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    onPressed: () {},
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
                              //   SizedBox(height: 2.height),
                            ],
                          ),
                        ),

                        // Overview section
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding, vertical: 14),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionTitle('Overview'),
                                  _seeAllButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PropertySummaryScreen()));
                                    },
                                  ),
                                ],
                              ),
                              OverviewCard(model: model),
                            ],
                          ),
                        ),

                        // Properties section
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding, vertical: 14),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionTitle('Your Properties'),
                                  _seeAllButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllPropertyScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              PropertyListV3(
                                model: model,
                                controller: propertyScrollController,
                              ),
                              const SizedBox(
                                  height: kBottomNavigationBarHeight + 50),
                            ],
                            // prevent blocking
                          ),
                        ),

                        //SizedBox(height: 2.height),

                        // Newsletter section
                        // Container(
                        //   width: screenWidth,
                        //   padding: EdgeInsets.symmetric(
                        //       horizontal: horizontalPadding),
                        //   color: Colors.white,
                        //   child: Column(
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         children: [
                        //           _buildSectionTitle('Newsletter'),
                        //           _seeAllButton(
                        //             onPressed: () {
                        //               Navigator.push(
                        //                 context,
                        //                 MaterialPageRoute(
                        //                     builder: (context) =>
                        //                         AllNewsletter()),
                        //               );
                        //             },
                        //           ),
                        //         ],
                        //       ),
                        //       SizedBox(height: responsiveHeight(15)),
                        //       NewsletterListV3(
                        //         model: model,
                        //         controller: newsletterScrollController,
                        //       ),
                        //       SizedBox(
                        //           height: kBottomNavigationBarHeight +
                        //               20), // prevent blocking
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const BottomNavBar(currentIndex: 0),
              extendBody: true,
            ),
          );
        },
      ),
    );
  }

  double _getExpandedHeight(BuildContext context) {
    // Only need height for status bar + top bar since other content is in body
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final topBarHeight = 60.0; // Approximate height of topBar

    return statusBarHeight + topBarHeight;
  }

  Widget _buildHeaderContent(BuildContext context, dynamic model,
      ValueNotifier<bool> isRefreshing, bool innerBoxIsScrolled) {
    return Container(
      width: 100.width,
      color: Colors.white,
      child: !innerBoxIsScrolled ? topBar(context, () {}) : SizedBox.shrink(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 24.fSize,
          fontWeight: FontWeight.w600,
          color: const Color(0XFF000000),
        ),
      ),
    );
  }

  Widget _seeAllButton({VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'See All',
        style: TextStyle(
          fontSize: 16.fSize,
        ),
      ),
    );
  }
}
