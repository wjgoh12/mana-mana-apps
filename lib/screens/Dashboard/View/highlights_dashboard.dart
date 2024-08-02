import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:responsive_grid/responsive_grid.dart';

class BuildHighlights extends StatelessWidget {
  const BuildHighlights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveGridRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            ResponsiveGridCol(
              xs: 6,
              child: const _HighlightImage(imagePath: 'assets/images/Promotions.png'),
            ),
            ResponsiveGridCol(
              xs: 6,
              child: const _HighlightImage(imagePath: 'assets/images/Discounts.png'),
            ),
          ],
        ),
        SizedBox(height: 2.height),
        ResponsiveGridRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveGridCol(
              xs: 6,
              child: const _HighlightImage(imagePath: 'assets/images/Exchange.png'),
            ),
            ResponsiveGridCol(
              xs: 6,
              child: const _HighlightImage(imagePath: 'assets/images/Earn Points.png'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HighlightImage extends StatelessWidget {
  final String imagePath;

  const _HighlightImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(imagePath);
  }
}