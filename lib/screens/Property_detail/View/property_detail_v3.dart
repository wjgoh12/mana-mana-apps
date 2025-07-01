import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
                    child:
                    Column(
                      children: [
                        SizedBox(height: 30.fSize),
                        Text(locationByMonth.first['location'] ?? '',
                        style: const TextStyle(
                          fontSize: 30,
                        ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [  
                          Image.asset(
                            'assets/images/map_pin.png',
                          width: 14.fSize, 
                          height: 17.fSize
                          ),
                          Text(model.locationRoad),
                        ]
                        ),

                        SizedBox(height: 10.fSize),
                        DropdownButton<String>(
                        items: [
                        const DropdownMenuItem<String>(
                        value: 'Overview',
                        child: Text('Overview'),
                        ),
                          ...model.typeItems.map<DropdownMenuItem<String>>((String value) {
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
                                 String unitNo = newValue.split(" (")[1].replaceAll(")", "");
                                 model.updateSelectedTypeUnit(type, unitNo);
                               }
                             }
                           },
                           hint: const Text('Select Unit'),
                           value: model.selectedView == 'Overview' 
                             ? 'Overview'
                             : (model.selectedType != null && model.selectedUnitNo != null 
                                 ? '${model.selectedType} (${model.selectedUnitNo})'
                                 : null),
                         ),

                    SizedBox(height: 20.fSize),
                         
                         // Show different content based on selection
                         if (model.selectedView == 'Overview')
                         PropertyOverviewContainer(model: model, locationByMonth: locationByMonth)
                         else
                         Column(
                         children: [
                         UnitDetailsContainer(model: model),
                         SizedBox(height: 20.fSize),
                         MonthlyStatementContainer(model: model),
                           SizedBox(height: 20.fSize),
                             AnnualStatementContainer(model: model),
                              ],
                            ),

                     ],),
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
                      child:
                          CircularProgressIndicator(),
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
  const PropertyOverviewContainer({super.key, required this.model, required this.locationByMonth});

  @override
  Widget build(BuildContext context) {
     return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
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
                  child: Column(
                    children:[
                      Image.asset('assets/images/PropertyOverview1.png'),
                      const Text('Total Assets'),
                      Text('${locationByMonth.first['totalAssets'] ?? ''}'),
                      Text(DateFormat('MMMM yyyy').format(DateTime.now())),
                      ],
                  ),
                ),
              ),
              SizedBox(width: 10.width),
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
                  child: Column(
                    children:[
                      Image.asset('assets/images/PropertyOverview2.png'),
                    const Text('Total Assets'),
                    Text('${locationByMonth.first['totalAssets'] ?? ''}'),
                    Text(DateFormat('MMMM yyyy').format(DateTime.now())),
                    ],
                  ),
                ),
              ),
            ]
          ),

          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
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
                  child: Column(
                    children: [
                      Image.asset('assets/images/PropertyOverview3.png'),
                      const Text('Total Assets'),
                      Text('${locationByMonth.first['totalAssets'] ?? ''}'),
                      Text(DateFormat('MMMM yyyy').format(DateTime.now())),
                    ],
                  ),
                ),
              ),
            
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
                  child: Column(
                    children: [
                      Image.asset('assets/images/PropertyOverview4.png'),
                      const Text('Total Assets'),
                      Text('${locationByMonth.first['totalAssets'] ?? ''}'),
                      Text(DateFormat('MMMM yyyy').format(DateTime.now())),
                    ],
                  ),
                ),
              ),
              ]
            ),
          ),
        ],
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
