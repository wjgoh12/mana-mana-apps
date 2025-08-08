import 'package:flutter/material.dart';
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
        height: 900,
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: SizedBox(
                height: 350,
                child: ListView.builder(
                  itemCount: 6, // Replace with actual data length
                  itemBuilder: (context, index) {
                    return PropertyPointRecord();
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Booking History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 380,
              height: 300.fSize,
              child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Location'),
                            Text('Check-In Date'),
                            Text('Check-Out Date'),
                            Text('Points \nUsed'),
                          ],
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 6, // Replace with actual data length
                            itemBuilder: (context, index) {
                              return BookingHistoryRecord();
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Property Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Points',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '1000/10000',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingHistoryRecord extends StatelessWidget {
  const BookingHistoryRecord({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Location Name'),
          Text('2023-10-01'),
          Text('2023-10-05'),
          Text('500'),
        ],
      ),
    );
  }
}
