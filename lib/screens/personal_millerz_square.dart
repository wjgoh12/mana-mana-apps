import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/dashboard.dart';
import 'package:mana_mana_app/screens/statement.dart';
import 'package:mana_mana_app/widgets/bar_chart.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/overall_revenue_container.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class PersonalMillerzSquare1Screen extends StatefulWidget {
  const PersonalMillerzSquare1Screen({super.key});

  @override
  State<PersonalMillerzSquare1Screen> createState() =>
      _PersonalMillerzSquare1ScreenState();
}

class _PersonalMillerzSquare1ScreenState
    extends State<PersonalMillerzSquare1Screen> {
  bool isClicked = false;
  final List<String> items = ['Type A', 'Type B', 'Type C', 'Type D'];
  final List<String> items2 = ['A-13-2', 'A-13-3', 'A-13-4', 'A-13-5'];
  final List<String> items3 =
      List.generate(8, (index) => (DateTime.now().year - index).toString());
  String? selectedValue;

  void toggleIsClicked() {
    setState(() {
      isClicked = !isClicked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      appBar: propertyAppBar(
          context,
          () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NewDashboardPage();
              }))),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 7.width, right: 7.width),
            child: Column(
              children: [
                SizedBox(height: 2.height),
                propertyStack(
                  image: 'millerz_square',
                  text1: 'Millerz Square',
                  text2: '@ Old Klang Road',
                  width: 86.width,
                  height: 12.height,
                ),
                SizedBox(height: 2.height),
                const OverallRevenueContainer(
                  text1: 'Overall Revenue',
                  text2: 'RM 9,999.99',
                  text3: '100%',
                  text4: 'Overall Rental Income',
                  text5: 'RM 8,888.88',
                  text6: '88%',
                  color: Color(0XFFFFFFFF),
                  backgroundColor: Color(0XFF4313E9),
                ),
                SizedBox(height: 2.height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientText1(
                      text: 'Type',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 15.fSize,
                        fontWeight: FontWeight.w700,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF2900B7), Color(0xFF120051)],
                      ),
                    ),
                    SizedBox(width: 1.width),
                    NewDropdownButton(list: items),
                    const Spacer(),
                    GradientText1(
                      text: 'Unit',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 15.fSize,
                        fontWeight: FontWeight.w700,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF2900B7), Color(0xFF120051)],
                      ),
                    ),
                    SizedBox(width: 1.width),
                    NewDropdownButton(list: items2),
                  ],
                ),
                SizedBox(height: 2.height),
                const OverallRevenueContainer(
                  text1: 'Unit Revenue',
                  text2: 'RM 2,399.99',
                  text3: '100%',
                  text4: 'Unit Rental Income',
                  text5: 'RM 2,399.00',
                  text6: '88%',
                  color: Color(0XFF4313E9),
                  backgroundColor: Color(0XFFFFFFFF),
                ),
                SizedBox(height: 1.height),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Statistics',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 20.fSize,
                      fontWeight: FontWeight.w800,
                      color: Color(0XFF4313E9),
                    ),
                  ),
                ),
                SizedBox(height: 1.height),
                _chartContainer(),
                SizedBox(height: 5.height),
                Row(
                  children: [
                    Text(
                      'Monthly Statement',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 20.fSize,
                        fontWeight: FontWeight.w800,
                        color: Color(0XFF4313E9),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return StatementPage();
                          }));
                        },
                        iconSize: 4.height,
                        icon: const Icon(Icons.arrow_right_rounded)),
                    SizedBox(
                      width: 12.width,
                      height: 14.width,
                      child: Image.asset(
                        'assets/images/patterns.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 3.height),
                Container(
                  width: 90.width,
                  decoration: BoxDecoration(
                    color: const Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0XFF120051).withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                        spreadRadius: -1.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 2.height,
                      left: 6.width,
                      right: 5.width,
                      bottom: 2.height,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GradientText1(
                              text: 'Year',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15.fSize,
                                fontWeight: FontWeight.w700,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF2900B7), Color(0xFF120051)],
                              ),
                            ),
                            SizedBox(width: 2.width),
                            NewDropdownButton(list: items3),
                          ],
                        ),
                        SizedBox(height: 1.height),
                        Row(
                          children: [
                            Text(
                              '01 - 30 April',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 15.fSize,
                                color: const Color(0XFF888888),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: toggleIsClicked,
                              child: Icon(
                                Icons.keyboard_arrow_down_outlined,
                                size: 4.height,
                                color: const Color(0XFF4313E9),
                              ),
                            ),
                          ],
                        ),
                        if (isClicked)
                          Row(
                            children: [
                              Text(
                                'SCARLETZ - 11-03 - APR2024',
                                style: TextStyle(
                                  color:
                                      const Color(0XFF0044CC).withOpacity(0.8),
                                  fontFamily: 'Open Sans',
                                  fontSize: 15.fSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'PDF',
                                style: TextStyle(
                                  color:
                                      const Color(0XFF0044CC).withOpacity(0.8),
                                  fontFamily: 'Open Sans',
                                  fontSize: 15.fSize,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0XFF0044CC).withOpacity(0.8)
                                ),
                              ),
                            ],
                          ),
                        Divider(
                          color: const Color(0XFF888888),
                          thickness: 0.5.fSize,
                        ),
                        _monthlyStatementRow('01 - 31 March',
                            Icons.keyboard_arrow_down_outlined),
                        Divider(
                          color: const Color(0XFF888888),
                          thickness: 0.5.fSize,
                        ),
                        _monthlyStatementRow('01 - 29 February',
                            Icons.keyboard_arrow_down_outlined),
                        Divider(
                          color: const Color(0XFF888888),
                          thickness: 0.5.fSize,
                        ),
                        _monthlyStatementRow('01 - 31 January',
                            Icons.keyboard_arrow_down_outlined),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 1.height,
                ),
                Row(
                  children: [
                    Text(
                      'Agreement(s)',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 20.fSize,
                        fontWeight: FontWeight.w800,
                        color: Color(0XFF4313E9),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 12.width,
                      height: 14.width,
                      child: Image.asset(
                        'assets/images/patterns.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 3.height),
                Container(
                  padding: EdgeInsets.only(left: 3.width, right: 3.width),
                  width: 86.width,
                  height: 6.height,
                  decoration: BoxDecoration(
                    color: const Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0XFF120051).withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                        spreadRadius: -1.0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'SCARLETZ - 11-03 - APR2024',
                        style: TextStyle(
                          color: const Color(0XFF0044CC).withOpacity(0.8),
                          fontFamily: 'Open Sans',
                          fontSize: 15.fSize,
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
                          decorationColor: const Color(0XFF0044CC).withOpacity(0.8)
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.height),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _monthlyStatementRow(String text, IconData icon) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w600,
            fontSize: 15.fSize,
            color: const Color(0XFF888888),
          ),
        ),
        const Spacer(),
        Icon(
          icon,
          size: 4.height,
          color: const Color(0XFF4313E9),
        ),
      ],
    );
  }
}

Widget _chartContainer() {
  return Container(
    width: 90.width,
    height: 30.height,
    decoration: BoxDecoration(
      color: const Color(0XFFFFFFFF),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0XFF120051).withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 3),
          spreadRadius: -1.0,
        ),
      ],
    ),
    child: SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.only(top: 2.height, left: 6.width, right: 5.width),
            child: Row(
              children: [
                Text(
                  'Monthly Overall Earnings',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 8.fSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0XFF4313E9),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 2.width,
                  height: 2.width,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradientColor1,
                  ),
                ),
                SizedBox(width: 1.width),
                Text(
                  'Overall Revenue',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 8.fSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0XFF888888),
                  ),
                ),
                SizedBox(width: 2.width),
                Container(
                  width: 2.width,
                  height: 2.width,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradientColor2,
                  ),
                ),
                SizedBox(width: 1.width),
                Text(
                  'Overall Revenue',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 8.fSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0XFF888888),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(-0.8, 0),
            child: Text(
              '(Ringgit in thousands)',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 6.fSize,
                fontWeight: FontWeight.w600,
                color: const Color(0XFF4313E9),
              ),
            ),
          ),
          BarChartSample7(),
          Padding(
            padding:
                EdgeInsets.only(left: 6.width, right: 5.width, top: 1.height),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 20.width),
                    SizedBox(width: 5.width),
                    SizedBox(
                      width: 25.width,
                      child: Text(
                        'Monthly Revenue',
                        style: TextStyle(
                          color: const Color(0XFF888888),
                          fontSize: 8.fSize,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 25.width,
                      child: Text(
                        'Monthly Rental Income',
                        style: TextStyle(
                          color: const Color(0XFF888888),
                          fontSize: 8.fSize,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.height),
                revenueChartRow('April 2024', 'RM 0', 'RM 0'),
                SizedBox(height: 0.5.height),
                Divider(
                  color: Color(0XFF888888),
                  thickness: 0.5.fSize,
                ),
                SizedBox(height: 0.5.height),
                revenueChartRow('Mar 2024', 'RM 4,562.40', 'RM 4,562.40'),
                SizedBox(height: 0.5.height),
                Divider(
                  color: Color(0XFF888888),
                  thickness: 0.5.fSize,
                ),
                SizedBox(height: 0.5.height),
                revenueChartRow('Feb 2024', 'RM 100,562.40', 'RM 100,562.40'),
                SizedBox(height: 0.5.height),
                Divider(
                  color: Color(0XFF888888),
                  thickness: 0.5.fSize,
                ),
                SizedBox(height: 0.5.height),
                revenueChartRow('Jan 2024', 'RM 60,562.40', 'RM 60,562.40'),
                SizedBox(height: 3.height),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

class NewDropdownButton extends StatefulWidget {
  const NewDropdownButton({super.key, required this.list});
  final List<String> list;

  @override
  State<NewDropdownButton> createState() => _NewDropdownButtonState();
}

class _NewDropdownButtonState extends State<NewDropdownButton> {
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          widget.list.first,
          style: TextStyle(
            color: const Color(0XFF4313E9),
            fontFamily: 'Open Sans',
            fontSize: 12.fSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        items: widget.list
            .map(
              (String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: const Color(0XFF4313E9),
                    fontFamily: 'Open Sans',
                    fontSize: 12.fSize,
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
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0XFFFFFFFF),
            border: Border.all(color: const Color(0XFF999999)),
            borderRadius: BorderRadius.circular(5),
          ),
          width: 20.width,
          height: 3.height,
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
}

Widget revenueChartRow(String text1, String text2, String text3) {
  return Row(
    children: [
      SizedBox(
        width: 20.width,
        child: Text(
          text1,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w600,
            fontSize: 15.fSize,
            color: const Color(0XFF888888),
          ),
        ),
      ),
      SizedBox(width: 5.width),
      SizedBox(
        width: 25.width,
        child: Text(
          text2,
          style: TextStyle(
            color: const Color(0XFF4313E9),
            fontSize: 15.fSize,
            fontWeight: FontWeight.w400,
            fontFamily: 'Open Sans',
          ),
        ),
      ),
      const Spacer(),
      SizedBox(
        width: 25.width,
        child: Text(
          text3,
          style: TextStyle(
            color: const Color(0XFF4313E9),
            fontSize: 15.fSize,
            fontWeight: FontWeight.w400,
            fontFamily: 'Open Sans',
          ),
        ),
      ),
    ],
  );
}
