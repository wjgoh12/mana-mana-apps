import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle small = TextStyle(
    fontFamily: AppFonts.outfit,
    fontSize: AppDimens.fontSizeSmall,
  );

  static const TextStyle big = TextStyle(
    fontFamily: AppFonts.outfit,
    fontSize: AppDimens.fontSizeBig,
  );

  static TextStyle get(double size, {FontWeight? weight, Color? color}) {
    return TextStyle(
      fontFamily: AppFonts.outfit,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}
