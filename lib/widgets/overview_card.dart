import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
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
                      
                      Expanded(
                        child: Stack(
                          children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, top: 15),
                            child:Image.asset('assets/images/Bulat.png',
                            width:35,
                            height:35,
                            ),
                        ),
                        Padding(
                              padding: const EdgeInsets.only(left: 25 ,top: 20),
                              child: Image.asset(
                                'assets/images/OverviewProperty.png',
                                width: 14,
                                height: 26,
                              ),
                            ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            
                            children: [
                              
                              Padding(
                                padding:const EdgeInsets.only(right:15),
                                  child:
                                  Text('${model.ownerUnits.length}',
                                  )
                            
                              ),
                              const SizedBox(width: 1), // spacing between text and image
                              
                            ],
                          ),
                        )
                          ]
                        ),
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
                        padding: const EdgeInsets.only(left: 10,bottom:15),
                      child:Text(
                        'Managed: ', 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.fSize,
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
                                  child: Image.asset(
                                    'assets/images/Bulat.png',
                                    width: 35,
                                    height: 35,
                                  ),
                                ),
                              ),
                              const Padding(
                            padding: EdgeInsets.only(left: 15,top:25),
                            child: Image(
                              image: AssetImage('assets/images/OverviewOccupancy.png'),
                              width: 25,
                              height: 15,
                            )
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
                                '75% Active',
                                style:TextStyle(
                                  fontSize: 12,
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
                      child: Expanded(
                        child: Row(
                          children: [
                            const Stack(
                              children: [
                                Padding(
                                      padding: EdgeInsets.only(left: 10, top: 10),
                                      child: Image(
                                        image: AssetImage('assets/images/Bulat.png'),
                                        width:35,
                                        height:35,
                                        ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 17, top: 17),
                                      child: Image(
                                        image: AssetImage('assets/images/OverviewMonthlyProfit.png'),
                                        width:20,
                                        height:19,
                                       ),
                                    ),
                              ],
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
                                  padding: const EdgeInsets.only(left: 20),
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
                                  padding: const EdgeInsets.only(left: 15),
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
                        ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          
                        children:
                        [
                          Padding(
                            padding: const EdgeInsets.only(left:20,top: 13),
                            child: Text('${DateTime.now().year} Accumulated Profit',
                            style: const TextStyle(fontSize: 8),)
                            ),
                              
                            Padding(
                            padding: const EdgeInsets.only(left: 20),
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
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: '88888.88',
                                      style: const TextStyle(
                                        fontSize: 15.0,            
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            ),
                            Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              DateFormat('MMMM yyyy').format(DateTime.now()),
                            style: const TextStyle(fontSize: 8),)
                            ),
                          
                          const Stack(
                            children: [
                              
                               Align(
                                alignment: Alignment.bottomRight,
                                  child: Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Image(
                                          image: AssetImage('assets/images/Bulat.png'),
                                          width:40,
                                          height:40,
                                          ),
                                      ),
                                ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child:Padding(
                                      padding: EdgeInsets.only(right: 15, top: 7),
                                      child: Image(
                                        image: AssetImage('assets/images/OverviewAccumulatedProfit.png'),
                                        width:26,
                                        height:26,
                                        ),
                                    ),
                                    ),
                                
                              ],
                        ),
                        ]
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