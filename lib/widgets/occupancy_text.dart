import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';

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

    // print('OccupancyText: build called');
    // print('OccupancyText: viewModel provided: ${widget.viewModel != null}');
    // print('OccupancyText: viewModel from context: ${viewModel != null}');
    // print('OccupancyText: viewModel.isLoading: ${viewModel.isLoading}');
    // print('OccupancyText: viewModel.propertyOccupancy: ${viewModel.propertyOccupancy}');

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        String occupancy;

        // print('OccupancyText: ListenableBuilder rebuild');
        // print('OccupancyText: viewModel.isLoading: ${viewModel.isLoading}');
        // print(
        //     'OccupancyText: viewModel.propertyOccupancy: ${viewModel.propertyOccupancy}');

        try {
          if (widget.showTotal) {
            occupancy = viewModel.getTotalOccupancyRate();
            // print(
            //     'OccupancyText: showTotal=true, occupancy=$occupancy, isLoading=${viewModel.isLoading}');
          } else if (widget.location != null && widget.unitNo != null) {
            // For unit-specific occupancy, we need to handle async
            return FutureBuilder<String>(
              future:
                  viewModel.getUnitOccupancy(widget.location!, widget.unitNo!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...',
                      style: TextStyle(fontSize: 8));
                }
                if (snapshot.hasError) {
                  return const Text('Error', style: TextStyle(fontSize: 8));
                }

                final unitOccupancy = snapshot.data ?? '0';
                // print('OccupancyText: Unit occupancy=$unitOccupancy');

                if (widget.showPercentageOnly) {
                  return Text('$unitOccupancy%',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black));
                }

                return Text('($unitOccupancy% Occupancy)',
                    style: const TextStyle(fontSize: 8));
              },
            );
          } else if (widget.location != null) {
            occupancy = viewModel.getOccupancyByLocation(widget.location!);
            // print(
            //     'OccupancyText: location=${widget.location}, occupancy=$occupancy');
          } else {
            occupancy = viewModel.getTotalOccupancyRate();
            // print('OccupancyText: no location/unit, occupancy=$occupancy');
          }

          // Check if data is still loading
          if (viewModel.isLoading || occupancy == '0' || occupancy.isEmpty) {
            // print(
            //     'OccupancyText: Showing loading, isLoading=${viewModel.isLoading}, occupancy=$occupancy');
            return const Text('0.0%', style: TextStyle(fontSize: 12));
          }

          // print(
          //     'OccupancyText: Final occupancy=$occupancy, showPercentageOnly=${widget.showPercentageOnly}');

          if (widget.showPercentageOnly) {
            return Text('$occupancy%',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black));
          }

          return Text('($occupancy% Occupancy)',
              style: const TextStyle(fontSize: 8));
        } catch (e) {
          print('OccupancyText: Error occurred: $e');
          return const Text('0.0%', style: TextStyle(fontSize: 12));
        }
      },
    );
  }
}
