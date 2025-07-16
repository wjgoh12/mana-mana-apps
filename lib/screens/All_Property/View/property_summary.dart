import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/occupancy_rate_box.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/recent_activity.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/property_dropdown.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/new_dashboard_v3.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/overview_card.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:provider/provider.dart';

class PropertySummaryScreen extends StatelessWidget {
  const PropertySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = NewDashboardVM_v3();
    final model2 = PropertyDetailVM();
    model.fetchData();
    model2.fetchData(model.locationByMonth);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: propertyAppBar(
        context,
        () => Navigator.of(context).pop(),
      ),
      body: FutureBuilder(
        future: model.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 15, top: 5, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      flex: 0,
                      child: PropertyTitleDropdown(currentPage:'Summary'),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // spacing between dropdown and card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: OverviewCard(model:model),
                ),
                SizedBox(height:10.fSize),
                OccupancyRateBox(),
                RecentActivity(),
                


                
              ],
              
            ),
          );

        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
