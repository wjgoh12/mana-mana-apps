import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

// This size work fine on my design, maybe you need some customization depends on your design

  static final _tablet = 1100;
  static final _phone = 850;

  // This isMobile, isTablet, isDesktop help us later
  static bool isMobile(BuildContext context) => measureWidth(context) < _phone;

  static bool isTablet(BuildContext context) =>
      measureWidth(context) < _tablet && measureWidth(context) >= _phone;

  static bool isDesktop(BuildContext context) => measureWidth(context) >= _tablet;

  static double measureWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    double width = measureWidth(context);
    // print("width $width");
    // If our width is more than 1100 then we consider it a desktop
    if (width >= _tablet) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (width >= _phone) {
      return tablet ?? desktop;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}
