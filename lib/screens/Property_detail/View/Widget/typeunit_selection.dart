import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Property_detail/View/Widget/typeunit_selection_dropdown.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class TypeUnitSelection extends StatelessWidget {
  final PropertyDetailVM model;
  const TypeUnitSelection({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildGradientText('Unit No'),
        SizedBox(width: 3.width),
        TypeUnitSelectionDropdown(
          label: 'Unit No',
          list: model.typeItems,
          onChanged: (_) {
            model.updateSelectedTypeUnit(
                _!.split(" (")[0], _.split(" (")[1].replaceAll(")", ""));
          },
        ),
      ],
    );
  }
}

Widget _buildGradientText(String text) {
  return GradientText1(
    text: text,
    style: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 17.fSize,
      fontWeight: FontWeight.w700,
    ),
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF2900B7), Color(0xFF120051)],
    ),
  );
}