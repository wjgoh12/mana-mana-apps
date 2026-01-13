import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

Widget StickyBottomBar({
  required int selectedQuantity,
  required String formattedPoints,
  required bool dataIsStale,
  required VoidCallback onNextPressed,
  required bool hasRoomSelected,
  required bool hasDatesSelected,
}) {
  final grey = const Color(0xFF606060);
  return Container(
    color: Colors.white,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSize.scaleWidth(15),
            vertical: ResponsiveSize.scaleHeight(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              // color: Color.fromARGB(255, 236, 247, 255),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveSize.scaleWidth(12)),
              child: Row(
                children: [
                  Text(
                    'Number of Rooms Selected:  ',
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeSmall,
                      fontFamily: AppFonts.outfit,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text('$selectedQuantity',
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeSmall,
                        fontFamily: AppFonts.outfit,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      )),
                  const Spacer(),
                  Text(
                    'Total: ',
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeSmall,
                      fontFamily: AppFonts.outfit,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '$formattedPoints points',
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeSmall,
                      fontFamily: AppFonts.outfit,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        // Next Button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: TextButton(
              onPressed:
                  dataIsStale ? null : onNextPressed, // 🆕 Disable if stale
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(
                  dataIsStale
                      ? Colors.grey.shade300
                      : (hasRoomSelected && hasDatesSelected
                          ? const Color(0xFFFFCF00)
                          : grey),
                ),
                fixedSize: WidgetStateProperty.all(const Size(300, 40)),
              ),
              child: Text(
                dataIsStale ? 'Updating Prices...' : 'Next',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  color: dataIsStale
                      ? Colors.grey.shade600
                      : (hasRoomSelected && hasDatesSelected
                          ? grey
                          : Colors.white),
                  fontSize: AppDimens.fontSizeBig,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ResponsiveSize.scaleHeight(20),
        ),
      ],
    ),
  );
}
