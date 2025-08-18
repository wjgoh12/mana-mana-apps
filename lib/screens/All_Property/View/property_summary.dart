import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_rate_box.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/recent_activity.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/property_dropdown.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/overview_card.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:provider/provider.dart';

class PropertySummaryScreen extends StatefulWidget {
  const PropertySummaryScreen({super.key});

  @override
  State<PropertySummaryScreen> createState() => _PropertySummaryScreenState();
}

class _PropertySummaryScreenState extends State<PropertySummaryScreen> {
  final NewDashboardVM_v3 _model = NewDashboardVM_v3();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    print('refetching data...');
    await _model.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _model,
      child: Consumer<NewDashboardVM_v3>(
        builder: (context, model, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Screen width and height
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              // Scale factors
              double padding = screenWidth * 0.04; // ~4% of width
              double smallGap = screenHeight * 0.015;
              double mediumGap = screenHeight * 0.02;

              return Scaffold(
                backgroundColor: Colors.white,
                appBar: propertyAppBar(
                  context,
                  () => Navigator.of(context).pop(),
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: padding,
                    right: padding,
                    top: smallGap,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            flex: 0,
                            child:
                                PropertyTitleDropdown(currentPage: 'Summary'),
                          ),
                        ],
                      ),
                      SizedBox(height: mediumGap),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: OverviewCard(model: model),
                      ),
                      SizedBox(height: smallGap),
                      OccupancyRateBox(),
                      RecentActivity(
                        locationByMonth: model.locationByMonth,
                        ownerData: [],
                      ),
                    ],
                  ),
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
                    child: PropertyTitleDropdown(currentPage: 'Summary'),
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
              RecentActivity(
                locationByMonth: model.locationByMonth,
                ownerData: model2.ownerData,
              ),
            ],
          ),
        );
      },
    );
  }
}
