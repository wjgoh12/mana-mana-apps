import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/View/owner_profile.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/new_dashboard_v3.dart';
import 'package:mana_mana_app/screens/Profile/View/OwnerProfileScreen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;
  
  const CustomBottomNavigationBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CustomBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _selectedIndex = widget.currentIndex;
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      
      // Call the callback if provided
      if (widget.onTap != null) {
        widget.onTap!(index);
      }
      
      // Navigation logic
      _navigateToPage(context, index);
      
      print('Tapped index: $index');
    }
  }

  void _navigateToPage(BuildContext context, int index) {
    Widget? targetPage;
    switch (index) {
      case 0:
        // Navigate to Home/Dashboard
        // Navigator.pushNamedAndRemoveUntil(
        // context, 
        // 'screens/Dashboard_v3/View/new_dashboard_v3.dart', 
        // (route) => false,
        // );
        targetPage = const NewDashboardV3();
        break;
      case 1:
        // Navigate to Properties
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/properties', 
          (route) => false,
        );
        break;
      case 2:
        // Navigate to Newsletter
        // Navigator.pushNamedAndRemoveUntil(
        //   context, 
        //   '/newsletter', 
        //   (route) => false,
        // );
        break;
      case 3:
        // Navigate to Profile
        Navigator.pushNamedAndRemoveUntil(
          context, 
          'screens/Profile/View/OwnerProfileScreen', 
          (route) => false,
        );
         targetPage = const OwnerProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.fSize,
      width: 320.fSize,
      margin: EdgeInsets.all(16.fSize),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
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
          _buildNavItem(Icons.person, 'Profile', 3),
        ],
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
        decoration: isSelected ? const BoxDecoration(
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.fSize,
              height: 24.fSize,
              child: Center(
                child: isSelected
                  ? (icon is IconData 
                      ? Icon(
                          icon,
                          size: 18.fSize,
                          color: Colors.white,
                        )
                      : ImageIcon(
                          AssetImage(icon),
                          size: 18.fSize,
                          color: Colors.white,
                        ))
                  : ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0XFFB82B7D),
                          Color(0xFF3E51FF),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ).createShader(bounds),
                      child: icon is IconData 
                        ? Icon(
                            icon,
                            size: 18.fSize,
                            color: Colors.white,
                          )
                        : ImageIcon(
                            AssetImage(icon),
                            size: 18.fSize,
                            color: Colors.white,
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
                  fontSize: 8.fSize,
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