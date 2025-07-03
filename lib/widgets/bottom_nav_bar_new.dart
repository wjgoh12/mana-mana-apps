import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';
import 'package:mana_mana_app/screens/Profile/View/owner_profile.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/new_dashboard_v3.dart';
import 'package:mana_mana_app/screens/Profile/View/owner_profile.dart';
class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({
    Key? key,
    this.currentIndex = 0,
    this.onTap,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      body: IndexedStack(
        index: widget.currentIndex,
        children: _navigatorKeys.values.map((key) => Navigator(
          key: key,
          onPopPage: (route, result) {
            return false;
          },
          pages: [
            MaterialPage(
              key: UniqueKey(),
              child: const NewDashboardV3(),
              maintainState: true, 
            ),
            const MaterialPage(
              child: AllPropertyScreen(locationByMonth: [],), 
            ),
            const MaterialPage(
              child: Newsletter()
            ),
            const MaterialPage(
              child: OwnerProfile()
            ),
          ],
        )).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.currentIndex,
        onTap: (index) {
          setState(() {
            widget.onTap?.call(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Home.png'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Properties.png'),
            label: 'Properties',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Newsletter.png'),
            label: 'Newsletter',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Profile.png'),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}