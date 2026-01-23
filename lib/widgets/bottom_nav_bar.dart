import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/all_properties/view/all_properties_view.dart';
import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/profile/view/owner_profile_v3_view.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:mana_mana_app/screens/dashboard/view/dashboard_view.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({
    super.key,
    this.currentIndex = 0, // Default index is 0
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          height:
              MediaQuery.of(context).size.width >= 600 ? 150.fSize : 100.fSize,
          width: constraints.maxWidth * 0.8,
          margin:
              EdgeInsets.symmetric(horizontal: 85.fSize, vertical: 20.fSize),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(children: [
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem('assets/images/Home.png', 'Home', 0),
                  _buildNavItem(
                      'assets/images/Properties.png', 'Properties', 1),
                  _buildNavItem('assets/images/Profile.png', 'Profile', 2),
                ],
              ),
            ),
          ]),
        );
      }),
    );
  }

  Widget _buildNavItem(dynamic icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    final double itemSize =
        MediaQuery.of(context).size.width >= 600 ? 140.fSize : 100.fSize;

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
            // Icon container
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.2 : 1.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 1.0 : 1.0,
                child: icon is IconData
                    ? Icon(
                        icon,
                        size: 24.fSize,
                        color: isSelected ? Colors.white : Colors.grey,
                      )
                    : isSelected
                        ? Image.asset(
                            icon,
                            width: 24.fSize,
                            height: 24.fSize,
                            color: AppColors.primaryYellow,
                          )
                        : ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.black, Colors.black],
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

            SizedBox(
              width: itemSize,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primaryYellow : Colors.transparent,
                  fontSize: AppDimens.fontSizeSmall,
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
                          colors: [Colors.black, Colors.black],
                        ).createShader(bounds),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: AppFonts.outfit,
                            color: Colors.white,
                            fontSize: AppDimens.fontSizeSmall,
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
