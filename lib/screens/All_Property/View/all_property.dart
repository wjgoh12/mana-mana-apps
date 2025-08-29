import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/property_dropdown.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:provider/provider.dart';

class AllPropertyScreen extends StatelessWidget {
  const AllPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewDashboardVM_v3()..fetchData(),
      child: Consumer<NewDashboardVM_v3>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: const Color(0XFFFFFFFF),
            appBar: propertyAppBar(
              context,
              () => Navigator.of(context).pop(),
            ),
            body: model.isLoading
                ? const Center(
                    child: CircularProgressIndicator()) // Show loading
                : Column(
                    children: [
                      // Add PropertyTitleDropdown shere
                      const Padding(
                        padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            PropertyTitleDropdown(currentPage: 'Property List'),
                          ],
                        ),
                      ),
                      // Main content
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          children: [
                            _buildPropertyStack(
                              locationByMonth: model.locationByMonth,
                              context: context,
                              model: model,
                            ),
                          ],
                        ),
                      ),
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
}
