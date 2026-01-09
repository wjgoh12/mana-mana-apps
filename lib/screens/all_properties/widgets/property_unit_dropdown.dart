import 'package:flutter/material.dart';

class PropertyUnitDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> properties;
  // Example structure:
  // [
  //   {
  //     "name": "Property A",
  //     "units": ["Unit 1A", "Unit 2A", "Unit 3A"]
  //   },
  //   {
  //     "name": "Property B",
  //     "units": ["Unit 1B", "Unit 2B"]
  //   }
  // ]

  const PropertyUnitDropdown({super.key, required this.properties});

  @override
  State<PropertyUnitDropdown> createState() => _PropertyUnitDropdownState();
}

class _PropertyUnitDropdownState extends State<PropertyUnitDropdown> {
  String? selectedProperty;
  String? selectedUnit;
  List<String> availableUnits = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Dropdown 1: Property
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Select Property",
            border: OutlineInputBorder(),
          ),
          value: selectedProperty,
          items: widget.properties.map((prop) {
            return DropdownMenuItem<String>(
              value: prop["name"],
              child: Text(prop["name"]),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedProperty = value;
              selectedUnit = null; // reset unit
              availableUnits = widget.properties
                  .firstWhere((prop) => prop["name"] == value)["units"]
                  .cast<String>();
            });
          },
        ),
        const SizedBox(height: 16),

        // 🔹 Dropdown 2: Unit
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Select Unit",
            border: OutlineInputBorder(),
          ),
          value: selectedUnit,
          items: availableUnits.map((unit) {
            return DropdownMenuItem<String>(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedUnit = value;
            });
          },
        ),
      ],
    );
  }
}
