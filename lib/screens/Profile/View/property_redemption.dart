import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Profile/View/choose_property_location.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class PropertyRedemption extends StatefulWidget {
  const PropertyRedemption({super.key});

  @override
  State<PropertyRedemption> createState() => _PropertyRedemptionState();
}

class _PropertyRedemptionState extends State<PropertyRedemption> {
  final NewDashboardVM_v3 model = NewDashboardVM_v3();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height
    double responsiveFont(double value) =>
        (value / 812.0) * screenHeight; // font scaling

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 13.width,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.fSize,
              backgroundImage: const AssetImage(
                'assets/images/mana2logo.png',
              ),
              backgroundColor: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: GradientText1(
                  text: 'Free Stay Redemptions',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 20.fSize,
                    fontWeight: FontWeight.w800,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                  )),
            ),
          ],
        ),
      ),
      body: Container(
        height: responsiveHeight(900),
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3E51FF).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                height: responsiveHeight(350),
                child: ListView.builder(
                  itemCount: 1, // Replace with actual data length
                  itemBuilder: (context, index) {
                    return PropertyPointRecord();
                  },
                ),
              ),
            ),
            SizedBox(height: responsiveHeight(30)),
            Text(
              'Booking History',
              style: TextStyle(
                fontSize: responsiveFont(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsiveHeight(10)),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3E51FF).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      border: TableBorder.all(color: Colors.transparent),
                      columnWidths: {
                        0: FlexColumnWidth(responsiveWidth(1.5)),
                        1: FlexColumnWidth(responsiveWidth(2)),
                        2: FlexColumnWidth(responsiveWidth(2)),
                        3: FlexColumnWidth(responsiveWidth(1)),
                      },
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 10, top: 10),
                              child: Text(
                                'Location',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3E51FF),
                                    fontSize: responsiveFont(13)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10, top: 10),
                              child: Text(
                                'Check-In Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E51FF),
                                  fontSize: responsiveFont(13),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10, top: 10),
                              child: Text(
                                'Check-Out Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E51FF),
                                  fontSize: responsiveFont(13),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10, top: 10),
                              child: Text(
                                'Points Used',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E51FF),
                                  fontSize: responsiveFont(13),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Ceylonz 9-11-3',
                                style: TextStyle(
                                  fontSize: responsiveFont(11),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '2023-10-01',
                                style: TextStyle(
                                  fontSize: responsiveFont(11),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '2023-10-05',
                                style: TextStyle(
                                  fontSize: responsiveFont(11),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '1000',
                                style: TextStyle(
                                  fontSize: responsiveFont(11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertyPointRecord extends StatefulWidget {
  const PropertyPointRecord({super.key});

  @override
  State<PropertyPointRecord> createState() => _PropertyPointRecordState();
}

class _PropertyPointRecordState extends State<PropertyPointRecord> {
  final NewDashboardVM_v3 model = NewDashboardVM_v3();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height
    double responsiveFont(double value) =>
        (value / 812.0) * screenHeight; // font scaling

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3E51FF).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChoosePropertyLocation()),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ceylonz 9-11-3',
                style: TextStyle(
                  fontSize: responsiveFont(16),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E51FF),
                ),
              ),
              SizedBox(width: responsiveWidth(17)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Points',
                    style: TextStyle(
                      fontSize: responsiveFont(11),
                    ),
                  ),
                  SizedBox(height: responsiveHeight(6)),
                  Text(
                    '14000/20000',
                    style: TextStyle(
                      fontSize: responsiveFont(11),
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E51FF),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 13),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingHistoryRecord extends StatelessWidget {
  final String location;
  final String checkInDate;
  final String checkOutDate;
  final String pointsUsed;

  const BookingHistoryRecord({
    super.key,
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    required this.pointsUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            location,
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          Text(
            checkInDate,
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          Text(
            checkOutDate,
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          Text(pointsUsed),
        ],
      ),
    );
  }
}
