import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/all_properties/view/all_properties_view.dart';
import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/profile/view/owner_profile_v3_view.dart';
import 'package:mana_mana_app/screens/dashboard/view/dashboard_view.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
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

  String _getDeviceType(double width) {
    if (width < 600) {
      return 'mobile';
    } else if (width < 1024) {
      return 'tablet';
    } else {
      return 'web';
    }
  }

  double _getContainerHeight(String deviceType) {
    switch (deviceType) {
      case 'mobile':
        return 70.0;
      case 'tablet':
        return 80.0;
      case 'web':
        return 90.0;
      default:
        return 70.0;
    }
  }

  double _getItemSize(String deviceType) {
    switch (deviceType) {
      case 'mobile':
        return 60.0;
      case 'tablet':
        return 70.0;
      case 'web':
        return 80.0;
      default:
        return 60.0;
    }
  }

  double _getHorizontalMargin(String deviceType, double screenWidth) {
    switch (deviceType) {
      case 'mobile':
        return screenWidth * 0.1;
      case 'tablet':
        return screenWidth * 0.15;
      case 'web':
        return screenWidth * 0.25;
      default:
        return screenWidth * 0.05;
    }
  }

  double _getIconSize(String deviceType) {
    switch (deviceType) {
      case 'mobile':
        return 22.0;
      case 'tablet':
        return 26.0;
      case 'web':
        return 30.0;
      default:
        return 22.0;
    }
  }

  PageRouteBuilder _createRoute(Widget page,
      {String transitionType = 'slide'}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case 'fade':
            return FadeTransition(opacity: animation, child: child);

          case 'scale':
            return ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );

          case 'slideUp':
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );

          case 'slideLeft':
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );

          default:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );
        }
      },
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushReplacement(context,
              _createRoute(const NewDashboardV3(), transitionType: 'fade'));
          break;

        case 1:
          context.read<NewDashboardVM>();
          Navigator.pushReplacement(
              context,
              _createRoute(const AllPropertyNewScreen(),
                  transitionType: 'fade'));
          break;
        case 2:
          Navigator.pushReplacement(context,
              _createRoute(const OwnerProfile_v3(), transitionType: 'fade'));
          break;
        case 3:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final String deviceType = _getDeviceType(screenWidth);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalMargin(deviceType, screenWidth),
        vertical: 10.0,
      ),
      child: Container(
        height: _getContainerHeight(deviceType),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem('assets/images/Home.png', 'Home', 0, deviceType),
            _buildNavItem(
                'assets/images/Properties.png', 'Properties', 1, deviceType),
            _buildNavItem(
                'assets/images/Profile.png', 'Profile', 2, deviceType),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      dynamic icon, String label, int index, String deviceType) {
    bool isSelected = _selectedIndex == index;
    final double itemSize = _getItemSize(deviceType);
    final double iconSize = _getIconSize(deviceType);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: itemSize,
        height: itemSize,
        decoration: isSelected
            ? const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGrey,
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.2 : 1.0,
              child: icon is IconData
                  ? Icon(
                      icon,
                      size: iconSize,
                      color: isSelected ? Colors.white : Colors.grey,
                    )
                  : isSelected
                      ? Image.asset(
                          icon,
                          width: iconSize,
                          height: iconSize,
                          color: AppColors.primaryYellow,
                        )
                      : ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.black, Colors.black],
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Image.asset(
                            icon,
                            width: iconSize,
                            height: iconSize,
                          ),
                        ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryYellow,
                  fontSize: deviceType == 'mobile' ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.outfit,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}
