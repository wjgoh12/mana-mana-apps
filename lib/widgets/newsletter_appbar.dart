import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

PreferredSizeWidget newsletterAppBar(context, function) {
  return AppBar(
    backgroundColor: const Color(0XFFFFFFFF).withOpacity(0),
    automaticallyImplyLeading: false,
    leadingWidth: 15.width,
    centerTitle: true,
    
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
             radius: 22.fSize, // or tweak size as needed
             backgroundImage: const AssetImage(
              'assets/images/mana2logo.png',),
             backgroundColor: Colors.transparent,
             ),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: GradientText1(
              text: 'Newsletter',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 20.fSize,
                fontWeight: FontWeight.w800,
              ),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
              )),
        ),
      ],
    ),
  );
}