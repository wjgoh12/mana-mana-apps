import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/New_Dashboard/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_builder/responsive_builder.dart';

class NewsletterListV3 extends StatelessWidget {
  final NewDashboardVM model;
  const NewsletterListV3({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
                  onTap: () {

                  },
            ),
          ],
        );
  }
}