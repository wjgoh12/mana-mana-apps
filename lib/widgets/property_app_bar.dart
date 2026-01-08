import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

PreferredSizeWidget propertyAppBar(context, function) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: Container(
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
              child: Text(
                'Property(s)',
                style: TextStyle(
                  color: const Color(0xFF000241),
                  fontFamily: 'outfit',
                  fontSize: ResponsiveSize.text(20),
                  fontWeight: FontWeight.w700,
                ),
              ),
              // GradientText1(
              //   text: 'Property(s)',
              //   style: TextStyle(
              //     fontFamily: 'outfit',
              //     fontSize: ResponsiveSize.text(20),
              //     fontWeight: FontWeight.w800,
              //   ),
              //   gradient: const LinearGradient(
              //     begin: Alignment.centerLeft,
              //     end: Alignment.centerRight,
              //     colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
              //   ),
              // ),
            ),
          ],
        ),
      ),
    ),
  );
}
