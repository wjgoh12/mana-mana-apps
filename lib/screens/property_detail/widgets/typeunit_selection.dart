import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/property_detail/widgets/typeunit_selection_drop_down.dart';
import 'package:mana_mana_app/screens/property_detail/view_model/property_detail_view_model.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

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
        TypeUnitSelectionDropdown2(
          label: 'Unit No',
          list: model.typeItems,
          onChanged: (_) {
            model.updateSelectedTypeUnit(
                _!.replaceAll(RegExp(r' \([^)]*\)$'), ''),
                _.split(' ').last.replaceAll(RegExp(r'[()]'), ''));
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
      fontSize: AppDimens.fontSizeBig,
      fontWeight: FontWeight.w700,
    ),
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF2900B7), Color(0xFF120051)],
    ),
  );
}
