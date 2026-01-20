import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:mana_mana_app/screens/statements/view_model/statement_view_model.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:mana_mana_app/screens/statements/view/dropdown_button.dart';

class StatementPage extends StatefulWidget {
  const StatementPage({super.key});

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
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 2.height),
          Align(
            alignment: Alignment.center,
            child: DropdownButtonStatement(
              width: 25.width,
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
                DropdownButtonStatement(
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
                          fontSize: AppDimens.fontSizeBig,
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
                                .where((item) => item
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
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
                            fontSize: AppDimens.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 2.width),
                        ),
                      ),
                    ),
                    isExpanded: false,
                    hint: Text(
                      'Select Unit',
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeSmall,
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
                                  fontSize: AppDimens.fontSizeBig,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Open Sans',
                                  color:
                                      const Color(0XFF0044CC).withOpacity(0.8),
                                ),
                              ),
                            ))
                        .toList(),
                    dropdownStyleData: DropdownStyleData(
                        width: 20.width, maxHeight: 30.height),
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
                                  colors: [
                                    Color(0XFF120051),
                                    Color(0XFF170DF2)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter)),
                        ),
                        child: GradientIcon(
                          size: 2.height,
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
              fontSize: AppDimens.fontSizeSmall,
              color: AppColors.white,
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
                    fontSize: AppDimens.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'PDF',
                  style: TextStyle(
                      color: const Color(0XFF0044CC).withOpacity(0.8),
                      fontFamily: 'Open Sans',
                      fontSize: AppDimens.fontSizeBig,
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
      backgroundColor: AppColors.white.withOpacity(0),
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
              fontSize: AppDimens.fontSizeBig,
              fontWeight: FontWeight.w800,
            ),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.primaryBlue, Color(0xFF120051)],
            ),
          ),
          SizedBox(
            width: 5.width,
          ),
          SizedBox(
            width: 7.width,
            height: 5.height,
            child: Image.asset(
              'assets/images/patterns.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
