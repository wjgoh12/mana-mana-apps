import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:provider/provider.dart';

class RecentActivity extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;
  final List<OwnerPropertyList> ownerData;

  const RecentActivity({
    super.key,
    required this.locationByMonth,
    required this.ownerData,
  });

  @override
  Widget build(BuildContext context) {
    PropertyDetailVM model = PropertyDetailVM();

    if (locationByMonth.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('No recent activity'),
        ),
      );
    }

    return ListView.builder(
      itemCount: locationByMonth.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = locationByMonth[index];
        final location = item['location'] ?? 'Unknown Location';
        final unitNo = item['unitNo'] ?? 'Unknown Unit';
        final fullProperty = locationByMonth.firstWhere(
          (prop) =>
              prop['location'] == item['location'] &&
              prop['unitNo'] == item['unitNo'],
          orElse: () => item,
        );
        // final owner = ownerData.firstWhere(
        //   (o) =>
        //       o.location?.trim().toLowerCase() ==
        //           location?.trim().toLowerCase() &&
        //       o.unitno?.trim().toLowerCase() == unitNo.trim().toLowerCase(),
        //   orElse: () =>
        //       OwnerPropertyList(type: '', unitno: 'Unknown Unit', location: ''),
        // );
        // final isMobile =
        //     sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        // final width = isMobile ? 370.fSize : 360.fSize;
        // final height = 207.fSize;
        // // final position = 25.height;
        // final containerWidth = isMobile ? 390.fSize : 380.fSize;
        // final containerHeight = 405.fSize;
        // final smallcontainerWidth = isMobile ? 355.fSize : 100.width;
        // final smallcontainerHeight = 35.fSize;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChangeNotifierProvider<NewDashboardVM_v3>(
                    create: (_) => NewDashboardVM_v3(),
                    child: property_detail_v3(
                      model: NewDashboardVM_v3(),
                      locationByMonth: [locationByMonth.first],
                      initialType: fullProperty['type'],
                      initialUnitNo: fullProperty['unitNo'],
                      initialTab: 'unitDetails',
                    ),
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 106.fSize,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.fSize),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // left text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Statement for Unit ${fullProperty['unitNo']} has been issued for $location',
                          style: TextStyle(
                            fontSize: 11.fSize,
                            color: const Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 14.fSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.black54),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
