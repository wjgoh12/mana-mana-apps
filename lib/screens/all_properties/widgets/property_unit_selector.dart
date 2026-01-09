import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:provider/provider.dart';

class PropertyUnitSelector extends StatefulWidget {
  const PropertyUnitSelector({super.key});

  @override
  State<PropertyUnitSelector> createState() => _PropertyUnitSelectorState();
}

class _PropertyUnitSelectorState extends State<PropertyUnitSelector> {
  String? selectedProperty;
  String? selectedUnit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = Provider.of<NewDashboardVM_v3>(context, listen: false);
      final firstProperty = model.ownerUnits
          .map((unit) => unit.location)
          .where((location) => location != null)
          .firstOrNull;

      if (firstProperty != null) {
        setState(() {
          selectedProperty = firstProperty;
        });

        final firstUnit = model.ownerUnits
            .where((unit) => unit.location == firstProperty)
            .map((unit) => unit.unitno)
            .where((unitno) => unitno != null)
            .firstOrNull;

        if (firstUnit != null) {
          setState(() {
            selectedUnit = firstUnit;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<NewDashboardVM_v3>(context);

    // Get properties
    final properties = model.ownerUnits
        .map((unit) => unit.location)
        .where((location) => location != null)
        .toSet()
        .toList();

    // Get units for selected property
    final units = selectedProperty != null
        ? model.ownerUnits
            .where((unit) => unit.location == selectedProperty)
            .map((unit) => unit.unitno)
            .where((unitno) => unitno != null)
            .toSet()
            .toList()
        : <String>[];

    return Row(
      children: [
        const SizedBox(width: 16),
        // Label
        Text(
          'Unit:',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: ResponsiveSize.text(18),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),

        // Property dropdown
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: selectedProperty,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: ResponsiveSize.text(18),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            // icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            items: properties.map((property) {
              return DropdownMenuItem(
                value: property,
                child: Text(
                  property ?? '',
                  style: TextStyle(
                      fontFamily: 'Outfit', fontSize: ResponsiveSize.text(14)),
                ),
              );
            }).toList(),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              // width: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                color: Colors.white,
              ),
              offset: const Offset(0, 0),
            ),
            onChanged: (value) {
              if (value != null) {
                final firstUnit = model.ownerUnits
                    .where((unit) => unit.location == value)
                    .map((unit) => unit.unitno)
                    .where((unitno) => unitno != null)
                    .firstOrNull;

                setState(() {
                  selectedProperty = value;
                  selectedUnit = firstUnit;
                });
              }
            },
          ),
        ),
        // SizedBox(width: ResponsiveSize.scaleWidth(8)),
        // Text(
        //   ' > ',
        //   style: TextStyle(
        //     fontFamily: 'Outfit',
        //     fontSize: ResponsiveSize.text(18),
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        // Unit dropdown
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: selectedUnit,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: ResponsiveSize.text(14),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            // icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            items: units.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(
                  unit ?? '',
                  style: TextStyle(
                      fontFamily: 'Outfit', fontSize: ResponsiveSize.text(14)),
                ),
              );
            }).toList(),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: ResponsiveSize.scaleWidth(120),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                color: Colors.white,
              ),
              offset: const Offset(0, 0),
            ),
            onChanged: (value) {
              setState(() {
                selectedUnit = value;
              });
            },
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.grey.shade300),
        //   ),
        //   child: DropdownButtonHideUnderline(
        //     child: DropdownButton<String>(
        //       value: selectedUnit,
        //       hint: const Text('Select Unit'),
        //       items: units.map((unit) {
        //         return DropdownMenuItem(
        //           value: unit,
        //           child: Text(
        //             unit ?? '',
        //             style: TextStyle(
        //               fontFamily: 'Outfit',
        //               fontSize: ResponsiveSize.text(16),
        //             ),
        //           ),
        //         );
        //       }).toList(),
        //       onChanged: (value) {
        //         setState(() {
        //           selectedUnit = value;
        //         });
        //       },
        //     ),
        //   ),
        // ),
        const SizedBox(width: 16),
      ],
    );
  }
}
