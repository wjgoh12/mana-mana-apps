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
    super.key,
    this.currentIndex = 0,// Default index is 0
    this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;
  final NewDashboardVM model = NewDashboardVM();
  
    

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _selectedIndex = widget.currentIndex;
    }
  }

  void _onItemTapped(int index) {
      final List<Map<String, dynamic>> locationByMonth;
  
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      
      switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewDashboardV3()),
      //   ).then((_) {
      // setState(() {
      //   _selectedIndex = 0;
      // });
      // }
      );
        break;
        
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>AllPropertyScreen(locationByMonth: model.locationByMonth,
          ),
           ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Newsletter()),
      //   ).then((_) {
      // setState(() {
      //   _selectedIndex = 2;
      // });
      // }
      );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OwnerProfile()),
        ).then((_) {
      setState(() {
        _selectedIndex = 3;
      });
      });;
        break;
    }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 80,
        width: 320.fSize,
        margin: EdgeInsets.all(16.fSize),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem('assets/images/Home.png', 'Home', 0),
            _buildNavItem('assets/images/Properties.png', 'Properties', 1),
            _buildNavItem('assets/images/Newsletter.png', 'Newsletter', 2),
            _buildNavItem('assets/images/Profile.png', 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(dynamic icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70.fSize, // Fixed width instead of Expanded
        height: 70.fSize,
        decoration: isSelected ? 
        const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0XFFB82B7D),
              Color(0xFF3E51FF),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
            scale: isSelected ? 1.2 : 1.0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.6,
              child: icon is IconData
                  ? Icon(
                      icon,
                      size: 24.fSize,
                      color: isSelected ? Colors.white : Colors.white,
                    )
                    : isSelected
            ? Image.asset(
                icon,
                width: 24.fSize,
                height: 24.fSize,
                color: Colors.white,
              )
                  : ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0XFFB82B7D),
                          Color(0xFF3E51FF),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Image.asset(
                        icon,
                        width: 24.fSize,
                        height: 24.fSize,
                        
                      ),
                    ),
            ),
            ),
            
            SizedBox(height: 4.fSize),
            
            // Text with constrained width
            SizedBox(
              width: 70.fSize, // Fixed width for text
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFFFFF) : Colors.transparent,
                  fontSize: 10.fSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: isSelected
                  ? Text(
                      label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  : ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0XFFB82B7D),
                          Color(0xFF3E51FF),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ).createShader(bounds),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.fSize,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}