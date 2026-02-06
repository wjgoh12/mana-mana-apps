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

  static final _tablet = 1100;
  static final _phone = 600;

  static bool isMobile(BuildContext context) => measureWidth(context) < _phone;

  static bool isTablet(BuildContext context) =>
      measureWidth(context) < _tablet && measureWidth(context) >= _phone;

  static bool isDesktop(BuildContext context) =>
      measureWidth(context) >= _tablet;

  static double measureWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    double width = measureWidth(context);
    if (width >= _tablet) {
      return desktop;
    } else if (width >= _phone) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}
