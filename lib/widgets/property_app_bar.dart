import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

PreferredSizeWidget propertyAppBar(context, function) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: Container(
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 13.width,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.fSize,
              backgroundImage: const AssetImage(
                'assets/images/mana2logo1.png',
              ),
              backgroundColor: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: GradientText1(
                  text: 'Property(s)',
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
      ),
    ),
  );
}
