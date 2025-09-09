import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/property_unit_selector.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Profile/View/financial_details.dart';
import 'package:mana_mana_app/screens/Profile/View/property_redemption.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/unit_overview_container.dart';
import 'package:provider/provider.dart';

class AllPropertyNewScreen extends StatefulWidget {
  const AllPropertyNewScreen({super.key});

  @override
  State<AllPropertyNewScreen> createState() => _AllPropertyNewScreenState();
}

class _AllPropertyNewScreenState extends State<AllPropertyNewScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global data manager at the top level
        ChangeNotifierProvider.value(value: GlobalDataManager()),
        // Dashboard ViewModel that will use cached data
        ChangeNotifierProvider(
          create: (_) {
            final model = NewDashboardVM_v3();
            // Initialize data once - will use cached data if already loaded
            model.fetchData();
            return model;
          },
        ),
        // Property Detail ViewModel that will use cached data
        ChangeNotifierProvider(
          create: (_) => PropertyDetailVM(),
        ),
      ],
      child: Consumer2<NewDashboardVM_v3, PropertyDetailVM>(
        builder: (context, dashboardModel, propertyModel, child) {
          // Initialize property detail model with dashboard data
          if (dashboardModel.locationByMonth.isNotEmpty &&
              !propertyModel.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              propertyModel.fetchData(dashboardModel.locationByMonth);
            });
          }

          return Scaffold(
            backgroundColor: const Color(0XFFFFFFFF),
            appBar: propertyAppBar(context, () => Navigator.of(context).pop()),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: ResponsiveSize.scaleHeight(20),
                  ),
                  _unitDropDown(),
                  UnitOverviewContainer(
                    model: dashboardModel,
                    model2: propertyModel,
                  ),
                  SizedBox(
                    height: ResponsiveSize.scaleHeight(15),
                  ),
                  _quickLinks(context),
                ],
              ),
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 1),
          );
        },
      ),
    );
  }
}

Widget _unitDropDown() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Unit:',
        //   style: TextStyle(
        //       fontSize: ResponsiveSize.text(18),
        //       fontWeight: FontWeight.bold,
        //       fontFamily: 'Outfit'),
        // ),
        SizedBox(height: ResponsiveSize.scaleHeight(8)),
        const PropertyUnitSelector(),
      ],
    ),
  );
}

Widget _quickLinks(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(
          left: ResponsiveSize.scaleWidth(10),
          bottom: ResponsiveSize.scaleHeight(8),
        ),
        child: Text(
          'Quick Links',
          style: TextStyle(
            fontSize: ResponsiveSize.text(18),
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ),
      SizedBox(height: ResponsiveSize.scaleHeight(10)),
      Padding(
        padding:
            EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(20)),
        child: Row(
          children: [
            //1
            Expanded(
              child: SizedBox(
                height:
                    ResponsiveSize.scaleWidth(120), // 🔹 fixed square height
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  FinancialDetails(),
                          transitionDuration: const Duration(milliseconds: 300),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wallet, size: ResponsiveSize.scaleWidth(40)),
                        SizedBox(height: 8),
                        Text(
                          'Financial Details',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(12),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //2
            Expanded(
              child: SizedBox(
                height: ResponsiveSize.scaleWidth(120),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book, size: ResponsiveSize.scaleWidth(40)),
                        SizedBox(height: 8),
                        Text(
                          'Make a Booking',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(12),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //3
            Expanded(
              child: SizedBox(
                height: ResponsiveSize.scaleWidth(120),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  PropertyRedemption(),
                          transitionDuration: const Duration(milliseconds: 300),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hotel, size: ResponsiveSize.scaleWidth(40)),
                        SizedBox(height: 8),
                        Text(
                          'Free Stay Redemption',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(12),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    ],
  );
}
