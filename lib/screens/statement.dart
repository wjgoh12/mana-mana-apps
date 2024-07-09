import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

final List<String> items = [
  'Overall',
  'Millerz',
  'Scarletz',
  'Expressionz',
];
final List<String> items2 =
    List.generate(8, (index) => (DateTime.now().year - index).toString());

Set<String> generateUnitNumbers() {
  final Set<String> unitNumbers = {};

  for (int i = 1; i <= 25; i++) {
    for (int j = 1; j <= 25; j++) {
      unitNumbers.add(
          '${i.toString().padLeft(2, '0')}-${j.toString().padLeft(2, '0')}');
    }
  }

  return unitNumbers;
}

class StatementPage extends StatefulWidget {
  @override
  State<StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> {
  String? selectedValue;
  String? selectedYear;
  String? selectedUnit;
  Set<Map<String, String>> statements = {
    {
      'property': 'Scarletz',
      'date': '11-03 - APR2024',
      'month': 'APRIL 2024',
      'year': '2024'
    },
    {
      'property': 'Millerz',
      'date': '15-01 - APR2024',
      'month': 'APRIL 2024',
      'year': '2024'
    },
    {
      'property': 'Scarletz',
      'date': '11-03 - MAR2024',
      'month': 'MAY 2024',
      'year': '2024'
    },
    {
      'property': 'Millerz',
      'date': '15-01 - MAR2024',
      'month': 'MAY 2024',
      'year': '2024'
    },
    {
      'property': 'Expressionz',
      'date': '22-01 - MAR2024',
      'month': 'MAY 2024',
      'year': '2024'
    },
    {
      'property': 'Scarletz',
      'date': '11-03 - FEB2023',
      'month': 'FEBRUARY 2023',
      'year': '2023'
    },
    {
      'property': 'Millerz',
      'date': '15-01 - JAN2023',
      'month': 'JANUARY 2023',
      'year': '2023'
    },
  };

  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredList = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    selectedValue = 'Overall';
    selectedYear = null;
    selectedUnit = null;
    _filteredList = generateUnitNumbers().toList(); // Convert the set to a list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.clear(); // Clear the TextEditingController
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onUnitNumberChanged(String? value) {
    setState(() {
      selectedUnit = value;
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  String _formatInput(String input) {
    // Remove any non-digit characters
    String cleanedInput = input.replaceAll(RegExp(r'[^0-9]'), '');

    // Split the input into two parts for the "xx-xx" format
    String part1 = cleanedInput.substring(0, 2);
    String part2 = cleanedInput.substring(2, 4);

    // Format the input as "xx-xx"
    return '${part1.padRight(2, '0')}-${part2.padRight(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      appBar: _appBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: DropdownButton(
              width: 30.width,
              label: 'Overall',
              list: items,
              selectedValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
          ),
          SizedBox(
            height: 4.height,
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 4.8.height,
            padding: EdgeInsets.only(left: 5.width),
            decoration: const BoxDecoration(color: Color(0XFFF4F6FF)),
            child: Row(
              children: [
                DropdownButton(
                  width: 20.width,
                  label: '2024',
                  list: items2,
                  selectedValue: selectedYear,
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value;
                    });
                  },
                ),
                const Spacer(),
                //unit button 
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    dropdownSearchData: DropdownSearchData(
                      searchController: _searchController,
                      searchInnerWidgetHeight: 3.height,
                      searchInnerWidget: TextField(
                        style: TextStyle(
                          color: const Color(0XFF4313E9),
                          fontFamily: 'Open Sans',
                          fontSize: 14.fSize,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorColor: const Color(0XFF4313E9),
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchController.text = _formatInput(value);
                            _searchController.selection =
                                TextSelection.collapsed(
                                    offset: _searchController.text.length);
                            _filteredList
                                .where((item) =>
                                    item.toLowerCase().contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Search Unit',
                          hintStyle: TextStyle(
                            color: const Color(0XFF4313E9),
                            fontFamily: 'Open Sans',
                            fontSize: 12.fSize,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 2.width),
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 15.fSize,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Open Sans',
                      color: const Color(0XFF0044CC).withOpacity(0.8),
                    ),
                    isExpanded: false,
                    hint: Text(
                      'Select Unit',
                      style: TextStyle(
                        fontSize: 15.fSize,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Open Sans',
                        color: const Color(0XFF0044CC).withOpacity(0.8),
                      ),
                    ),
                    items: _filteredList
                        .map((String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 15.fSize,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Open Sans',
                                  color: const Color(0XFF0044CC).withOpacity(0.8),
                                ),
                              ),
                            ))
                        .toList(),
                    dropdownStyleData:
                        DropdownStyleData(width: 20.width, maxHeight: 30.height),
                    value: selectedUnit,
                    onChanged: _onUnitNumberChanged,
                    iconStyleData: IconStyleData(
                      icon: Container(
                        alignment: Alignment.center,
                        width: 5.width,
                        height: 5.width,
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
                          size: 3.width,
                          offset: const Offset(0, 0),
                          icon: _isDropdownOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          gradient: const LinearGradient(
                              colors: [Color(0XFF120051), Color(0XFF170DF2)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                        ),
                      ),
                    ),
                    buttonStyleData: ButtonStyleData(
                      width: 20.width,
                      height: 3.height,
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      height: 3.height,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          ),
          SizedBox(
            height: 2.height,
          ),
          _monthContainer(
              'APRIL 2024',
              statements
                  .where((statement) =>
                      statement['month'] == 'APRIL 2024' &&
                      (selectedYear == null ||
                          statement['year'] == selectedYear) &&
                      (selectedValue == 'Overall' ||
                          statement['property'] == selectedValue) &&
                      (selectedUnit == null ||
                          statement['date']!.contains(selectedUnit!)))
                  .toList()),
          SizedBox(
            height: 2.height,
          ),
          _monthContainer(
              'MAY 2024',
              statements
                  .where((statement) =>
                      statement['month'] == 'MAY 2024' &&
                      (selectedYear == null ||
                          statement['year'] == selectedYear) &&
                      (selectedValue == 'Overall' ||
                          statement['property'] == selectedValue) &&
                      (selectedUnit == null ||
                          statement['date']!.contains(selectedUnit!)))
                  .toList()),
        ],
      ),
    );
  }

  Widget _monthContainer(
      String month, List<Map<String, String>> filteredStatements) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          width: double.infinity,
          height: 4.6.height,
          padding: EdgeInsets.only(left: 7.width),
          decoration: const BoxDecoration(color: Color(0XFF4313E9)),
          child: Text(
            month,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
              fontSize: 12.fSize,
              color: const Color(0XFFFFFFFF),
            ),
          ),
        ),
        SizedBox(
          height: 1.height,
        ),
        ...filteredStatements.map(
          (statement) => Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 4.8.height,
            padding: EdgeInsets.only(left: 7.width, right: 4.width),
            decoration: const BoxDecoration(color: Color(0XFFF4F6FF)),
            child: Row(
              children: [
                Text(
                  '${statement['property']} - ${statement['date']}',
                  style: TextStyle(
                    color: const Color(0XFF0044CC).withOpacity(0.8),
                    fontFamily: 'Open Sans',
                    fontSize: 12.fSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'PDF',
                  style: TextStyle(
                      color: const Color(0XFF0044CC).withOpacity(0.8),
                      fontFamily: 'Open Sans',
                      fontSize: 15.fSize,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          const Color(0XFF0044CC).withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0XFFFFFFFF).withOpacity(0),
      leadingWidth: 15.width,
      centerTitle: true,
      leading: Padding(
        padding: EdgeInsets.only(left: 7.width),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Image.asset(
            'assets/images/return.png',
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GradientText1(
            text: 'Statements',
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 20.fSize,
              fontWeight: FontWeight.w800,
            ),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF2900B7), Color(0xFF120051)],
            ),
          ),
          SizedBox(
            width: 5.width,
          ),
          SizedBox(
            width: 7.width,
            height: 7.width,
            child: Image.asset(
              'assets/images/patterns.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownButton extends StatelessWidget {
  const DropdownButton({
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
          fontSize: 15.fSize,
          fontWeight: FontWeight.w700,
          fontFamily: 'Open Sans',
          color: const Color(0XFF0044CC).withOpacity(0.8),
        ),
        isExpanded: false,
        hint: Text(
          label,
          style: TextStyle(
            fontSize: 15.fSize,
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
                    style: TextStyle(
                      fontSize: 15.fSize,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Open Sans',
                      color: const Color(0XFF0044CC).withOpacity(0.8),
                    ),
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
            height: 5.width,
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
              size: 3.width,
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
        ),
      ),
    );
  }
}
