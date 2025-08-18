import 'package:flutter/material.dart';

class ResponsiveScale {
  final BuildContext context;
  late double screenWidth;
  late double screenHeight;

  ResponsiveScale(this.context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  double width(double value) => (value / 375.0) * screenWidth; // base width
  double height(double value) => (value / 812.0) * screenHeight; // base height
  double font(double value) => (value / 812.0) * screenHeight; // font scaling
}
