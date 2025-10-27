import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class EnhancedStatementDropdown extends StatefulWidget {
  final VoidCallback onBack;
  final List<String> yearOptions;
  final List<String> monthOptions;
  final PropertyDetailVM model;

  const EnhancedStatementDropdown({
    required this.onBack,
    required this.yearOptions,
    required this.monthOptions,
    required this.model,
    Key? key,
  }) : super(key: key);

  @override
  _EnhancedStatementDropdownState createState() =>
      _EnhancedStatementDropdownState();
}

class _EnhancedStatementDropdownState extends State<EnhancedStatementDropdown> {
  @override
  void initState() {
    super.initState();
    // Don't do anything here, let the model control the state
  }

  String getMonthName(String month) {
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
        return month;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read values directly from model - no local state
    final selectedYear = widget.model.selectedYearValue;
    final selectedMonth = widget.model.selectedMonthValue;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(16)),
      child: Row(
        children: [
          // Statements Title
          Text(
            'Statements',
            style: TextStyle(
              fontSize: ResponsiveSize.text(16),
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              // color: const Color(0xFF3E51FF),
            ),
          ),

          SizedBox(width: ResponsiveSize.scaleWidth(16)),

          // Monthly Dropdown
          Expanded(
            child: DropdownButton2<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: selectedMonth,
              hint: Text(selectedMonth == null ? 'All' : 'Month'),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: ResponsiveSize.text(13),
                color: Color(0xFF606060),
              ),
              buttonStyleData: ButtonStyleData(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade500, width: 1),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  // Removed border for seamless look
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 300, // Set max height to prevent overflow
                isOverButton:
                    false, // Display below the button instead of overlaying
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(ResponsiveSize.scaleWidth(15)),
                    bottomRight: Radius.circular(ResponsiveSize.scaleWidth(15)),
                  ),
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade500),
                    right: BorderSide(color: Colors.grey.shade500),
                    bottom: BorderSide(color: Colors.grey.shade500),
                    top: BorderSide
                        .none, // No top border for seamless connection
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                offset: const Offset(0, 6),
              ),
              items: [
                // Add "All" option
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    'All',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: ResponsiveSize.text(13),
                    ),
                  ),
                ),
                // Add individual month options
                ...widget.monthOptions.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(
                      getMonthName(month),
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: ResponsiveSize.text(13),
                      ),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                print('📅 Month dropdown changed to: $value');
                widget.model.updateSelectedMonth(value);
              },
            ),
          ),

          SizedBox(width: ResponsiveSize.scaleWidth(10)),

          // Year Dropdown
          Expanded(
            child: DropdownButton2<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: selectedYear,
              hint: const Text('Year'),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: ResponsiveSize.text(12),
                color: Color(0xFF606060),
              ),
              buttonStyleData: ButtonStyleData(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade500, width: 1),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 300,
                isOverButton: false,
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(ResponsiveSize.scaleWidth(15)),
                    bottomRight: Radius.circular(ResponsiveSize.scaleWidth(15)),
                  ),
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade500),
                    right: BorderSide(color: Colors.grey.shade500),
                    bottom: BorderSide(color: Colors.grey.shade500),
                    top: BorderSide
                        .none, // No top border for seamless connection
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                offset: const Offset(0, 7),
              ),
              items: widget.yearOptions.isEmpty
                  ? [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          'No Data',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: ResponsiveSize.text(12),
                          ),
                        ),
                      ),
                    ]
                  : widget.yearOptions.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(
                          year,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: ResponsiveSize.text(12),
                          ),
                        ),
                      );
                    }).toList(),
              onChanged: widget.yearOptions.isEmpty
                  ? null
                  : (value) {
                      print('📅 Year dropdown changed to: $value');
                      if (value != null) {
                        widget.model.updateSelectedYear(value);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
