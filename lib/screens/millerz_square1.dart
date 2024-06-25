import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/personal_millerz_square.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

const List<String> list = <String>['Type A', 'Type B', 'Type C', 'Type D'];

class MillerzSquare1Screen extends StatelessWidget {
  const MillerzSquare1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      appBar: propertyAppBar(context, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const PersonalMillerzSquare1Screen();
        }));
      }),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            propertyStack(
              'millerz_square',
              'Millerz Square',
              '@ Old Klang Road',
              90.width,
              12.height,
            ),
            const SizedBox(
              height: 20,
            ),
            propertyStack(
              'scarletz_suites',
              'Scarletz Suites',
              '@ KL City Centre',
              90.width,
              12.height,
            ),
            const SizedBox(
              height: 20,
            ),
            propertyStack(
              'expressionz',
              'Expressionz Suites',
              '@ Jalan Tun Razak',
              90.width,
              12.height,
            ),
          ],
        ),
      ),
    );
  }
}

class TypeDropdownButton extends StatefulWidget {
  const TypeDropdownButton({super.key});

  @override
  State<TypeDropdownButton> createState() => _TypeDropdownButtonState();
}

class _TypeDropdownButtonState extends State<TypeDropdownButton> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 30.width,
      height: 3.height,
      decoration: BoxDecoration(
          color: Color(0XFFFFFFFF), borderRadius: BorderRadius.circular(35)),
      child: DropdownButton<String>(
        underline: const SizedBox(),
        iconDisabledColor: Color(0XFF4313E9),
        iconEnabledColor: Color(0XFF4313E9),
        dropdownColor: Color(0xFFFFFFFF),
        value: dropdownValue,
        icon: const Icon(Icons.arrow_drop_down_sharp),
        elevation: 16,
        style: const TextStyle(color: Color(0XFF4313E9)),
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

Widget propertyStack(image, text1, text2, width, height) {
  return Stack(
    children: [
      Align(
        alignment: Alignment.center,
        child: Container(
          width: width,
          height: height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Image.asset(
            'assets/images/$image.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      Center(
        child: Column(
          children: [
            SizedBox(
              height: 2.height,
            ),
            Text(
              '$text1',
              style: TextStyle(
                  color: const Color(0XFFFFFFFF),
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                        color: const Color(0XFF120051).withOpacity(0.75))
                  ],
                  fontSize: 30.fSize),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '$text2',
              style: TextStyle(
                  color: const Color(0XFFFFFFFF),
                  fontFamily: 'Italic',
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                        color: const Color(0XFF120051).withOpacity(0.75))
                  ],
                  fontSize: 15.fSize),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            // const TypeDropdownButton()
          ],
        ),
      ),
    ],
  );
}
