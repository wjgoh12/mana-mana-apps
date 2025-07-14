import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/newsletter_list_v3.dart';
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
import 'package:flutter_animate/flutter_animate.dart';

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
          final ScrollController propertyScrollController = ScrollController();
          final ScrollController newsletterScrollController = ScrollController();
          final ValueNotifier<bool> isRefreshing = ValueNotifier(false);

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
                      background: _buildHeaderContent(context, model, isRefreshing, innerBoxIsScrolled),
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
                    padding: const EdgeInsets.only(top: 0),
                    child: Column(
                      children: [
                        // Greeting and search bar (always visible)
                        Container(
                          width: 100.width,
                          padding: EdgeInsets.all(7.width),
                          color: Colors.white,
                          child: Column(
                            children: [
                              // Greeting
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hey, ${model.userNameAccount}👋',
                                    style: TextStyle(
                                      fontSize: 16.fSize,
                                      fontFamily: 'Open Sans',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.height),
                              
                              // Gradient title
                              Row(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFFB82B7D), Color.fromRGBO(62, 81, 255, 1)],
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
                                    child: Image.asset('assets/images/searchIcon.png'),
                                  ),
                                  hintText: 'Search Your Properties',
                                  hintStyle: TextStyle(fontSize: 15.fSize),
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
                          width: 100.width,
                          padding: EdgeInsets.symmetric(horizontal:7.width),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionTitle('Overview'),
                                  _seeAllButton(),
                                ],
                              ),
                              OverviewCard(model: model),
                            ],
                          ),
                        ),

                        // Properties section
                        Container(
                          width: 100.width,
                          padding: EdgeInsets.symmetric(horizontal: 7.width),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionTitle('Your Properties'),
                                  _seeAllButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AllPropertyScreen(
                                            locationByMonth: model.locationByMonth,
                                          ),
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
                            ],
                          ),
                        ),

                     //   SizedBox(height: 2.height),

                        // Newsletter section
                        Container(
                          width: 100.width,
                          padding: EdgeInsets.symmetric(horizontal: 7.width),
                          color: Colors.white,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 40.fSize,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: _buildSectionTitle('Newsletter'),
                                    ),
                                    _seeAllButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Newsletter(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              NewsletterListV3(
                                model: model,
                                controller: newsletterScrollController,
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  Widget _buildHeaderContent(BuildContext context, dynamic model, ValueNotifier<bool> isRefreshing, bool innerBoxIsScrolled) {
    return Container(
      width: 100.width,
      color: Colors.white,
      child: Column(
        children: [
          // Status bar spacing
          SizedBox(height: MediaQuery.of(context).padding.top),
          
          // Only show Owner's portal top bar when not scrolled
          if (!innerBoxIsScrolled) topBar(context, () {}),
        ],
      ),
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
        style: TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
}
