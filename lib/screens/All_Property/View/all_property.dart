import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class AllPropertyScreen extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;
  const AllPropertyScreen({required this.locationByMonth, super.key});

  @override
  Widget build(BuildContext context) {
    const _isActive = true;
    const _isNotActive = false;
    //to identify if active or inactive property to do the logic for organizing types of properties(active/contract ended)


    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      appBar: propertyAppBar(
        context,
        () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 5),
        children: [
          GestureDetector(
            child: Column(
              children: locationByMonth
                  .map((property) => property['location'])
                  .toSet()
                  .map((uniqueLocation) {
                final property = locationByMonth
                    .firstWhere((p) => p['location'] == uniqueLocation);
                return Column(
                  children: [
                    GestureDetector(
                      child: _buildPropertyStack(
                        locationByMonth: [property],
                        context: context,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1,),
    );
  }

  Widget _buildPropertyStack({
    required List<Map<String, dynamic>> locationByMonth,
    required BuildContext context,
  }) {
    String locationRoad = '';
    switch (locationByMonth[0]['location'].toUpperCase()) {
      case "EXPRESSIONZ":
        locationRoad = "@ Jalan Tun Razak";
        break;
      case "CEYLONZ":
        locationRoad = "@ Persiaran Raja Chulan";
        break;
      case "SCARLETZ":
        locationRoad = "@ Jalan Yap Kwan Seng";
        break;
      case "MILLERZ":
        locationRoad = "@ Old Klang Road";
        break;
      case "MOSSAZ":
        locationRoad = "@ Empire City";
        break;
      case "PAXTONZ":
        locationRoad = "@ Empire City";
        break;
      default:
        locationRoad = "";
        break;
    }
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => PropertyDetail(locationByMonth: locationByMonth),
        //   ),
        // );
      },
      child: PropertyStack(
        image: locationByMonth[0]['location'] ?? '',
        text1: locationByMonth[0]['location'] ?? '',
        text2: locationRoad,
        text3: locationByMonth[0]['totalUnits'] ?? '',
        total:locationByMonth[0]['total'] ?? '',
        // width: 85.width,
        // height: 12.height,
      ),
    );
  }
}
