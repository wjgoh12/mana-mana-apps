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
  String? selectedMonth;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    // Initialize with current values from model
    selectedYear = widget.model.selectedYearValue;
    selectedMonth = widget.model.selectedMonthValue;
  }

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFF3E51FF),
            ),
          ),
          
          SizedBox(width: ResponsiveSize.scaleWidth(16)),
          
          // Monthly Dropdown
          Expanded(
            child: DropdownButton2<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: selectedMonth,
              hint: const Text('Monthly'),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: ResponsiveSize.text(14),
                color: Colors.black87,
              ),
              buttonStyleData: ButtonStyleData(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                offset: const Offset(0, -5),
              ),
              items: widget.monthOptions.map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text(
                    month,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: ResponsiveSize.text(14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
                if (value != null) {
                  widget.model.updateSelectedMonth(value);
                }
              },
            ),
          ),
          
          SizedBox(width: ResponsiveSize.scaleWidth(12)),
          
          // Year Dropdown
          Expanded(
            child: DropdownButton2<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: selectedYear,
              hint: const Text('Year'),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: ResponsiveSize.text(14),
                color: Colors.black87,
              ),
              buttonStyleData: ButtonStyleData(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                offset: const Offset(0, -5),
              ),
              items: widget.yearOptions.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(
                    year,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: ResponsiveSize.text(14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                });
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
