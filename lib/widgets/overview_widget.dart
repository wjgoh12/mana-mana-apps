import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/statistic_table_v3.dart';

class OverviewWidget extends StatefulWidget {
  const OverviewWidget({super.key});

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  final NewDashboardVM_v3 model = NewDashboardVM_v3();
  
  int totalUnits = 0;
  bool isLoading = true;
  String profit = '';
  

  @override
  void initState() {
    super.initState();
    fetchOwnerUnits();
  }

String getTotalProfit() {
  final profit = model.overallProfit.toString();
  return profit;
}

  Future<void> fetchOwnerUnits() async {
    final units = await model.ownerPropertyListRepository.getOwnerUnit(); // ← make sure this method exists
    setState(() {
      totalUnits = units.length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Expanded(
            child: Column(
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
                    // mainAxisAlignment: MainAxisAlignment.start,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          
                          children: [
                            
                            Padding(
                              padding:const EdgeInsets.only(right:22),
                                child:Text(
                                  '$totalUnits',
                                  style: const TextStyle(
                                    fontSize: 50,
                                    color: Colors.white,
                                  ),
                                ),
                          
                            ),
                            const SizedBox(width: 1), // spacing between text and image
                            
                          ],
                        )
                          ]
                        ),
                      ),
                      Padding(
                        padding:const EdgeInsets.only(left: 10,),
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
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                              const Padding(
                            padding: EdgeInsets.only(left: 16,top:30),
                            child: Image(
                              image: AssetImage('assets/images/OverviewOccupancy.png'),
                              width: 30,
                              height: 20,
                            )
                          ),
                            ],
                          
                        ),
                        const Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left:8,top:15),
                                child: Text(
                                  
                                  'Occupancy Rate',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontStyle: FontStyle.normal
                                  ),
                              ),
                            )

                      ],
                    ),
                      ],
                     
                  ),
                ),
                ),
              ],
            ),
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
                                    padding: EdgeInsets.only(left: 15, top: 15),
                                    child: Image(
                                      image: AssetImage('assets/images/OverviewMonthlyProfit.png'),
                                      width:20,
                                      height:19,
                                      ),
                                  ),
                              
                            ],
                          
                          ),
                          Column(
                          
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 15, top: 15),
                                child: Text(
                                  'Monthly Profit',
                                  style: TextStyle(
                                    
                                    fontSize: 10.0,
                                    fontStyle: FontStyle.normal
                                  ),
                                ),
                              ),
                              Padding(
                                padding:const EdgeInsets.only(top: 10),
                               child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text:'RMprofit',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10.0,
                                        fontStyle: FontStyle.normal
                                      )
                                    ),
                                    WidgetSpan(
                                      child: Transform.translate(
                                        offset: const Offset(2, -4),
                                        ),
                                        ),
                                        const TextSpan(
                                          text: '',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10.0,
                                            fontStyle: FontStyle.normal
                                          )
                                        ),
                                  ]
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
                    child: Expanded(
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        
                      children:[
                        Padding(
                          padding: const EdgeInsets.only(left:25,top: 13),
                          child: Text('${DateTime.now().year} Accumulated Profit',
                          style: const TextStyle(fontSize: 10),)
                          ),

                          const Padding(
                          padding: EdgeInsets.only(left: 25),
                          child: Text('RM',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                          ),
                          
                          ),
                          Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: const TextStyle(fontSize: 10),)
                          ),
                        
                        const Stack(
                          children: [
                            
                             Align(
                              alignment: Alignment.bottomRight,
                                child: Padding(
                                      padding: EdgeInsets.only(right: 10, top: 5),
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
                                    padding: EdgeInsets.only(right: 15, top: 12),
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
    );
  }
}