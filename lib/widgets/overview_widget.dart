import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15), // 15px screen margin
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Flexible(
            child: Column(
              children: [
                Card(
                  
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFF5092FF),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 130.fSize,
                  ),
                  
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFFFFE7B8),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 83.fSize,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 20), // spacing between columns

          // Right Column
          Flexible(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFF9EEAFF),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 83.fSize,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFFDBC7FF),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 130.fSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}