import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';


class MillerzSquare1Screen extends StatelessWidget {
  const MillerzSquare1Screen({super.key});

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
              image:'millerz_square',
              text1: 'Millerz Square',
              text2: '@ Old Klang Road',
              width:90.width,
              height:12.height,
            ),
            const SizedBox(
              height: 20,
            ),
            propertyStack(
              image:'scarletz_suites',
              text1:'Scarletz Suites',
              text2:'@ KL City Centre',
              width:90.width,
              height:12.height,
            ),
            const SizedBox(
              height: 20,
            ),
            propertyStack(
              image:'expressionz',
              text1:'Expressionz Suites',
              text2:'@ Jalan Tun Razak',
              width:90.width,
              height:12.height,
            ),
          ],
        ),
      ),
    );
  }
}




