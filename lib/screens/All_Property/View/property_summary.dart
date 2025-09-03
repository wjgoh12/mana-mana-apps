import 'package:flutter/material.dart';
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
  final NewDashboardVM_v3 _model = NewDashboardVM_v3();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    debugPrint('refetching data...');
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

              // Scale factors (tweak as needed)
              final double baseWidth = 390;
              final double baseHeight = 844;
              final double scaleW = screenWidth / baseWidth;
              final double scaleH = screenHeight / baseHeight;

              // Shortcut for scaled spacing
              double spacing(double value) => value * scaleH;
              double font(double size) => size * scaleW;

              return Scaffold(
                backgroundColor: Colors.white,
                appBar: propertyAppBar(
                  context,
                  () => Navigator.of(context).pop(),
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing(12),
                    vertical: spacing(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      SizedBox(height: spacing(16)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing(8)),
                        child: OverviewCard(model: model),
                      ),
                      SizedBox(height: spacing(12)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing(8)),
                        child: OccupancyRateBox(),
                      ),
                      SizedBox(height: spacing(12)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing(8)),
                        child: RecentActivity(
                          model: PropertyDetailVM(),
                        ),
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
