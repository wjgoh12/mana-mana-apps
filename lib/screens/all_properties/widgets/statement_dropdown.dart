import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/property_detail/view_model/property_detail_view_model.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class StatementDropdown extends StatefulWidget {
  final VoidCallback onBack;
  final List<String> yearOptions;
  final PropertyDetailVM model;

  const StatementDropdown({
    required this.onBack,
    required this.yearOptions,
    required this.model,
    Key? key,
  }) : super(key: key);

  @override
  _StatementDropdownState createState() => _StatementDropdownState();
}

class _StatementDropdownState extends State<StatementDropdown> {
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(10)),
      child: Container(
        // height: ResponsiveSize.scaleHeight(95),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 8),
              Text(
                'Statements',
                style: TextStyle(
                    fontSize: ResponsiveSize.text(18),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'outfit'),
              ),
              const Spacer(),
              const Text('Year',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'outfit')),
              const SizedBox(width: 8),
              DropdownButton2<String>(
                underline: const SizedBox(),
                buttonStyleData: ButtonStyleData(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 0.5),

                    //remove text underline of the dropdown bar
                  ),
                ),
                value: widget.model.selectedYearValue,
                hint: widget.model.yearItems.isNotEmpty
                    ? const Text(
                        'Select Year',
                        style: TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.none,
                            fontFamily: 'outfit'),
                      )
                    : const Text(
                        '-',
                        style: TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.none,
                            fontFamily: 'outfit'),
                      ),
                items: widget.yearOptions
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year,
                              style: const TextStyle(
                                  fontFamily: 'outfit',
                                  fontSize: 12,
                                  decoration: TextDecoration.none)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    widget.model.updateSelectedYear(val);
                  }
                },
                dropdownStyleData: DropdownStyleData(
                  offset: const Offset(0, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: const Border(
                      left: BorderSide(color: Colors.grey, width: 0.5),
                      right: BorderSide(color: Colors.grey, width: 0.5),
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                      // top: BorderSide.none  // so no border at top
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0),
                    //     blurRadius: 10,
                    //     offset: const Offset(0, -1),
                    //   ),
                    // ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
