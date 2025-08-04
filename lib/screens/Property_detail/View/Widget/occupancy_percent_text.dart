import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';

enum OccupancyType { unit, property, total }

class OccupancyPercentText extends StatefulWidget {
  final String? location;
  final String? unitNo;
  final OccupancyType type;

  const OccupancyPercentText({
    super.key,
    this.location,
    this.unitNo,
    this.type = OccupancyType.total,
  });

  @override
  State<OccupancyPercentText> createState() => _OccupancyPercentTextState();
}

class _OccupancyPercentTextState extends State<OccupancyPercentText> {
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

      switch (widget.type) {
        case OccupancyType.unit:
          if (widget.location != null && widget.unitNo != null) {
            occupancy = await viewModel.getUnitOccupancy(
                widget.location!, widget.unitNo!);
          } else {
            occupancy = '0';
          }
          break;
        case OccupancyType.property:
          if (widget.location != null) {
            occupancy = viewModel.getOccupancyByLocation(widget.location!);
          } else {
            occupancy = '0';
          }
          break;
        case OccupancyType.total:
        default:
          occupancy = viewModel.getTotalOccupancyRate();
      }

      if (mounted) {
        setState(() {
          _occupancyRate = occupancy;
          _isLoading = false;
        });
      }
    } catch (_) {
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
      return const Text('...', style: TextStyle(fontSize: 10));
    }

    return Text(
      '$_occupancyRate%',
      style: const TextStyle(fontSize: 10),
    );
  }
}
