import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/statistic_table_v3.dart';

class OverviewCard extends StatelessWidget {
  final NewDashboardVM model;
  const OverviewCard({required this.model, super.key});

String getTotalProfit() {
  final profit = model.overallProfit.toString();
  return profit;
}
  @override
  Widget build(BuildContext context) {

    final uniqueLocations = model.totalByMonth
    .map((e) => e['slocation'])   
    .toSet()                      
    .toList();

final locationCount = uniqueLocations.length;


    return SizedBox(
      width: double.infinity,
      child: Row(
        
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                //1st 
                Card(
                  
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFF5092FF),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 130.fSize,
                   child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Stack(
                        children: [
                      Positioned(
                        left: 10,
                        top: 10,
                        child: CircleAvatar(
                          radius: 20.fSize,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            'assets/images/OverviewProperty.png',
                            width: 18.fSize,
                            height: 22.fSize,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        
                        children: [
                          
                          Padding(
                            padding:const EdgeInsets.only(right:15),
                              child:
                              Text(
                                '$locationCount',
                                //call total number of locations
                                //total Properties
                      
                                style: TextStyle(
                                  fontSize: 40.fSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                        
                          ),
                          const SizedBox(width: 1), // spacing between text and image
                        ],
                      )
                        ]
                      ),
                      Padding(
                        padding:const EdgeInsets.only(left: 10),
                      child:Text(
                        'Total Properties', 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.fSize,
                          ),
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                      child:Text(
                        'Managed: ', 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.fSize,
                          fontWeight: FontWeight.bold,
                          ),
                      ),
                      ),
                    ]
                   ),
                  ),
                ),
                  
                //2nd
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFFFFE7B8),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 83.fSize,
                    child: Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft, // Vertically center, left-aligned
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                                  child: CircleAvatar(
                                  radius: 23.fSize, 
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    'assets/images/OverviewOccupancy.png',
                                    width:35.fSize,
                                    height:25.fSize,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                                padding: EdgeInsets.only(left:8,top:10),
                                child: Text(
                                  'Occupancy Rate',
                                  style: TextStyle(
                                    fontSize: 8.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                              ),
                            ),
                            //hard coded
                            const Padding(
                              padding: EdgeInsets.only(left:8),
                              child: Text(
                                '% Active',
                                style:TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                            ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  DateFormat('MMMM yyyy').format(DateTime.now(),
                                  
                                ),
                                style:const  TextStyle(
                                    fontSize: 8.0,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                     
                  ),
                ),
                ),
              ],
            ),
      
            const SizedBox(width: 20), // spacing between columns
      
            // Right Column
            Flexible(
              child: Column(
                children: [
                  //3rd
                  Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    color: const Color(0xFF9EEAFF),
                    child: SizedBox(
                      width: 190.fSize,
                      height: 83.fSize,
                      child: Row(
                        children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  radius: 23.fSize,
                                  backgroundColor: Colors.white,
                                  child:Image.asset(
                                    'assets/images/OverviewMonthlyProfit.png',
                                    width: 30.fSize,
                                    height: 28.fSize,
                                  )
                                ),
                              ),
                                  
                          Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 10, top: 10),
                                child: Text(
                                  'Monthly Profit',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.normal
                                  ),
                                ),
                              ),
                              ...model.monthlyBlcOwner.map((entry) {
                              final year = entry['year'];
                              final month = entry['month'];
                              final profitEntry = model.monthlyProfitOwner.firstWhere(
                                (profit) =>
                                    profit['year'] == year &&
                                    profit['month'] == month,
                                orElse: () => {'total': 0.00},
                              );
                              final totalProfit = profitEntry['total'];
                              final formatted = totalProfit
                                  .toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]},',
                                  );
                              return Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.baseline,
                                        baseline: TextBaseline.alphabetic,
                                        child: Transform.translate(
                                          offset: const Offset(0, -4),
                                          child: const Text(
                                            'RM',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'Open Sans',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: formatted,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Open Sans',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  DateFormat('MMMM yyyy').format(DateTime.now(),
                                ),
                                style:const  TextStyle(
                                    fontSize: 8.0,
                                    fontStyle: FontStyle.normal
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ),
                  ),
      
                  //4th
                  Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    color: const Color(0xFFDBC7FF),
                    child: SizedBox(
                      width: 190.fSize,
                      height: 130.fSize,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(left:5),
                          child: Column(
                            children: [
                            RevenueContainer(
                              title:
                              '${model.revenueLastestYear} Accumulated Profit​',
                              icon: Icons.home_outlined,
                              overallRevenue: false,
                              model: model),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }
}


class RevenueContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool overallRevenue;
  final NewDashboardVM model;
  const RevenueContainer({
    Key? key,
    required this.title,
    required this.icon,
    required this.overallRevenue,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190.fSize,
      height: 130.fSize,
      child: Stack(
        children: [
          GestureDetector(
            // onTap: () => model.updateOverallRevenueAmount(),
            child: Container(
              padding: !Responsive.isMobile(context)
                  ? EdgeInsets.only(
                      left: 1.height, right: 1.height)
                  : EdgeInsets.all(1.height),

              child: Column(
                children: [
                  SizedBox(
                    height: (0.5).height,
                  ),
                  _buildTitleRow(),
                  //SizedBox(height: (1.5).height),
                  _buildAmountText(),
                  _buildDateRow(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    
                      children: [
                        Column(
                          children: [
                            Transform.translate(
                              offset: Offset(0, -3.5), // Move up by 3.5 pixels
                              child: CircleAvatar(
                                radius: 20.fSize,
                                backgroundColor: Colors.white,
                                child: Image.asset(
                                  'assets/images/OverviewAccumulatedProfit.png',
                                  width: 26.fSize,
                                  height: 24.fSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],


                        ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        // SizedBox(width: 3.width),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Open Sans',
            // fontSize: 12.fSize,
            fontSize: 10.fSize,
            
          ),
        ),
        const Spacer(),
        // Container(
        //   width: 3.width,
        //   height: 3.width,
        //   alignment: Alignment.center,
        //   child: Icon(
        //     Icons.arrow_outward_rounded,
        //     color: const Color(0xff3E51FF),
        //     size: 3.width,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Text(
          DateFormat('MMMM yyyy').format(DateTime.now()),
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 10.fSize,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text.rich(
        TextSpan(
       children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: const Offset(0, -3),
               child: const Text(
                'RM',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  ),
                  ),
                   ),
                   ),
       ]
        ),
        ),
        SizedBox(width: 1.width),
        FutureBuilder<dynamic>(
          future: overallRevenue ? model.overallBalance : model.overallProfit,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final value = snapshot.data ?? 0.00;
              return Text(
                NumberFormat('#,##0.00').format(value),
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 14.fSize,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

