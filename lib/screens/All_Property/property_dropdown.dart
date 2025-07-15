
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/All_Property/View/property_summary.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class PropertyTitleDropdown extends StatefulWidget{
  const PropertyTitleDropdown({Key? key}) : super(key: key);

@override
  State<PropertyTitleDropdown> createState() => _PropertyTitleDropdownState();
}

class _PropertyTitleDropdownState extends State<PropertyTitleDropdown> {

  String? selectedValue ='Property Summary';

  final pages = {
    'Property Summary': PropertySummaryScreen(),
    'Property List': AllPropertyScreen(),
    
  };
  String getDisplayText(){
    if(selectedValue == 'Property Summary') {
      return 'Property Summary';
    } else if (selectedValue == 'Property List') {
      return 'Property List';
    } else {
      return 'Select page';
    }
  }
  @override
  Widget build(BuildContext context) {
    final model = NewDashboardVM();
    final model2 = PropertyDetailVM();
    model.fetchData();
    model2.fetchData(model.locationByMonth);
    
    return Container(
      width:197.fSize,
      child: DropdownButton2<String>(
                        value: selectedValue,
                        isExpanded: false,
                        underline: const SizedBox(),
                         dropdownStyleData: DropdownStyleData(
                                          width: 197.fSize,
                                          offset: const Offset(-2, -1),
                                          useSafeArea: true,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0),
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
                      items:
                             pages.keys.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),

                            onChanged: (String? newValue) {
                          if(newValue != null) {
                            Navigator.push(context, _createRoute(pages[newValue]!));
                          }
                        },
                        hint: Text(
                          getDisplayText(),
                          
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        
                        ),
                        );
                        
                       }
                       }

PageRouteBuilder _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity:animation,
        child:child
      );
    },
  );
}