import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/Profile/View/choose_property_location.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/services/booking_submission_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyRedemption extends StatefulWidget {
  const PropertyRedemption({super.key});

  @override
  State<PropertyRedemption> createState() => _PropertyRedemptionState();
}

class _PropertyRedemptionState extends State<PropertyRedemption> {
  String selectedFilter = 'All'; // Filter state

  // Helper method to remove prefix uppercase letters
  String _sanitizeRoomTypeName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;

    final firstToken = s.split(RegExp(r'\s+'))[0];

    // Check if first token is all uppercase and between 2-5 characters
    final isAllCaps = RegExp(r'^[A-Z]+$').hasMatch(firstToken);
    if (isAllCaps && firstToken.length >= 2 && firstToken.length <= 5) {
      return s.substring(firstToken.length).trim();
    }

    return s;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);
      ownerVM.clearSelectionCache();

      final globalData = Provider.of<GlobalDataManager>(context, listen: false);
      globalData.clearLocationCache();
    });

    Future.microtask(() async {
      // ignore: use_build_context_synchronously
      final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);
      await ownerVM.fetchData();
      await ownerVM.fetchUserAvailablePoints();
      await ownerVM.fetchBookingHistory();
    });
  }

  // Filter tabs widget
  Widget _buildFilterTab(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'outfit',
              fontSize: ResponsiveSize.text(14),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // Get filtered bookings - sorted by submission time (latest first)
  Future<List<dynamic>> _getFilteredBookings(OwnerProfileVM ownerVM) async {
    List<dynamic> filteredList;

    if (selectedFilter == 'All') {
      filteredList = ownerVM.bookingHistory;
    } else if (selectedFilter == 'Cancelled') {
      // Group all cancellation-related statuses
      final cancelledStatuses = [
        'Cancelled',
        'Unavailable',
        'Cancel Booking',
        'No Availability'
      ];
      filteredList = ownerVM.bookingHistory.where((booking) {
        return cancelledStatuses.contains(booking.status);
      }).toList();
    } else {
      filteredList = ownerVM.bookingHistory.where((booking) {
        return booking.status == selectedFilter;
      }).toList();
    }

    // Get submission times for all bookings
    Map<String, DateTime> submissionTimes = {};
    for (var booking in filteredList) {
      final submissionTime =
          await BookingSubmissionService.getSubmissionTime(booking);
      if (submissionTime != null) {
        submissionTimes[booking.storageKey] = submissionTime;
      }
    }

    // Sort by submission time if available, otherwise by createdAt
    filteredList.sort((a, b) {
      final timeA = submissionTimes[a.storageKey];
      final timeB = submissionTimes[b.storageKey];

      if (timeA != null && timeB != null) {
        return timeB.compareTo(timeA);
      }
      if (timeA != null) return -1;
      if (timeB != null) return 1;

      return b.createdAt.compareTo(a.createdAt);
    });

    return filteredList;
  }

  List<Widget> _buildGroupedBookings(List<dynamic> bookings) {
    // Sort bookings by creation date (newest first)
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Just return the sorted list
    return bookings.map((booking) => _buildBookingCard(booking)).toList();
  }

  // Build booking card
  Widget _buildBookingCard(dynamic booking) {
    return InkWell(
      onTap: () {
        if (booking.status == "Confirmed") {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Confirmed Booking Details",
                      style: TextStyle(
                        fontFamily: 'outfit',
                        fontSize: ResponsiveSize.text(18),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3E51FF),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Location",
                        style: TextStyle(fontFamily: 'outfit')),
                    Text(
                      booking.bookingLocation,
                      style: const TextStyle(
                          fontFamily: 'outfit', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Room Type",
                        style: TextStyle(fontFamily: 'outfit')),
                    Text(
                      _sanitizeRoomTypeName(booking.typeRoom),
                      style: const TextStyle(
                          fontFamily: 'outfit', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Total Points",
                        style: TextStyle(fontFamily: 'outfit')),
                    Text(
                      '${booking.pointUsed}',
                      style: const TextStyle(
                          fontFamily: 'outfit', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Check-In",
                        style: TextStyle(fontFamily: 'outfit')),
                    Text(
                      DateFormat('dd MMM yyyy').format(booking.arrivalDate),
                      style: const TextStyle(
                          fontFamily: 'outfit', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Check-Out",
                        style: TextStyle(fontFamily: 'outfit')),
                    Text(
                      DateFormat('dd MMM yyyy').format(booking.departureDate),
                      style: const TextStyle(
                          fontFamily: 'outfit', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text('Points Redeemed From',
                        style: TextStyle(fontFamily: 'outfit')),
                    Text(
                      ' ${booking.location} - ${booking.unitNo}',
                      style: const TextStyle(
                          fontFamily: 'outfit', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // const Text('Confirmation Date',
                    //     style: TextStyle(fontFamily: 'outfit')),
                    // Text(
                    //   DateFormat('dd MMM yyyy HH:mm').format(booking.createdAt),
                    //   style: const TextStyle(
                    //       fontFamily: 'outfit', fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveSize.scaleHeight(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: ResponsiveSize.scaleHeight(60),
                width: ResponsiveSize.scaleWidth(60),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.hotel, color: Colors.blueAccent, size: 30),
              ),
              SizedBox(width: ResponsiveSize.scaleWidth(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _sanitizeRoomTypeName(booking.typeRoom),
                            style: TextStyle(
                              fontSize: ResponsiveSize.text(14),
                              fontFamily: 'outfit',
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: booking.status == 'Confirmed'
                                ? Colors.green
                                : booking.status == 'Pending'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                          child: Text(
                            booking.status,
                            style: TextStyle(
                              fontSize: ResponsiveSize.text(10),
                              fontFamily: 'outfit',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.bookingLocation,
                      style: TextStyle(
                        fontSize: ResponsiveSize.text(12),
                        fontFamily: 'outfit',
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stay Period: ${DateFormat('dd MMM yyyy').format(booking.arrivalDate)} to ${DateFormat('dd MMM yyyy').format(booking.departureDate)}',
                      style: TextStyle(
                        fontSize: ResponsiveSize.text(11),
                        fontFamily: 'outfit',
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   'Submitted: ${DateFormat('dd MMM yyyy HH:mm').format(booking.createdAt)}',
                    //   style: TextStyle(
                    //     fontSize: ResponsiveSize.text(11),
                    //     fontFamily: 'outfit',
                    //     color: Colors.grey.shade500,
                    //     fontStyle: FontStyle.italic,
                    //   ),
                    // ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Spacer(),
                        Icon(Icons.star,
                            size: 16, color: Colors.purple.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${booking.pointUsed}',
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(13),
                            fontFamily: 'outfit',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalData = GlobalDataManager();
    globalData.initializeData();
    final ownerVM = Provider.of<OwnerProfileVM>(context);
    final sortedUnits = [
      ...ownerVM.unitAvailablePoints,
    ].where((unit) => unit.redemptionBalancePoints > 0.0).toList()
      ..sort((a, b) =>
          b.redemptionBalancePoints.compareTo(a.redemptionBalancePoints));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 13.width,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 10),
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
            const Spacer(),
            TextButton(
              onPressed: () {
                Uri url = Uri.parse(
                    'https://www.manamanasuites.com/freestayredemption/');
                launchUrl(url);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(70, 35),
              ),
              child: Container(
                width: ResponsiveSize.scaleWidth(70),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF3E51FF)),
                  color: const Color(0xFF3E51FF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Center(
                    child: Text(
                      "FAQ",
                      style: TextStyle(
                        fontFamily: 'outfit',
                        color: Color(0xFF3E51FF),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: Container(
        height: ResponsiveSize.scaleHeight(900),
        color: Colors.white,
        padding: const EdgeInsets.all(8),
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
                  child: ownerVM.unitAvailablePoints.isEmpty
                      ? const Center(
                          child: Text(
                            "No available points found.",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'outfit'),
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
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: ResponsiveSize.scaleWidth(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GradientText1(
                                            text:
                                                '${unit.location} - ${unit.unitNo}',
                                            style: TextStyle(
                                                fontFamily: 'outfit',
                                                fontSize:
                                                    ResponsiveSize.text(15),
                                                fontWeight: FontWeight.w700,
                                                fontFamilyFallback: const [
                                                  'outfit'
                                                ]),
                                            gradient: const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xFFB82B7D),
                                                Color(0xFF3E51FF)
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  ResponsiveSize.scaleHeight(
                                                      4)),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  ResponsiveSize.scaleWidth(8),
                                              vertical:
                                                  ResponsiveSize.scaleHeight(6),
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  97, 204, 248, 255),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Available Points',
                                                  style: TextStyle(
                                                    fontSize:
                                                        ResponsiveSize.text(12),
                                                    fontFamily: 'outfit',
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      ResponsiveSize.scaleWidth(
                                                          7),
                                                ),
                                                Text(
                                                  '${unit.redemptionBalancePoints.toInt()}/${unit.redemptionPoints.toInt()}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        ResponsiveSize.text(12),
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'outfit',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ownerVM.UserPointBalance.clear();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MultiProvider(
                                                providers: [
                                                  ChangeNotifierProvider.value(
                                                      value: globalData),
                                                  ChangeNotifierProvider.value(
                                                      value: ownerVM),
                                                ],
                                                child: ChoosePropertyLocation(
                                                  selectedLocation:
                                                      unit.location,
                                                  selectedUnitNo: unit.unitNo,
                                                  points: unit
                                                      .redemptionBalancePoints,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(70, 35),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3E51FF),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(7),
                                            child: Text(
                                              "Book Now",
                                              style: TextStyle(
                                                fontFamily: 'outfit',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )),
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

            // Filter Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterTab('All'),
                _buildFilterTab('Confirmed'),
                _buildFilterTab('Pending'),
                _buildFilterTab('Cancelled'),
              ],
            ),
            SizedBox(height: ResponsiveSize.scaleHeight(10)),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3E51FF).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: FutureBuilder<List<dynamic>>(
                  future: _getFilteredBookings(ownerVM),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "No booking history found.",
                          style: TextStyle(fontFamily: 'outfit'),
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: _buildGroupedBookings(snapshot.data!),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
