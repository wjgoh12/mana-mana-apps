import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/personal_millerz_square.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class MillerzSquare1Screen extends StatelessWidget {
  const MillerzSquare1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
          appBar: propertyAppBar(
            context,
            () => Navigator.of(context).pop(),
          ),      
          body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 5),
          children: [
            GestureDetector(
              // onTap: () {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) => const PersonalMillerzSquare1Screen(),
              //     ),
              //   );
              // },
              child: _buildPropertyStack(
                image: 'millerz_square',
                text1: 'Millerz Square',
                text2: '@ Old Klang Road',
                context: context,
              ),
            ),
            const SizedBox(height: 20),
            _buildPropertyStack(
              image: 'scarletz_suites',
              text1: 'Scarletz Suites',
              text2: '@ KL City Centre',
              context: context,
            ),
            const SizedBox(height: 20),
            _buildPropertyStack(
              image: 'expressionz',
              text1: 'Expressionz Suites',
              text2: '@ Jalan Tun Razak',
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyStack({
    required String image,
    required String text1,
    required String text2,
    required BuildContext context,
  }) {
    return propertyStack(
      image: image,
      text1: text1,
      text2: text2,
      width: 90.width,
      height: 12.height,
    );
  }
}
