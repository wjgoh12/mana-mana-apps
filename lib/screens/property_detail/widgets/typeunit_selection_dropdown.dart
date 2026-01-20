import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

class TypeUnitSelectionDropdown extends StatefulWidget {
  final String label;
  final List<String> list;
  final Function(String?) onChanged;

  const TypeUnitSelectionDropdown({
    required this.label,
    required this.list,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<TypeUnitSelectionDropdown> createState() =>
      _TypeUnitSelectionDropdownState();
}

class _TypeUnitSelectionDropdownState extends State<TypeUnitSelectionDropdown> {
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
  void initState() {
    super.initState();
    print('TypeUnitSelectionDropdown initialized');
    print('Initial list items: ${widget.list}');
  }

  @override
  void didUpdateWidget(TypeUnitSelectionDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list != widget.list) {
      print('Unit dropdown items updated');
      print('Previous items: ${oldWidget.list}');
      print('New items: ${widget.list}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building TypeUnitSelectionDropdown');
    print('Current list items: ${widget.list}');
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
              ? (widget.label == "Month"
                  ? _getMonthName(widget.list.first)
                  : widget.list.first)
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
                  widget.label == "Month" ? _getMonthName(item) : item,
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
          print('Unit dropdown value changed');
          print('Selected value: $value');
          setState(() {
            selectedValue = value;
          });
          print('State updated with new value: $selectedValue');
          widget.onChanged(value);
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: const Color(0XFF999999)),
            borderRadius: BorderRadius.circular(5),
          ),
          width: maxTextWidth + 60,
          height: (3.5).height,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: maxTextWidth + 60,
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
