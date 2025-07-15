import 'package:flutter/material.dart';
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
    final model = PropertyDetailVM();
    model.fetchData(locationByMonth);
    
                  

    //final ScrollController scrollController = ScrollController();
    bool isCollapsed = false;

    return ListenableBuilder(
      listenable: model,
      builder: (context, child) {
        return Scaffold(
  body: Stack(
    children: [
     NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
      final collapsedHeight = 290.fSize - kToolbarHeight;
      isCollapsed = scrollInfo.metrics.pixels > collapsedHeight;
      return false;
    },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 290.fSize,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/${locationByMonth.first['location'].toString().toUpperCase()}.png',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Image.asset('assets/images/GroupBack.png'),
                  ),
                ),
              ],
            ),
          ),

            
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top:Radius.circular(20)),
                color: Colors.white,
              ),
              padding: EdgeInsets.only(top: 30.fSize),
              child: Column(
                children: [
                  Text(locationByMonth.first['location'] ?? '', style: const TextStyle(fontSize: 30)),
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
                                        offset: const Offset(-12.5, -1),
                                        useSafeArea: true,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: const Border(
                                            left: BorderSide(color: Colors.grey, width: 0.5),
                                            right: BorderSide(color: Colors.grey, width: 0.5),
                                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(4),
                                            bottomRight: Radius.circular(4),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        maxHeight: 200,
                                        scrollbarTheme: ScrollbarThemeData(
                                          radius: const Radius.circular(40),
                                          thickness: WidgetStateProperty.all(6),
                                          thumbVisibility:
                                              WidgetStateProperty.all(true),
                                          trackVisibility: WidgetStateProperty.all(true),
                                        ),
                                      ),
                    
                                      menuItemStyleData: MenuItemStyleData(
                                        height: 50,
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 16),
                                        overlayColor:
                                            WidgetStateProperty.resolveWith<Color?>(
                                          (Set<WidgetState> states) {
                                            if (states.contains(WidgetState.hovered)) {
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
                            final parts = newValue.split(' (');
                            if (parts.length == 2) {
                              final type = parts[0].trim();
                              final unit = parts[1].replaceAll(')', '').trim();
                              
                              // Update the view and unit data
                              model.updateSelectedView('UnitDetails');
                              model.updateSelectedTypeUnit(type, unit);
                            }
                          }
                        }
                      },
                                hint: const Text('Select Unit'),
                                      value: model.selectedView == 'Overview'
                                          ? 'Overview'
                                          : (model.selectedType != null && model.selectedUnitNo != null)
                                          ? '${model.selectedType!.trim()} (${model.selectedUnitNo!.trim()})'
                                          : null,
                    ),
                  ),
                ],
              ),
              
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: model.selectedView != 'Overview',
            child: SingleChildScrollView(
              child: model.selectedView == 'Overview'
                ? PropertyOverviewContainer(model: model, locationByMonth: locationByMonth)
                : UnitDetailsContainer(model: model),
            ),
          ),
        ],
      ),
    ),
if (isCollapsed)
   Container(
      height: 85.fSize,
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: SafeArea(
        bottom: false, 
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Image.asset('assets/images/GroupBack.png'),
            ),
            const SizedBox(width: 8),
            const Text(
              'Property(s)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      
    ),
  ),

    ]
  ),
  
);

      }   
          );
        
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
            color: const Color(0XFF3E51FF).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 0),
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
    double getTotalNetAfterPOB() {
  return model.unitByMonth
      .where((unit) => unit.slocation == model.property)
      .fold(0.0, (sum, unit) => sum + (model.selectedUnitBlc ?? 0.0));
    }

    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),

      decoration: const BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),
          topRight: Radius.circular(20),  // Add top right radius

      ),),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(
              padding: const EdgeInsets.only(top:50),
              child: Container(
                 //margin: const EdgeInsets.only(bottom: 20),
                 width: 175,
                 height: 175,
                 decoration: BoxDecoration(
                   color: const Color(0XFFFFFFFF),
                   borderRadius: BorderRadius.circular(12),
                   boxShadow: [
                     BoxShadow(
                       color: Color(0xFF3E51FF).withOpacity(0.15),
                       blurRadius: 10,
                       offset: const Offset(0, 0),
                     ),
                   ],
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
                     Text('${model.isLoading ? 0 : model.unitByMonth.where((unit) =>
                        unit.slocation?.contains(locationByMonth.first['location']) == true
                      ).length-1}'),

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
            SizedBox(width: 17.fSize),
            Padding(
              padding: const EdgeInsets.only(top:50),
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                     color: const Color(0XFFFFFFFF),
                     borderRadius: BorderRadius.circular(12),
                     boxShadow: [
                       BoxShadow(
                         color: Color(0xFF3E51FF).withOpacity(0.15),
                         blurRadius: 10,
                         offset: const Offset(0, 0),
                       ),
                     ],
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
          SizedBox(height: 10.fSize),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Container(
                width: 175,
                height: 175,
                 decoration: BoxDecoration(
                     color: const Color(0XFFFFFFFF),
                     borderRadius: BorderRadius.circular(10),
                     boxShadow: [
                       BoxShadow(
                         color: Color(0xFF3E51FF).withOpacity(0.15),
                         blurRadius: 10,
                         offset: const Offset(0, 0),
                       ),
                     ],
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
                      //property overview
                      const Text('Monthly Profit',style:TextStyle(
                        fontSize:12,
                      ),),
                      RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: Transform.translate(
                                      offset: const Offset(0, -4), // adjust this value
                                      child: const Text(
                                        'RM',
                                        style: TextStyle(
                                          fontSize: 12, // smaller size
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text:'${model.locationByMonth.first['total'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 16,       
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
              SizedBox(width: 17.fSize),
              Container(
                width: 175,
                height: 175,
                 decoration: BoxDecoration(
                     color: const Color(0XFFFFFFFF),
                     borderRadius: BorderRadius.circular(12),
                     boxShadow: [
                       BoxShadow(
                         color: Color(0xFF3E51FF).withOpacity(0.15),
                         blurRadius: 10,
                         offset: const Offset(0, 0),
                       ),
                     ],
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
                      RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: Transform.translate(
                                      offset: const Offset(0, -4), // adjust this value
                                      child: const Text(
                                        'RM',
                                        style: TextStyle(
                                          fontSize: 12, // smaller size
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${model.locationByMonth.first['total'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 16,               // Larger for the amount
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
            ]),
          ),
        ],
      ),
    );
  }
}

class ContractDetailsContainer extends StatelessWidget {
  final PropertyDetailVM model;
  final List<Map<String, dynamic>> locationByMonth;

  const ContractDetailsContainer({
    super.key, 
    required this.model,
    required this.locationByMonth
  });
  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: model.fetchData(locationByMonth),
      builder: (context, snapshot) {
        final hasData = snapshot.connectionState == ConnectionState.done;
        final unitType = hasData && model.locationByMonth.isNotEmpty
            ? model.locationByMonth.first['unitType'] as String?
            : '';

    return Container(
      width: 400.fSize,
      height: 50.fSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.fSize),
        border: Border.all(color: const Color(0xFF5092FF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Padding(
              padding: EdgeInsets.only(left: 5, top: 5, bottom: 10),
              child: Text('Contract Type',
              style:TextStyle(
                fontSize: 10,
                ),
              ),
              
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 5, bottom: 10),
              child: Text( model.unitByMonth.first.stype ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF5092FF),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                
                width: 1,
                height: 30,
                child: Container(
                  color:  const Color(0xFF5092FF),
                ),
              ),
            ),
            const Padding(
              padding:EdgeInsets.only( top: 5, bottom: 10),
              child: Text('Contract End Date',
              style:TextStyle(
                fontSize: 10,
              )
              ),
            ),
            Padding(
              padding:const EdgeInsets.only( left:3,top: 5, bottom: 10),
              child: Text(
                DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(DateTime.now(),),
              style:const TextStyle(
                fontSize: 12,
                color:Color(0xFF5092FF),
                fontWeight: FontWeight.bold,
              )
              ),
            ),
          ],
        ),
      ),
      );
    
      },
    );

  }
}

class UnitDetailsContainer extends StatelessWidget {
  final PropertyDetailVM model;
  const UnitDetailsContainer({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:Colors.white,
      child: Column(
        children: [
          SizedBox(height:25.fSize),
          
          ContractDetailsContainer(model: model, locationByMonth: model.locationByMonth),
          Row(
            children: [
      
      
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:15,top:25),
                    child: Image.asset(
                      'assets/images/Group.png',
                      width:50,
                      height:50,
                      ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, top: 1),
                    child:Text('Owner(s)',
                    style:TextStyle(
                      fontSize: 12,
                    )),
                  )
                ],
              ),
      
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...model.ownerData
                          .where((owner) => owner.location == model.property)
                          .map((owner) => owner.accountname)
                          .toSet() // Remove duplicates
                          .map((ownerName) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      ownerName ?? 'Unknown Owner',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
      
            ],
          ),
          SizedBox(height: 2.height),
      
          Container(
            height: 125,
            color: Colors.white,
            child:Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 125,
                    height: 125,
                    
                    child: Container(
                      
                      decoration:  BoxDecoration(
                        color:Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        boxShadow:[
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                          )
                        ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:15),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/PropertyOverview2.png',
                              width:39.fSize,
                              height:22.fSize,
                              ),
                              const SizedBox(height: 15),
                              const Text('Occupancy Rate',
                      style:TextStyle(
                          fontSize:10,
                        ),),
                      
                      Text(
                        '${model.locationByMonth.first['occupancy']?? ''}% Active',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          )
                      ),
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
                  
                   SizedBox(
                    width: 125,
                    height: 125,
                    
                    child: Container(
                      decoration:  BoxDecoration(
                        color:Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        boxShadow:[
                          BoxShadow(
                            color: Color(0xFF3E51FF).withOpacity(0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 0),
                          )
                        ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:15),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/PropertyOverview3.png',
                              width:30.fSize,
                              height:30.fSize,
                              ),
                              const SizedBox(height: 13),
                              const Text('Monthly Profit',
                      style:TextStyle(
                          fontSize:10,
                        ),),
                      
                      RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: Transform.translate(
                                        offset: const Offset(0, -4), // adjust this value
                                        child: const Text(
                                          'RM',
                                          style: TextStyle(
                                            fontSize: 10, // smaller size
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                       text: '${model.selectedUnitPro.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0.00'}',
                                      style: const TextStyle(
                                        fontSize: 15,               // Larger for the amount
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
               
                 SizedBox(
                    width: 125,
                    height: 125,
                    
                    child: Container(
                      decoration:  BoxDecoration(
                        color:Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        boxShadow:[
                          BoxShadow(
                            color: Color(0xFF3E51FF).withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                          )
                        ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:15),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/PropertyOverview4.png',
                              width:30.fSize,
                              height:30.fSize,
                              ),
                              const SizedBox(height: 15),
                              const Text('Net After POB',
                              style:TextStyle(
                                  fontSize:9,
                                ),),
                              
                              RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: Transform.translate(
                                        offset: const Offset(0, -4), // adjust this value
                                        child: const Text(
                                          'RM',
                                          style: TextStyle(
                                            fontSize: 10, // smaller size
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${model.selectedUnitBlc.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0.00'}',
                                      style: const TextStyle(
                                        fontSize: 15,               // Larger for the amount
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                ]
              ),
            ),
            
          ),
      
          StickyEstatementBar(onBack: () => Navigator.pop(context),
          yearOptions: model.yearItems),
          //EStatementContainer(model: model),
          EStatementContainer(model: model)
          
        ],
      ),
    );
  }
}

class EStatementContainer extends StatelessWidget {
  final PropertyDetailVM model;
  const EStatementContainer({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (model.isDateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = model.unitByMonth;
    String monthNumberToName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'
  ];
  if (month >= 1 && month <= 12) {
    return months[month - 1];
  } else {
    return 'Unknown';
  }
}

    return Container(
      decoration:const BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        
        child: ListView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
      final item = items[i]; 
      
      if (model.selectedView != 'Overview' && 
          item.sunitno != model.selectedUnitNo) {
        return const SizedBox.shrink(); // Skip this item
      }
      
      return Row(
        children: [
          InkWell(
            hoverColor: Colors.grey.shade50,
            onTap: () => model.downloadPdfStatement(context),
            child: SizedBox(
              height: 50.fSize,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text('${item.slocation} ${item.sunitno} ${monthNumberToName(item.imonth ?? 0)} ${item.iyear}'),
                  ],
                ),
              ),
            ),
          )
        ],
      );
        },
      ),
      
      ),
    );

  }
}

class StickyEstatementBar extends StatefulWidget {
  final VoidCallback onBack;
  final List<String> yearOptions;

  const StickyEstatementBar({
    required this.onBack,
    required this.yearOptions,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StickyEstatementBarState createState() => _StickyEstatementBarState();
}

class _StickyEstatementBarState extends State<StickyEstatementBar> {
  String? _selectedYear;
  

  @override
  Widget build(BuildContext context) {

      return Container(
        height: 85.fSize,
        color: Colors.white,
        alignment: Alignment.centerLeft,
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 8),
              const Text(
                'eStatements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Text('Year'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedYear,
              hint: const Text('Select Year'),
              items: widget.yearOptions
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedYear = val);
                    // Optionally notify parent with callback or event
                  },
              ),
              const SizedBox(width: 8),
              ],
              ),
            
          )
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
