import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';

class OccupancyText extends StatefulWidget {
  final String? location;
  final String? unitNo;
  final bool showTotal;

  const OccupancyText({
    super.key,
    this.location,
    this.unitNo,
    this.showTotal = false,
  });

  @override
  State<OccupancyText> createState() => _OccupancyTextState();
}

class _OccupancyTextState extends State<OccupancyText> {
  String _occupancyRate = '0';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOccupancy();
    });
  }

  Future<void> _loadOccupancy() async {
    if (!mounted) return;

    try {
      final viewModel = context.read<NewDashboardVM_v3>();
      String occupancy;

      if (widget.showTotal) {
        occupancy = viewModel.getTotalOccupancyRate();
      } else if (widget.location != null && widget.unitNo != null) {
        occupancy =
            await viewModel.getUnitOccupancy(widget.location!, widget.unitNo!);
      } else if (widget.location != null) {
        occupancy = viewModel.getOccupancyByLocation(widget.location!);
      } else {
        occupancy = viewModel.getTotalOccupancyRate();
      }

      if (mounted) {
        setState(() {
          _occupancyRate = occupancy;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _occupancyRate = '0';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Text('Loading...', style: TextStyle(fontSize: 10));
    }

    return Text('($_occupancyRate% Occupancy)',
        style: const TextStyle(fontSize: 10));
  }
}
