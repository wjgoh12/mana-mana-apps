import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';

class OverviewWidget extends StatefulWidget {
  const OverviewWidget({super.key});

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  final NewDashboardVM_v3 model = NewDashboardVM_v3();
  int totalUnits = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOwnerUnits();
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
          Flexible(
            child: Column(
              children: [
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
                      
                      Stack(
                        children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                          child:Image.asset('assets/images/Bulat.png',
                          width:40,
                          height:40,
                          ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        
                        children: [
                          Padding(
                            padding:const EdgeInsets.only(left:10),
                              child:Text(
                                
                                '$totalUnits',
                                style: const TextStyle(
                                  fontSize: 50,
                                  
                                  color: Colors.white,
                                ),
                              ),
                        
                          ),
                          const SizedBox(width: 1), // spacing between text and image
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Image.asset(
                              'assets/images/OverviewProperty.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ],
                      )
                        ]
                      ),
                      Padding(
                        padding:EdgeInsets.only(left: 10),
                      child:Text(
                        'Total Properties', 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.fSize,
                          ),
                      ),
                      ),
                      Padding(
                        padding:EdgeInsets.only(left: 10),
                      child:Text(
                        'Managed: ', 
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.fSize,
                          fontWeight: FontWeight.bold,
                          ),
                      ),
                      ),

                       
                      
                      
                    ]
                   ),
                  ),
                  
                ),
                Card(
                  
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFFFFE7B8),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 83.fSize,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          
                          children: [
                            Align(
                              alignment: Alignment.centerLeft, // Vertically center, left-aligned
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10,top:10),
                                child: Image.asset(
                                  'assets/images/Bulat.png',
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                            const Padding(
                          padding: EdgeInsets.only(left: 16, top: 20),
                          child: Image(
                            image: AssetImage('assets/images/OverviewOccupancy.png'),
                            width: 35,
                            height: 25,
                          )
                        ),
                          ],
                        )
                        
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 20), // spacing between columns

          // Right Column
          Flexible(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFF9EEAFF),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 83.fSize,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: const Color(0xFFDBC7FF),
                  child: SizedBox(
                    width: 190.fSize,
                    height: 130.fSize,
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}