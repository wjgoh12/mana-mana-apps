import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

final List<String> items = [
  'Overall',
  'MILLERZ',
  'SCARLETZ',
  'EXPRESSIONZ',
];
final List<String> items2 =
    List.generate(8, (index) => (DateTime.now().year - index).toString());

class StatementPage extends StatefulWidget {
  @override
  State<StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> {
  String? selectedValue;
  String? selectedYear;
  List<Map<String, String>> statements = [
    {
      'property': 'SCARLETZ',
      'date': '11-03 - APR2024',
      'month': 'APRIL 2024',
      'year': '2024'
    },
    {
      'property': 'MILLERZ',
      'date': '15-01 - APR2024',
      'month': 'APRIL 2024',
      'year': '2024'
    },
    {
      'property': 'SCARLETZ',
      'date': '11-03 - MAR2024',
      'month': 'MAY 2024',
      'year': '2024'
    },
    {
      'property': 'MILLERZ',
      'date': '15-01 - MAR2024',
      'month': 'MAY 2024',
      'year': '2024'
    },
    {
      'property': 'EXPRESSIONZ',
      'date': '22-01 - MAR2024',
      'month': 'MAY 2024',
      'year': '2024'
    },
    {
      'property': 'SCARLETZ',
      'date': '11-03 - FEB2023',
      'month': 'FEBRUARY 2023',
      'year': '2023'
    },
    {
      'property': 'MILLERZ',
      'date': '15-01 - JAN2023',
      'month': 'JANUARY 2023',
      'year': '2023'
    },
  ];
 @override
  void initState() {
    super.initState();
    selectedValue = 'Overall'; // Set initial value to 'Overall'
    selectedYear = null; // Set initial year to null (show all years)
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
            child: dropDownButton(
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
            child: dropDownButton(
              label: '2024',
              list: items2,
              selectedValue: selectedYear,
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                });
              },
            ),
          ),
          SizedBox(
            height: 2.height,
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 4.6.height,
            padding: EdgeInsets.only(left: 7.width),
            decoration: const BoxDecoration(color: Color(0XFF4313E9)),
            child: Text(
              'APRIL 2024',
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
          ...statements
              .where((statement) =>
                  statement['month'] == 'APRIL 2024' &&
                  (selectedYear == null || statement['year'] == selectedYear) &&
                  (selectedValue == 'Overall' ||
                      statement['property'] == selectedValue))
              .map(
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
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          SizedBox(
            height: 2.height,
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 4.6.height,
            padding: EdgeInsets.only(left: 7.width),
            decoration: const BoxDecoration(color: Color(0XFF4313E9)),
            child: Text(
              'MAY 2024',
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
          ...statements
              .where((statement) =>
                  statement['month'] == 'MAY 2024' &&
                  (selectedYear == null || statement['year'] == selectedYear) &&
                  (selectedValue == 'Overall' ||
                      statement['property'] == selectedValue))
              .map(
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
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
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

class dropDownButton extends StatefulWidget {
  dropDownButton(
      {super.key,
      required this.label,
      required this.list,
      required this.selectedValue,
      required this.onChanged});

  final String label;
  final List<String> list;
  final String? selectedValue;
  final Function(String?) onChanged;

  @override
  State<dropDownButton> createState() => _dropDownButtonState();
}

class _dropDownButtonState extends State<dropDownButton> {
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
          widget.label,
          style: TextStyle(
            fontSize: 15.fSize,
            fontWeight: FontWeight.w700,
            fontFamily: 'Open Sans',
            color: const Color(0XFF0044CC).withOpacity(0.8),
          ),
        ),
        items: widget.list
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
        dropdownStyleData: DropdownStyleData(width: 30.width),
        value: widget.selectedValue,
        onChanged: widget.onChanged,
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
          height: 3.height,
          width: 25.width,
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 3.height,
        ),
      ),
    );
  }
}
