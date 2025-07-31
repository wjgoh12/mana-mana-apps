import 'package:flutter/material.dart';
import 'package:mana_mana_app/repository/property_list.dart';

class OccupancyText extends StatefulWidget {
  const OccupancyText({super.key});

  @override
  State<OccupancyText> createState() => _OccupancyTextState();
}

class _OccupancyTextState extends State<OccupancyText> {
  late Future<Map<String, dynamic>> _occupancyFuture;

  @override
  void initState() {
    super.initState();
    _occupancyFuture = PropertyListRepository().getPropertyOccupancy();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _occupancyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...', style: TextStyle(fontSize: 10));
        } else if (snapshot.hasError) {
          return const Text('Error', style: TextStyle(fontSize: 10));
        } else if (snapshot.hasData) {
          final occupancy = snapshot.data?['occupancyRate'] ?? 0;
          return Text('($occupancy% Occupancy)',
              style: const TextStyle(fontSize: 10));
        } else {
          return const Text('No data', style: TextStyle(fontSize: 10));
        }
      },
    );
  }
}
