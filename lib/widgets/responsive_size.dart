import 'package:flutter/widgets.dart';

class ResponsiveSize {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  // Scale factor for text
  static double text(double size) {
    return size * blockWidth / 3.8; // adjust to your needs
  }

  // Scale factor for spacing or widgets
  static double scaleWidth(double width) {
    return width * blockWidth;
  }

  static double scaleHeight(double height) {
    return height * blockHeight;
  }
}
