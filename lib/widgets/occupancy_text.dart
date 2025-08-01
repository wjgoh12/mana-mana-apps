import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';

class OccupancyText extends StatefulWidget {
  final String? location;
  final String? unitNo;
  final bool showTotal; // If true, shows total average across all properties
  
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
  late Future<String> _occupancyFuture;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding.instance.addPostFrameCallback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOccupancy();
    });
  }

  void _initializeOccupancy() {
    if (!mounted) return;
    
    final viewModel = context.read<NewDashboardVM_v3>();
    
    if (widget.showTotal) {
      // Show total average across all properties
      _occupancyFuture = Future.value(viewModel.getTotalOccupancyRate());
    } else if (widget.location != null && widget.unitNo != null) {
      // Show specific unit occupancy
      _occupancyFuture = viewModel.getUnitOccupancy(widget.location!, widget.unitNo!);
    } else if (widget.location != null) {
      // Show property average occupancy
      _occupancyFuture = Future.value(viewModel.getOccupancyByLocation(widget.location!));
    } else {
      // Default to total average
      _occupancyFuture = Future.value(viewModel.getTotalOccupancyRate());
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _occupancyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...', style: TextStyle(fontSize: 10));
        } else if (snapshot.hasError) {
          return const Text('Error', style: TextStyle(fontSize: 10));
        } else if (snapshot.hasData) {
          final occupancy = snapshot.data ?? '0';
          return Text('($occupancy% Occupancy)',
              style: const TextStyle(fontSize: 10));
        } else {
          return const Text('No data', style: TextStyle(fontSize: 10));
        }
      },
    );
  }
}
