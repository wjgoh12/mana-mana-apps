import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/property_dropdown.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Profile/View/financial_details.dart';
import 'package:mana_mana_app/screens/Profile/View/property_redemption.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
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
    return ChangeNotifierProvider(
      create: (_) => NewDashboardVM_v3()..fetchData(),
      child: Consumer<NewDashboardVM_v3>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: const Color(0XFFFFFFFF),
            appBar: propertyAppBar(context, () => Navigator.of(context).pop()),
            body: Column(
              children: [
                SizedBox(
                  height: ResponsiveSize.scaleHeight(20),
                ),
                _unitDropDown(),
                UnitOverviewContainer(model: PropertyDetailVM()),
                SizedBox(
                  height: ResponsiveSize.scaleHeight(15),
                ),
                _quickLinks(context),
              ],
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 1),
          );
        },
      ),
    );
  }

  Widget _buildPropertyStack({
    required List<Map<String, dynamic>> locationByMonth,
    required BuildContext context,
    required NewDashboardVM_v3 model,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final horizontalPadding = isMobile ? 16.0 : 40.0;

    // Group by location & pick latest month/year
    final Map<String, Map<String, dynamic>> latestByLocation = {};
    final List<Map<String, dynamic>> source = locationByMonth;

    for (var property in source) {
      final location = property['location'] as String;
      if (!latestByLocation.containsKey(location)) {
        latestByLocation[location] = property;
      } else {
        final existing = latestByLocation[location]!;
        final isNewer = (property['year'] > existing['year']) ||
            (property['year'] == existing['year'] &&
                property['month'] > existing['month']);
        if (isNewer) {
          latestByLocation[location] = property;
        }
      }
    }

    // Convert to list & sort by newest first
    final latestProperties = latestByLocation.values.toList()
      ..sort((a, b) {
        final yearDiff = (b['year'] as int).compareTo(a['year'] as int);
        if (yearDiff != 0) return yearDiff;
        return (b['month'] as int).compareTo(a['month'] as int);
      });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      itemCount: latestProperties.length,
      itemBuilder: (context, index) {
        final property = latestProperties[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Center(
            child: PropertyStack(
              locationByMonth: [property],
              model: model,
            ),
          ),
        );
      },
    );
  }

  Widget _unitDropDown() {
    final deduped = <String>[];
    final items =
        deduped.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList();

    return Container(
      child: Row(
        children: [
          SizedBox(width: ResponsiveSize.scaleWidth(16)),
          Text('Unit:',
              style: TextStyle(
                  fontSize: ResponsiveSize.text(18),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit')),
        ],
      ),
    );
  }
}

Widget _quickLinks(BuildContext context) {
  return Container(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //1
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FinancialDetails(),
                    transitionDuration: const Duration(milliseconds: 300),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                            CurvedAnimation(
                                parent: animation, curve: Curves.easeInOut),
                          ),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
              },
              child: Column(
                children: [
                  Icon(Icons.wallet, size: ResponsiveSize.scaleWidth(40)),
                  Text(
                    'Financial Details',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: ResponsiveSize.text(12),
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
            //2
            InkWell(
              onTap: () {},
              child: Column(
                children: [
                  Icon(Icons.book, size: ResponsiveSize.scaleWidth(40)),
                  Text(
                    'Make a Booking',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: ResponsiveSize.text(12),
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
            //3
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          PropertyRedemption(),
                      transitionDuration: const Duration(milliseconds: 300),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 300),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                              CurvedAnimation(
                                  parent: animation, curve: Curves.easeInOut),
                            ),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
                child: Column(
                  children: [
                    Icon(Icons.hotel, size: ResponsiveSize.scaleWidth(40)),
                    Text(
                      'Free Stay Redemption',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: ResponsiveSize.text(12),
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}
