import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:mana_mana_app/screens/Property_detail/View/Widget/typeunit_selection_dropdown.dart';

import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';

import 'package:mana_mana_app/widgets/size_utils.dart';

class PropertyDetail extends StatelessWidget {
  final List<Map<String, dynamic>> locationByMonth;
  const PropertyDetail({required this.locationByMonth, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PropertyDetailVM model = PropertyDetailVM();
    model.fetchData(locationByMonth);
    return ListenableBuilder(
        listenable: model,
        builder: (context, _) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: const Color(0XFFFFFFFF),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/${locationByMonth.first['location'].toString().toUpperCase()}.png',
                        width: 450.fSize,
                        height: 290.fSize,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 25.fSize),
                    ],
                  ),
                  Positioned(
                    top: 250.fSize,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: 450.fSize,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: const Color(0XFFFFFFFF),
                        //overlay with the image on top of it about 10 percent
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 30.fSize),
                          Text(
                            locationByMonth.first['location'] ?? '',
                            style: const TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/map_pin.png',
                                  width: 14.fSize, height: 17.fSize),
                              Text(model.locationRoad),
                            ],
                          ),

                          SizedBox(height: 10.fSize),
                          Container(
                            width: 370.fSize,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownStyleData: DropdownStyleData(
                                width: 370.fSize,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                maxHeight: 300,
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness: WidgetStateProperty.all(6),
                                  thumbVisibility:
                                      WidgetStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: MenuItemStyleData(
                                height: 50,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                overlayColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.hovered)) {
                                      return Colors.blue.withOpacity(0.1);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                              ),
                              buttonStyleData: const ButtonStyleData(
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: 'Overview',
                                  child: Text('Overview'),
                                ),
                                ...model.typeItems
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  if (newValue == 'Overview') {
                                    model.updateSelectedView('Overview');
                                  } else {
                                    String type = newValue.split(" (")[0];
                                    String unitNo = newValue
                                        .split(" (")[1]
                                        .replaceAll(")", "");
                                    model.updateSelectedTypeUnit(type, unitNo);
                                  }
                                }
                              },
                              hint: const Text('Select Unit'),
                              value: model.selectedView == 'Overview'
                                  ? 'Overview'
                                  : (model.selectedType != null &&
                                          model.selectedUnitNo != null
                                      ? '${model.selectedType} (${model.selectedUnitNo})'
                                      : null),
                            ),
                          ),

                          SizedBox(height: 20.fSize),

                          // Show different content based on selection
                          if (model.selectedView == 'Overview')
                            PropertyOverviewContainer(
                                model: model, locationByMonth: locationByMonth)
                          else
                            Column(
                              children: [
                                UnitDetailsContainer(model: model),
                                SizedBox(height: 20.fSize),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 10,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Image.asset('assets/images/GroupBack.png'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class MonthlyStatementContainer extends StatelessWidget {
  final PropertyDetailVM model;
  const MonthlyStatementContainer({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: EdgeInsets.fromLTRB(6.width, 3.height, 5.width, 2.height),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (model.isLoading) {
                  // Check if data is still loading
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child:
                          CircularProgressIndicator(), // Display a loading spinner
                    ),
                  );
                }
                return model.isDateLoading
                    ? const CircularProgressIndicator()
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildGradientText('Year'),
                              SizedBox(width: 2.width),
                              TypeUnitSelectionDropdown(
                                label: 'Year',
                                list: model.yearItems,
                                onChanged: (_) {
                                  model.updateSelectedYear(_!);
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildGradientText('Month'),
                              SizedBox(width: 2.width),
                              model.isMonthLoadng
                                  ? const CircularProgressIndicator() // Display a loading spinner
                                  : TypeUnitSelectionDropdown(
                                      label: 'Month',
                                      list: model.monthItems,
                                      onChanged: (_) {
                                        model.updateSelectedMonth(_!);
                                      },
                                    ),
                            ],
                          )
                        ],
                      );
              },
            ),
            SizedBox(height: 4.height),
            ElevatedButton(
              onPressed: () => model.downloadPdfStatement(context),
              // () async {
              // print(property);
              // print(selectedYearValue);
              // print(selectedMonthValue);
              // print(selectedType);
              // print(selectedUnitNo);
              // await ownerPropertyList_repository.downloadPdfStatement(
              //     context,
              //     property,
              //     selectedYearValue,
              //     selectedMonthValue,
              //     selectedType,
              //     selectedUnitNo);
              // },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF4313E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.width, vertical: 0.5.height),
                child: model.isDownloading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Download PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )
            // _buildMonthlyStatementContent(),
          ],
        ),
      ),
    );
  }
}

class AnnualStatementContainer extends StatelessWidget {
  final PropertyDetailVM model;
  const AnnualStatementContainer({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: EdgeInsets.fromLTRB(6.width, 3.height, 5.width, 2.height),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (model.isLoading) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return model.isDateLoading
                    ? const CircularProgressIndicator()
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildGradientText('Year'),
                              SizedBox(width: 2.width),
                              TypeUnitSelectionDropdown(
                                label: 'Year',
                                list: model.yearItems,
                                onChanged: (_) {
                                  model.updateSelectedAnnualYear(_!);
                                },
                              ),
                            ],
                          ),
                          // Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     _buildGradientText('Month'),
                          //     SizedBox(width: 2.width),
                          //     model.isMonthLoadng
                          //         ? const CircularProgressIndicator() // Display a loading spinner
                          //         : TypeUnitSelectionDropdown(
                          //             label: 'Month',
                          //             list: model.monthItems,
                          //             onChanged: (_) {
                          //               model.updateSelectedMonth(_!);
                          //             },
                          //           ),
                          //   ],
                          // )
                        ],
                      );
              },
            ),
            SizedBox(height: 4.height),
            ElevatedButton(
              onPressed: () => model.downloadAnnualPdfStatement(context),
              // () async {
              // print(property);
              // print(selectedYearValue);
              // print(selectedMonthValue);
              // print(selectedType);
              // print(selectedUnitNo);
              // await ownerPropertyList_repository.downloadPdfStatement(
              //     context,
              //     property,
              //     selectedYearValue,
              //     selectedMonthValue,
              //     selectedType,
              //     selectedUnitNo);
              // },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF4313E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.width, vertical: 0.5.height),
                child: model.isAnnualDownloading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Download PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )
            // _buildMonthlyStatementContent(),
          ],
        ),
      ),
    );
  }
}

class PropertyOverviewContainer extends StatelessWidget {
  final PropertyDetailVM model;
  final List<Map<String, dynamic>> locationByMonth;
  const PropertyOverviewContainer(
      {super.key, required this.model, required this.locationByMonth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SizedBox(
              width: 175,
              height: 175,
              child: Card(
                color: const Color(0XFFFFFFFF),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(

                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:30),
                      child: Image.asset(
                        'assets/images/PropertyOverview1.png',
                        width: 67.fSize,
                        height: 59.fSize,
                      ),
                    ),
                    SizedBox(height: 5.fSize),
                    const Text(
                      'Total Assets',
                      style:TextStyle(
                        fontSize:12,
                      ),
                      ),
                    Text('${locationByMonth.first['totalUnits'] ?? ''}'),
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 21.fSize),
            SizedBox(
              width: 175,
              height: 175,
              child: Card(
                color: const Color(0XFFFFFFFF),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top:45),
                  child: Column(
                    children: [
                      SizedBox(height: 5.fSize),
                      Image.asset(
                        'assets/images/PropertyOverview2.png',
                        width: 65.fSize,
                        height: 38.fSize,
                      ),
                      SizedBox(height:5.fSize),
                      const Text('Occupancy Rate',
                      style:TextStyle(
                          fontSize:12,
                        ),),
                      
                      Text('${locationByMonth.first['totalAssets'] ?? ''}'),
                      Text(DateFormat('MMMM yyyy').format(DateTime.now(),
                      ),
                      style: const TextStyle(
                            fontSize: 10,
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
          SizedBox(height: 20.fSize),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(children: [
              SizedBox(
                width: 175,
                height: 175,
                child: Card(
                  color: const Color(0XFFFFFFFF),
                  elevation: 5,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top:30),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/PropertyOverview3.png',
                          width: 59.fSize,
                        height: 58.fSize,
                        ),
                        const Text('Monthly Profit',style:TextStyle(
                          fontSize:12,
                        ),),
                        Text('${locationByMonth.first['totalAssets'] ?? ''}'),
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 21.fSize),
              SizedBox(
                width: 175,
                height: 175,
                child: Card(
                  color: const Color(0XFFFFFFFF),
                  elevation: 5,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top:30),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/PropertyOverview4.png',
                        width: 57.fSize,
                          height: 59.fSize,
                          ),
                        const Text('Total Net After POB',
                        style:TextStyle(
                          fontSize:12,
                        ),
                        ),
                        Text('${locationByMonth.first['totalAssets'] ?? ''}'),
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 10,
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class ContractDetailsContainer extends StatelessWidget {
  final PropertyDetailVM model;
  const ContractDetailsContainer({super.key, required this.model});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 50,
    );
  }
}

class UnitDetailsContainer extends StatelessWidget {
  final PropertyDetailVM model;
  const UnitDetailsContainer({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: EdgeInsets.fromLTRB(6.width, 3.height, 5.width, 3.height),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
        ),
      ),
    );
  }
}

Widget _buildGradientText(String text) {
  return GradientText1(
    text: text,
    style: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 17.fSize,
      fontWeight: FontWeight.w700,
    ),
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF2900B7), Color(0xFF120051)],
    ),
  );
}
