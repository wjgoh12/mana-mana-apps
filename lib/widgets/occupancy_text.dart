import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';

class OccupancyText extends StatefulWidget {
  final String? location;
  final String? unitNo;
  final bool showTotal;
  final bool showPercentageOnly;
  final NewDashboardVM_v3? viewModel;

  const OccupancyText({
    super.key,
    this.location,
    this.unitNo,
    this.showTotal = false,
    this.showPercentageOnly = false,
    this.viewModel,
  });

  @override
  State<OccupancyText> createState() => _OccupancyTextState();
}

class _OccupancyTextState extends State<OccupancyText> {
  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel ?? context.read<NewDashboardVM_v3>();

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        String occupancy;

        try {
          if (widget.showTotal) {
            occupancy = viewModel.getTotalOccupancyRate();
          } else if (widget.location != null && widget.unitNo != null) {
            // Use cached data instead of FutureBuilder with API calls
            occupancy = viewModel.getUnitOccupancyFromCache(widget.location!, widget.unitNo!);
          } else if (widget.location != null) {
            occupancy = viewModel.getOccupancyByLocation(widget.location!);
          } else {
            occupancy = viewModel.getTotalOccupancyRate();
          }

          // Check if data is still loading
          if (viewModel.isLoading || occupancy == '0' || occupancy.isEmpty) {
            return const Text('0.0%', style: TextStyle(fontSize: AppDimens.fontSizeSmall));
          }

          if (widget.showPercentageOnly) {
            return Text('$occupancy%',
                style: const TextStyle(
                    fontSize: AppDimens.fontSizeSmall,
                    fontWeight: FontWeight.bold,
                    color: Colors.black));
          }

          return Text('($occupancy% Occupancy)',
              style: const TextStyle(fontSize: AppDimens.fontSizeSmall));
        } catch (e) {
          return const Text('0.0%', style: TextStyle(fontSize: AppDimens.fontSizeSmall));
        }
      },
    );
  }
}
