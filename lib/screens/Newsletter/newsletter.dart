import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/newsletter_appbar.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';

class Newsletter extends StatelessWidget {
  const Newsletter({super.key});

  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: newsletterAppBar(context, () {}),

    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: const BottomNavBar(currentIndex: 2,),
        
  );
}
}

