
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OccupancyRateBox extends StatefulWidget{


  
  const OccupancyRateBox({super.key});

  final labelColor1 = const Color(0xFF8C71E7);
  final labelColor2 = const Color(0xFFDDD7FF);

  @override
  State<OccupancyRateBox> createState() => _OccupancyRateBoxState();

  BarChartGroupData generateBarGroup(
    int x, 
    LinearGradient color, 
    double value, 
    double shadowValue,) {
      return BarChartGroupData(
        x: x,
        barsSpace: 0.7,
        barRods: [
          BarChartRodData(
            toY: value,
            gradient: color,
            color:labelColor1,
            width: 10,
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          BarChartRodData(
            toY: shadowValue,
            gradient: color,
            width: 10,
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
        ],
      );
    } 
}

class _OccupancyRateBoxState extends State<OccupancyRateBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      width: 390,
      height:250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3E51FF).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),

      //title & dropdown 
      child:const Row(
        children: [
            Padding(
              padding: EdgeInsets.only(left:10, top:14),
              child: Text(
                'Occupancy Rate',
                style:TextStyle(
                  fontSize:20,
                  fontWeight: FontWeight.bold,
                )
                ),

                //dropdown

                
            ),
        ],
      ),

      

      
    );
  }

}

class _OccupancyData {
  const _OccupancyData(this.color, this.value, this.maxValue);
  final LinearGradient color;
  final double value;
  final double maxValue;
}


class 