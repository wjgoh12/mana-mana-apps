import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/PropertyDetail/propertyDetail.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class allPropertyScreen extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;
  allPropertyScreen({required this.locationByMonth, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      appBar: propertyAppBar(
        context,
        () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: ListView(
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
      ),
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => propertyDetailScreen(locationByMonth),
          ),
        );
      },
      child: propertyStack(
        image: locationByMonth[0]['location'] ?? '',
        text1: locationByMonth[0]['location'] ?? '',
        text2: locationRoad,
        width: 85.width,
        height: 13.height,
      ),
    );
  }
}
