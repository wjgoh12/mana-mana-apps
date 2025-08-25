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

          // Safely access the first owner (if exists)
          final owners = (item['owners'] as List?) ?? [];
          final firstOwner = owners.isNotEmpty ? owners.first : null;

          final unitNo = firstOwner != null
              ? firstOwner['unitNo'] ?? 'Unknown Unit'
              : 'Unknown Unit';
          final type = firstOwner != null ? firstOwner['type'] ?? '' : '';

          // Find the matching property by location + unitNo (avoid duplicates)
          final fullProperty = locationByMonth.firstWhere(
            (prop) {
              final propOwners = (prop['owners'] as List?) ?? [];
              final propFirstOwner =
                  propOwners.isNotEmpty ? propOwners.first : null;
              return prop['location'] == location &&
                  (propFirstOwner?['unitNo'] == unitNo);
            },
            orElse: () => item,
          );

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChangeNotifierProvider<NewDashboardVM_v3>(
                      create: (_) => NewDashboardVM_v3(),
                      child: property_detail_v3(
                        locationByMonth: [fullProperty],
                        initialType: type,
                        initialUnitNo: unitNo,
                        initialTab: 'unitDetails',
                        model: NewDashboardVM_v3(),
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
                            'Statement for Unit $unitNo has been issued for $location',
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
        });
  }
}
