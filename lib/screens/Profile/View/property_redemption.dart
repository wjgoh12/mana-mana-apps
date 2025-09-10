import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Profile/View/choose_property_location.dart';
import 'package:mana_mana_app/screens/Profile/View/select_date_room.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:provider/provider.dart';

class PropertyRedemption extends StatefulWidget {
  const PropertyRedemption({super.key});

  @override
  State<PropertyRedemption> createState() => _PropertyRedemptionState();
}

class _PropertyRedemptionState extends State<PropertyRedemption> {
  @override
  void initState() {
    super.initState();
    // Fetch booking history once
    Future.microtask(() {
      final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);
      ownerVM.fetchBookingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ownerVM = Provider.of<OwnerProfileVM>(context);
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
                'assets/images/mana2logo1.png',
              ),
              backgroundColor: Colors.transparent,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: GradientText1(
                text: 'Free Stay Redemptions',
                style: TextStyle(
                  fontFamily: 'outfit',
                  fontSize: 20.fSize,
                  fontWeight: FontWeight.w800,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        height: ResponsiveSize.scaleHeight(900),
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
                height: ResponsiveSize.scaleHeight(350),
                child: ListView.builder(
                  itemCount: 1, // Replace with actual data length
                  itemBuilder: (context, index) {
                    return PropertyPointRecord();
                  },
                ),
              ),
            ),
            SizedBox(height: ResponsiveSize.scaleHeight(15)),
            Center(
              child: Text(
                'Booking History',
                style: TextStyle(
                  fontFamily: 'outfit',
                  fontSize: ResponsiveSize.text(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: ResponsiveSize.scaleHeight(10)),
            Expanded(
              child: Container(
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
                child: Column(
                  children: [
                    // ✅ Sticky Header Row
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Location',
                              style: TextStyle(
                                fontFamily: 'outfit',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E51FF),
                                fontSize: ResponsiveSize.text(13),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Check-In Date',
                              style: TextStyle(
                                fontFamily: 'outfit',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E51FF),
                                fontSize: ResponsiveSize.text(13),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Check-Out Date',
                              style: TextStyle(
                                fontFamily: 'outfit',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E51FF),
                                fontSize: ResponsiveSize.text(13),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Points Used',
                              style: TextStyle(
                                fontFamily: 'outfit',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E51FF),
                                fontSize: ResponsiveSize.text(13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.grey.shade300),

                    // ✅ Scrollable Data Rows
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: ownerVM.bookingHistory.map((booking) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                        booking.typeRoom +
                                            "\n" +
                                            booking.bookingLocation,
                                        maxLines: 5,
                                        style: TextStyle(
                                            fontSize: ResponsiveSize.text(11),
                                            fontFamily: 'outfit')),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(booking.arrivalDate),
                                      style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'outfit'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(booking.departureDate),
                                      style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'outfit'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      booking.pointUsed.toString(),
                                      style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'outfit'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E51FF).withOpacity(0.15),
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
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => OwnerProfileVM(),
                  child: const ChoosePropertyLocation(),
                ),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ceylonz 9-11-3',
                style: TextStyle(
                  fontSize: ResponsiveSize.text(16),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E51FF),
                ),
              ),
              SizedBox(width: ResponsiveSize.scaleWidth(17)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Points',
                    style: TextStyle(
                      fontSize: ResponsiveSize.text(11),
                    ),
                  ),
                  SizedBox(height: ResponsiveSize.scaleHeight(6)),
                  Text(
                    '${SelectDateRoom.getUserPointsBalance()}/5000',
                    style: TextStyle(
                      fontSize: ResponsiveSize.text(11),
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
