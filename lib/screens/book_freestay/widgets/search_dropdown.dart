import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchDropdown extends StatefulWidget {
  @override
  _SearchDropdownState createState() => _SearchDropdownState();
}

class _SearchDropdownState extends State<SearchDropdown> {
  final List<String> items = [
    'Apple',
    'Banana',
    'Grapes',
    'Mango',
    'Orange',
    'Peach',
  ];

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: const Text('Select Item'),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
          },
          dropdownSearchData: DropdownSearchData(
            searchController: textEditingController,
            searchInnerWidget: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return item.value!
                  .toLowerCase()
                  .contains(searchValue.toLowerCase());
            },
          ),
        ),
      ),
    );
  }
}
