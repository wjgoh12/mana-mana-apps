import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail.dart';
import 'package:mana_mana_app/screens/Property_detail/View/property_detail_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class RecentActivity extends StatefulWidget {
  final PropertyDetailVM model;
  const RecentActivity({required this.model, super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  @override
  Widget build(BuildContext context) {
    final PropertyDetailVM model = PropertyDetailVM();

    return Container(
      alignment: Alignment.topLeft,
      width: 390,
      height: 500,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 15),
        child: Column(
          children: [
            Text('Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            //recent activity record list
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: false,
                children: [
                  RecentActivityRecord(
                      unitName: '12-12-22', propertyName: 'SCARLETZ'),
                  RecentActivityRecord(
                      unitName: '12-12-22', propertyName: 'SCARLETZ'),
                  RecentActivityRecord(
                      unitName: '45-99.99', propertyName: 'SCARLETZ'),
                  RecentActivityRecord(
                      unitName: '12-12-22', propertyName: 'SCARLETZ'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RecentActivityRecord extends StatelessWidget {
  final String unitName;
  final String propertyName;

  const RecentActivityRecord(
      {super.key, required this.unitName, required this.propertyName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => property_detail_v3(
                      locationByMonth: [
                        {'location': propertyName}
                      ],
                    )));
      },
      child: Container(
        width: 390.fSize,
        height: 60.fSize,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.fSize),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF000000).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statement for Unit $unitName has been issued',
                      style: TextStyle(
                        fontSize: 12.fSize,
                        color: Color(0xFF888888),
                      )),
                  Text('$propertyName'),
                ],
              ),
              Icon(Icons.arrow_right, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
