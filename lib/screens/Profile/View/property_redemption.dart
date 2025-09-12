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
      ownerVM.fetchUserAvailablePoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ownerVM = Provider.of<OwnerProfileVM>(context);
    final sortedUnits = [...ownerVM.unitAvailablePoints]
      ..sort(
        (a, b) =>
            b.redemptionBalancePoints.compareTo(a.redemptionBalancePoints),
      );
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
              backgroundImage: const AssetImage('assets/images/mana2logo1.png'),
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
                child: ownerVM.isLoadingAvailablePoints
                    ? const Center(child: CircularProgressIndicator())
                    : ownerVM.unitAvailablePoints.isEmpty
                    ? const Center(
                        child: Text(
                          "No available points found.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'outfit',
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: sortedUnits.map((unit) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                vertical: ResponsiveSize.scaleHeight(8),
                                horizontal: ResponsiveSize.scaleWidth(6),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveSize.scaleWidth(8),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChangeNotifierProvider(
                                        create: (_) => OwnerProfileVM(),
                                        child: ChoosePropertyLocation(
                                          selectedLocation: unit.location,
                                          selectedUnitNo: unit.unitNo,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: ResponsiveSize.scaleWidth(16),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Left column
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${unit.location} - ${unit.unitNo}',
                                            style: TextStyle(
                                              fontSize: ResponsiveSize.text(15),
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'outfit',
                                              color: const Color(0xFF3E51FF),
                                            ),
                                          ),
                                          SizedBox(
                                            height: ResponsiveSize.scaleHeight(
                                              6,
                                            ),
                                          ),
                                          Text(
                                            'Available Points',
                                            style: TextStyle(
                                              fontSize: ResponsiveSize.text(12),
                                              fontFamily: 'outfit',
                                            ),
                                          ),
                                          SizedBox(
                                            height: ResponsiveSize.scaleHeight(
                                              6,
                                            ),
                                          ),
                                          Text(
                                            '${unit.redemptionBalancePoints}/${unit.redemptionPoints}',
                                            style: TextStyle(
                                              fontSize: ResponsiveSize.text(13),
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF3E51FF),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Spacer(),

                                      // Arrow icon
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey,
                                        size: 13,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
                      color: const Color(0xFF3E51FF).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Divider(height: 1, color: Colors.grey.shade300),

                    // ✅ Content Area
                    Expanded(
                      child: ownerVM.isLoadingBookingHistory
                          ? const Center(child: CircularProgressIndicator())
                          : ownerVM.bookingHistory.isEmpty
                          ? const Center(
                              child: Text("No booking history found."),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: ownerVM.bookingHistory.map((booking) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: ResponsiveSize.scaleHeight(
                                            60,
                                          ),
                                          width: ResponsiveSize.scaleWidth(60),
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlue.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.hotel,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        SizedBox(
                                          width: ResponsiveSize.scaleWidth(16),
                                        ),
                                        // Wrap Column in Expanded so it has bounded width
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    booking.typeRoom,
                                                    maxLines: 5,
                                                    style: TextStyle(
                                                      fontSize:
                                                          ResponsiveSize.text(
                                                            14,
                                                          ),
                                                      fontFamily: 'outfit',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),

                                                      color:
                                                          booking.status ==
                                                              'Confirmed'
                                                          ? Colors.green
                                                          : booking.status ==
                                                                'Pending'
                                                          ? Colors.orange
                                                          : Colors.red,
                                                      border: Border.all(
                                                        color:
                                                            booking.status ==
                                                                'Confirmed'
                                                            ? Colors.green
                                                            : booking.status ==
                                                                  'Pending'
                                                            ? Colors.orange
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            2,
                                                          ),
                                                      child: Text(
                                                        booking.status,
                                                        style: TextStyle(
                                                          fontSize:
                                                              ResponsiveSize.text(
                                                                10,
                                                              ),
                                                          fontFamily: 'outfit',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${booking.bookingLocation}',
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Dates:',
                                                    style: TextStyle(
                                                      fontFamily: 'outfit',
                                                      fontSize:
                                                          ResponsiveSize.text(
                                                            11,
                                                          ),
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(
                                                      booking.arrivalDate,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize:
                                                          ResponsiveSize.text(
                                                            12,
                                                          ),
                                                      fontFamily: 'outfit',
                                                    ),
                                                  ),
                                                  Text(
                                                    ' to ',
                                                    style: TextStyle(
                                                      fontFamily: 'outfit',
                                                      fontSize:
                                                          ResponsiveSize.text(
                                                            11,
                                                          ),
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(
                                                      booking.departureDate,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize:
                                                          ResponsiveSize.text(
                                                            12,
                                                          ),
                                                      fontFamily: 'outfit',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Spacer(), // Pushes the next widget to the end
                                                    Icon(
                                                      Icons.star,
                                                      size: 14,
                                                      color: Colors.purple,
                                                    ),
                                                    Text(
                                                      '${booking.pointUsed.toString()}',
                                                      style: TextStyle(
                                                        fontSize:
                                                            ResponsiveSize.text(
                                                              13,
                                                            ),
                                                        fontFamily: 'outfit',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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
