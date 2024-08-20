import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

PreferredSizeWidget propertyAppBar(context, function) {
  return AppBar(
    backgroundColor: const Color(0XFFFFFFFF).withOpacity(0),
    leadingWidth: 15.width,
    centerTitle: true,
    leading: Padding(
      padding: EdgeInsets.only(left: 7.width),
      child: InkWell(
          onTap: function,
          child: Image.asset(
            'assets/images/return.png',
          )),
    ),
    title: GradientText1(
        text: 'Properties',
        style: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 20.fSize,
          fontWeight: FontWeight.w800,
        ),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF2900B7), Color(0xFF120051)],
        )),
  );
}