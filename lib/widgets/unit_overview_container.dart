import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class UnitOverviewContainer extends StatelessWidget {
  final PropertyDetailVM model;

  const UnitOverviewContainer({Key? key, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Monthly Profit',
                  'Year 2025',
                  value: 'RM 1,865.40',
                ),
              ),
              const SizedBox(width: 8), // spacing
              Expanded(
                child: _buildStatCard(
                  'Net Profit After POB',
                  'Year 2025',
                  value: 'RM 1,296.30',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '2025 Accumulated Profit',
                  'Year 2025',
                  value: 'RM 1,296.30',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Group Occupancy',
                  'Year 2025',
                  value: '92.30%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildStatCard(String title, String subtitle, {String? value}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    color: Colors.white,
    child: Container(
      height: ResponsiveSize.scaleHeight(90),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSize.scaleWidth(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Outfit',
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Outfit',
              ),
            ),
            Text(
              value ?? '0',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
