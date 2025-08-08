import 'package:flutter/material.dart';

class ChoosePropertyLocation extends StatelessWidget {
  const ChoosePropertyLocation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Property Location'),
      ),
      body: Center(
        child: Text('Property Location Selection Screen'),
      ),
    );
  }
}
