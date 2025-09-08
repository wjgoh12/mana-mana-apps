import 'package:flutter/material.dart';

class UnitDetails extends StatefulWidget {
  const UnitDetails({Key? key}) : super(key: key);

  @override
  State<UnitDetails> createState() => _UnitDetailsState();
}

class _UnitDetailsState extends State<UnitDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Unit Details'),
    );
  }
}
