import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';

class OccupancyPercentageText extends StatefulWidget {
  final String? location;
  final String? unitNo;
  final bool showTotal;

  const OccupancyPercentageText({
    super.key,
    this.location,
    this.unitNo,
    this.showTotal = false,
  });

  @override
  State<OccupancyPercentageText> createState() => _OccupancyTextState();
}

class _OccupancyTextState extends State<OccupancyPercentageText> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<NewDashboardVM_v3>();
    
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        String occupancy;

        try {
          if (widget.showTotal) {
            occupancy = viewModel.getTotalOccupancyRate();
          } else if (widget.location != null && widget.unitNo != null) {
            occupancy = viewModel.getUnitOccupancyFromCache(widget.location!, widget.unitNo!);
          } else if (widget.location != null) {
            occupancy = viewModel.getOccupancyByLocation(widget.location!);
          } else {
            occupancy = viewModel.getTotalOccupancyRate();
          }

          if (viewModel.isLoading) {
            return const Text('Loading...', style: TextStyle(fontSize: 11));
          }

          return Text('$occupancy%', style: const TextStyle(fontSize: 11));
        } catch (e) {
          return const Text('0%', style: TextStyle(fontSize: 11));
        }
      },
    );
  }
}
