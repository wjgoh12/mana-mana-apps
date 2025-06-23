

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key});


@override
  Widget build(BuildContext context) {

    return Container(
      child:Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            debugPrint('Card tapped.');
          },
          child: const SizedBox(width: 300, height: 100, child: Text('A card that can be tapped')),
        ),
      ),
    );

  }


}