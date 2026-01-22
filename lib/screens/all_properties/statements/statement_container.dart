import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/property_detail/view_model/property_detail_view_model.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'statement_dropdown.dart';
import 'statement_list.dart';

class StatementContainer extends StatelessWidget {
  final PropertyDetailVM model;

  const StatementContainer({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (model.selectedProperty == null ||
        model.selectedUnitNo == null ||
        model.selectedType == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          children: [
            SizedBox(
              height: ResponsiveSize.scaleHeight(20),
            ),
            StatementDropdown(
              yearOptions: model.yearItems,
              monthOptions: model.monthItems,
              model: model,
            ),
            StatementList(model: model),
          ],
        ),
      ),
    );
  }
}
