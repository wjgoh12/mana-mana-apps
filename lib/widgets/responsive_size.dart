import 'package:flutter/widgets.dart';

class ResponsiveSize {
  static late double screenWidth;
  static late double screenHeight;

  static const double baseWidth = 375.0;
  static const double baseHeight = 812.0;

  static void init(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 450.0) width = 450.0;
    screenWidth = width;
    double height = MediaQuery.of(context).size.height;
    if (height > 850.0) height = 850.0;
    screenHeight = height;
  }

  // Scale factor for width-based values
  static double scaleWidth(double width) {
    return (width / 375.0) * screenWidth;
  }

  // Scale factor for height-based values
  static double scaleHeight(double height) {
    return (height / 812.0) * screenHeight;
  }

  // Scale for text (use width scaling usually)
  static double text(double size) {
    return (size / 812.0) * screenHeight;
  }
}
