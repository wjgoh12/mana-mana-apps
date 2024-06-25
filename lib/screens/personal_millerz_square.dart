import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/millerz_square1.dart';
import 'package:mana_mana_app/widgets/overall_revenue_container.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class PersonalMillerzSquare1Screen extends StatelessWidget {
  const PersonalMillerzSquare1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      appBar: propertyAppBar(context, () {
        Navigator.of(context).pop();
      }),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            propertyStack(
              'millerz_square',
              'Millerz Square',
              '@ Old Klang Road',
              86.width,
              12.height,
            ),
            SizedBox(
              height: 0.5.height,
            ),
            const OverallRevenueContainer(),
          ],
        ),
      ),
    );
  }
}


