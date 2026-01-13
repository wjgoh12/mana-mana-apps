import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

class DropdownButtonStatement extends StatelessWidget {
  const DropdownButtonStatement({
    super.key,
    required this.label,
    required this.list,
    required this.selectedValue,
    required this.width,
    required this.onChanged,
  });

  final String label;
  final double width;
  final List<String> list;
  final String? selectedValue;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
          style: TextStyle(
            fontSize: AppDimens.fontSizeBig,
            fontWeight: FontWeight.w700,
            fontFamily: 'Open Sans',
            color: const Color(0XFF0044CC).withOpacity(0.8),
          ),
          isExpanded: false,
          hint: Text(
            label,
            style: TextStyle(
              fontSize: AppDimens.fontSizeBig,
              fontWeight: FontWeight.w700,
              fontFamily: 'Open Sans',
              color: const Color(0XFF0044CC).withOpacity(0.8),
            ),
          ),
          items: list
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                    ),
                  ))
              .toList(),
          dropdownStyleData: DropdownStyleData(width: width),
          value: selectedValue,
          onChanged: onChanged,
          iconStyleData: IconStyleData(
            icon: Container(
              alignment: Alignment.center,
              width: 5.width,
              height: 3.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: const GradientBoxBorder(
                    width: 2,
                    gradient: LinearGradient(
                        colors: [Color(0XFF120051), Color(0XFF170DF2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
              ),
              child: GradientIcon(
                size: 2.height,
                offset: const Offset(0, 0),
                icon: Icons.keyboard_arrow_down_rounded,
                gradient: const LinearGradient(
                    colors: [Color(0XFF120051), Color(0XFF170DF2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
            ),
          ),
          buttonStyleData: ButtonStyleData(
            width: width,
            height: 3.height,
          ),
          menuItemStyleData: MenuItemStyleData(
            height: 3.height,
          )),
    );
  }
}
