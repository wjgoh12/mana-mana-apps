import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_rate_box.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/recent_activity.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/property_dropdown.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/overview_card.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:provider/provider.dart';

class PropertySummaryScreen extends StatefulWidget {
  const PropertySummaryScreen({super.key});

  @override
  State<PropertySummaryScreen> createState() => _PropertySummaryScreenState();
}

class _PropertySummaryScreenState extends State<PropertySummaryScreen> {
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
          if (dashboardModel.locationByMonth.isNotEmpty && !propertyModel.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              propertyModel.fetchData(dashboardModel.locationByMonth);
            });
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Screen width and height
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              // Scale factors (tweak as needed)
              final double baseWidth = 390;
              final double baseHeight = 844;
              final double scaleW = screenWidth / baseWidth;
              final double scaleH = screenHeight / baseHeight;

              return Scaffold(
                backgroundColor: const Color(0XFFFFFFFF),
                appBar: propertyAppBar(
                  context,
                  () => Navigator.of(context).pop(),
                ),
                body: dashboardModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          // Add PropertyTitleDropdown here
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
                            child: Row(
                              children: [
                                // PropertyTitleDropdown(currentPage: 'Property List'),
                              ],
                            ),
                          ),
                          // Main content
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              children: [
                                // Overview Card
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15 * scaleW, vertical: 10 * scaleH),
                                  child: OverviewCard(model: dashboardModel),
                                ),

                                // Occupancy Rate Box
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15 * scaleW, vertical: 10 * scaleH),
                                  child: OccupancyRateBox(model: dashboardModel),
                                ),

                                // Recent Activity
                                if (propertyModel.unitByMonth.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15 * scaleW, vertical: 10 * scaleH),
                                    child: RecentActivity(model: propertyModel),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                bottomNavigationBar: const BottomNavBar(currentIndex: 1),
              );
            },
          );
        },
      ),
    );
  }
}

// Extract content to optimize rebuilds (optional)
class _PropertySummaryContent extends StatelessWidget {
  const _PropertySummaryContent();

  @override
  Widget build(BuildContext context) {
    return Consumer2<NewDashboardVM_v3, PropertyDetailVM>(
      builder: (context, model, model2, child) {
        print('locationByMonth length: ${model.locationByMonth.length}');
        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 15, top: 5, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    flex: 0,
                    child: PropertyTitleDropdown(currentPage: 'Property List'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: OverviewCard(model: model),
              ),
              SizedBox(height: 10.fSize),
              OccupancyRateBox(),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Text('Recent Activity',
                    style: TextStyle(
                        fontFamily: 'outfit',
                        fontSize: ResponsiveSize.text(16))),
              ),
              RecentActivity(
                model: model2,
              ),
            ],
          ),
        );
      },
    );
  }
}
