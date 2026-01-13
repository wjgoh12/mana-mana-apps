import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

class OccupancyPeriodDropdown extends StatefulWidget {
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const OccupancyPeriodDropdown(
      {super.key, required this.selectedValue, required this.onChanged});

  @override
  State<OccupancyPeriodDropdown> createState() =>
      _OccupancyPeriodDropdownState();
}

class _OccupancyPeriodDropdownState extends State<OccupancyPeriodDropdown> {
  String? selectedValue = 'Monthly';

  final period = {
    'Monthly': 'Monthly',
    'Quarterly': 'Quarterly',
    'Yearly': 'Yearly',
  };

  String getDisplayBarChart() {
    if (selectedValue == 'Monthly') {
      return 'Monthly';
    } else if (selectedValue == 'Quarterly') {
      return 'Quarterly';
    } else if (selectedValue == 'Yearly') {
      return 'Yearly';
    } else {
      return 'Select period';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(right: 10.fSize, top: 10.fSize),
        child: Container(
          // width: 130.fSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.fSize),
            color: const Color(0xFFF0F2FD),
          ),
          child: DropdownButton2<String>(
            underline: const SizedBox(),
            value: widget.selectedValue,
            onChanged: (value) {
              if (value != null) widget.onChanged(value);
            },
            items: period.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize: AppDimens.fontSizeBig,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
            dropdownStyleData: DropdownStyleData(
                //width: 130.fSize,
                offset: const Offset(0.5, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                  color: Color(0xFFF0F2FD),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
