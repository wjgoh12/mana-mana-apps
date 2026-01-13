import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

class TypeUnitSelectionDropdown2 extends StatefulWidget {
  final String label;
  final List<String> list;
  final Function(String?) onChanged;

  const TypeUnitSelectionDropdown2({
    required this.label,
    required this.list,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<TypeUnitSelectionDropdown2> createState() => _TypeUnitSelectionDropdownState();
}

class _TypeUnitSelectionDropdownState extends State<TypeUnitSelectionDropdown2> {
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  String _getMonthName(String month) {
    switch (month) {
      case '1':
        return 'Jan';
      case '2':
        return 'Feb';
      case '3':
        return 'Mar';
      case '4':
        return 'Apr';
      case '5':
        return 'May';
      case '6':
        return 'Jun';
      case '7':
        return 'Jul';
      case '8':
        return 'Aug';
      case '9':
        return 'Sep';
      case '10':
        return 'Oct';
      case '11':
        return 'Nov';
      case '12':
        return 'Dec';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate max width based on longest text
    double maxTextWidth = widget.list.fold(0.0, (maxWidth, item) {
      final textSpan = TextSpan(
        text: widget.label == "Month" ? _getMonthName(item) : item,
        style: TextStyle(
          fontSize: AppDimens.fontSizeBig,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      return max(maxWidth, textPainter.width);
    });

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          widget.list.isNotEmpty
              ? (widget.label == "Month" ? _getMonthName(widget.list.first) : widget.list.first.split(" (")[1].replaceAll(")", ""))
              : '',
          style: TextStyle(
            color: const Color(0XFF4313E9),
            fontFamily: 'Open Sans',
            fontSize: AppDimens.fontSizeBig,
            fontWeight: FontWeight.w600,
          ),
        ),
        items: widget.list
            .map(
              (String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  widget.label == "Month" ? _getMonthName(item) : item.split(" (")[1].replaceAll(")", ""),
                  style: TextStyle(
                    color: const Color(0XFF4313E9),
                    fontFamily: 'Open Sans',
                    fontSize: AppDimens.fontSizeBig,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
        value: selectedValue,
        onChanged: (String? value) {
          setState(() {
            selectedValue = value;
          });
          widget.onChanged(value);
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0XFFFFFFFF),
            border: Border.all(color: const Color(0XFF999999)),
            borderRadius: BorderRadius.circular(5),
          ),
          width: maxTextWidth + 40, // Add padding for icon and margins
          height: (3.5).height,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: maxTextWidth + 40,
        ),
        iconStyleData: IconStyleData(
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          iconSize: 2.height,
          iconEnabledColor: const Color(0XFF4313E9),
          iconDisabledColor: const Color(0XFF4313E9),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 3.height,
        ),
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
