import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/new_bar_chart.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

Widget topBar(context, function) {
  double responsiveFont(double value) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (value / 812.0) * screenHeight; // base height
  }

  return PreferredSize(
    preferredSize: Size(MediaQuery.of(context).size.width, 60),
    child: ClipRRect(
      child: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 13.width,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25, // or tweak size as needed
              backgroundImage: AssetImage(
                'assets/images/mana2logo1.png',
              ),
              backgroundColor: Colors.transparent,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 10),
              child: GradientText1(
                text: 'Owner\'s Portal',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => print('Notification button pressed'),
            icon: Image.asset(
              'assets/images/Notification.png',
              width: 50,
              //opacity: const AlwaysStoppedAnimation(0),
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    ),
  );
}
