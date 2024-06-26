import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/bar_chart.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/overall_revenue_container.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class PersonalMillerzSquare1Screen extends StatelessWidget {
  const PersonalMillerzSquare1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> items = ['Type A', 'Type B', 'Type C', 'Type D'];
    final List<String> items2 = ['A-13-2', 'A-13-3', 'A-13-4', 'A-13-5'];
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      appBar: propertyAppBar(context, () {
        Navigator.of(context).pop();
      }),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 7.width, right: 7.width),
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                propertyStack(
                  image: 'millerz_square',
                  text1: 'Millerz Square',
                  text2: '@ Old Klang Road',
                  width: 86.width,
                  height: 12.height,
                ),
                SizedBox(
                  height: 0.5.height,
                ),
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
                SizedBox(
                  height: 0.5.height,
                ),
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
                        )),
                    SizedBox(width: 1.width),
                    NewDropdownButton(
                      list: items,
                    ),
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
                        )),
                    SizedBox(width: 1.width),
                    NewDropdownButton(
                      list: items2,
                    ),
                  ],
                ),
                SizedBox(
                  height: 1.height,
                ),
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
                SizedBox(
                  height: 1.height,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GradientText1(
                      text: 'Statistics',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 20.fSize,
                        fontWeight: FontWeight.w800,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF2900B7), Color(0xFF120051)],
                      )),
                ),
                SizedBox(
                  height: 1.height,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: const Color(0XFFFFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0XFF120051).withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                          spreadRadius:
                              -1.0, // Negative value to apply shadow only to the border
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 1.height, left: 5.width, right: 5.width),
                          child: Row(
                            children: [
                              Text(
                                'Monthly Overall Earnings',
                                style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 12.fSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0XFF4313E9)),
                              ),
                              const Spacer(),
                              Container(
                                width: 2.width,
                                height: 2.width,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: gradientColor1),
                              ),
                              SizedBox(
                                width: 1.width,
                              ),
                              Text(
                                'Overall Revenue',
                                style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 12.fSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0XFF888888)),
                              ),
                              SizedBox(
                                width: 2.width,
                              ),
                              Container(
                                width: 2.width,
                                height: 2.width,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: gradientColor2),
                              ),
                              SizedBox(
                                width: 1.width,
                              ),
                              Text(
                                'Overall Revenue',
                                style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 12.fSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0XFF888888)),
                              ),
                            ],
                          ),
                        ),
                        Align(alignment: const Alignment(-0.75,0,),
                              child: Text(
                                      '(in thousands)',
                                      style: TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontSize: 10.fSize,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0XFF4313E9)),
                                    ),
                            ),
                        BarChartSample7(),
                        
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//edit this
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
              fontWeight: FontWeight.w600),
        ),
        items: widget.list
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                        color: const Color(0XFF4313E9),
                        fontFamily: 'Open Sans',
                        fontSize: 12.fSize,
                        fontWeight: FontWeight.w600),
                  ),
                ))
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
              borderRadius: BorderRadius.circular(5)),
          width: 25.width,
          height: 3.height,
        ),
        iconStyleData: IconStyleData(
            icon: const Icon(Icons.keyboard_arrow_down_outlined),
            iconSize: 2.height,
            iconEnabledColor: const Color(0XFF4313E9),
            iconDisabledColor: const Color(0XFF4313E9)),
        menuItemStyleData: MenuItemStyleData(
          height: 4.height,
        ),
      ),
    );
  }
}
