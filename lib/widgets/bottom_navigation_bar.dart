import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add your navigation logic here
    print('Tapped index: $index');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.fSize,
      width: 320.fSize,
      margin: EdgeInsets.all(16.fSize),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('assets/images/Home.png', 'Home', 0),

          _buildNavItem('assets/images/Properties.png', 'Properties', 1),
          _buildNavItem(Icons.newspaper, 'Newsletter', 2),
          _buildNavItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(dynamic icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.fSize, horizontal: 12.fSize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon is IconData 
              ? Icon(
                  icon,
                  color: isSelected ? const Color(0xFF4313E9) : Colors.grey,
                  size: 24.fSize,
                )
              : ImageIcon(
                  AssetImage(icon), // icon is the asset path string
                  size: 24.fSize,
                  color: isSelected ? const Color(0xFF4313E9) : Colors.grey,
                ),
            SizedBox(height: 4.fSize),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4313E9) : Colors.grey,
                fontSize: 12.fSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
