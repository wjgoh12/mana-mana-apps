
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class OccupancyPeriodDropdown extends StatefulWidget {

  const OccupancyPeriodDropdown({super.key});

  @override
  State<OccupancyPeriodDropdown> createState() => _OccupancyPeriodDropdownState();


}


class _OccupancyPeriodDropdownState extends State<OccupancyPeriodDropdown> {
  String? selectedValue ='Monthly';

  final period = {
    'Monthly':'Monthly',
    'Quarterly':'Quarterly',
    'Yearly':'Yearly',
  };

  String getDisplayBarChart(){
    if(selectedValue == 'Monthly'){
      return 'Monthly';
    } else if (selectedValue == 'Quarterly') {
      return 'Quarterly';
    } else if (selectedValue == 'Yearly') {
      return 'Yearly';
    } else {
      return 'Select period';
  }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      
      child:Padding(
        padding: EdgeInsets.only(right: 10.fSize, top:10.fSize),
      child: Container(
        width: 130.fSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.fSize),
          color:Color(0xFFF0F2FD),
        ),
        child: DropdownButton2<String>(
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
          },
          items: period.entries.map((entry) {
             
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(entry.value),
              ),
            );
          }).toList(),
          dropdownStyleData: DropdownStyleData(
            width: 130.fSize,
            offset: const Offset(-2, -1),
            
          ),

        ),
      ),
    ),
    );
}
}