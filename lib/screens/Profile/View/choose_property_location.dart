import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/View/select_date_room.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class ChoosePropertyLocation extends StatelessWidget {
  const ChoosePropertyLocation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Property Location',
          style: TextStyle(
            fontSize: 20.fSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: GradientText1(
                text: 'Kuala Lumpur',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 30.fSize,
                  fontWeight: FontWeight.w800,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                )),
          ),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            padding: EdgeInsets.all(16),
            childAspectRatio: 0.7,
            children: [
              _buildLocationCard(context, 'Scarletz'),
              _buildLocationCard(context, 'Ceylonz'),
            ],
          )
        ],
      ),
    );
  }
}

Widget _buildLocationCard(BuildContext context, String location) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Column(
      //mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.fSize),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SelectDateRoom()),
                );
                // Navigate to the select booking screen
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.fSize),
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/${location.toUpperCase()}_BUILDING.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          location,
          style: TextStyle(
            fontSize: 20.fSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E51FF),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
