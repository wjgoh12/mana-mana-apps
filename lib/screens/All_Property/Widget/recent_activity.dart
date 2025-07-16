
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';


class RecentActivity extends StatefulWidget{

  const RecentActivity({super.key});


  

  @override
  State<RecentActivity> createState() => _RecentActivityState();



}

class _RecentActivityState extends State<RecentActivity> {
  
  @override
  Widget build(BuildContext context) {


    return Container(
      alignment: Alignment.topLeft,
      width: 390,
      height:250,
      child: Padding(
                  padding: const EdgeInsets.only(left:10, top:15),
                  child: Column(
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )
                      )
                  ],
                  ),
                ),
      
    );
  }

  

}

