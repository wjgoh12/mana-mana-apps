import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/book_freestay/view/choose_property_location.dart';
import 'package:mana_mana_app/screens/profile/view_model/owner_profile_view_model.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyRedemption extends StatefulWidget {
  const PropertyRedemption({super.key});

  @override
  State<PropertyRedemption> createState() => _PropertyRedemptionState();
}

class _PropertyRedemptionState extends State<PropertyRedemption> {
  String selectedFilter = 'All';
  bool _isLoadingLocations = true;

  final Map<String, String> _imageCache = {};

  String _getPropertyImageByLocation(String locationName) {
    if (_imageCache.containsKey(locationName)) {
      return _imageCache[locationName]!;
    }

    final globalData = Provider.of<GlobalDataManager>(context, listen: false);

    final cleanBookingLocation = locationName
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    for (var state in globalData.locationsByState.keys) {
      final locations = globalData.locationsByState[state] ?? [];
      for (var location in locations) {
        final cleanGlobalLocation = location.locationName
            .toUpperCase()
            .replaceAll(RegExp(r'\s+'), '')
            .replaceAll(RegExp(r'[^A-Z0-9]'), '');

        if (cleanGlobalLocation.startsWith(cleanBookingLocation) ||
            cleanBookingLocation.startsWith(cleanGlobalLocation) ||
            cleanGlobalLocation.contains(cleanBookingLocation)) {
          final imageUrl = location.pic.isNotEmpty
              ? location.pic
              : 'assets/images/booking_confirmed.png';

          _imageCache[locationName] = imageUrl;
          return imageUrl;
        }
      }
    }

    const defaultImage = 'assets/images/booking_confirmed.png';
    _imageCache[locationName] = defaultImage;
    return defaultImage;
  }

  String _sanitizeRoomTypeName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;

    final firstToken = s.split(RegExp(r'\s+'))[0];

    final isAllCaps = RegExp(r'^[A-Z]+$').hasMatch(firstToken);
    if (isAllCaps && firstToken.length >= 2 && firstToken.length <= 5) {
      return s.substring(firstToken.length).trim();
    }

    return s;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final globalData = Provider.of<GlobalDataManager>(context, listen: false);

    setState(() {
      _isLoadingLocations = true;
    });

    try {
      await Future.wait([
        _loadBookingData(),
        globalData.fetchRedemptionStatesAndLocations(),
      ]);

      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing data: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
      }
    }
  }

  Future<void> _loadBookingData() async {
    if (!mounted) return;

    try {
      final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);

      await Future.wait([
        ownerVM.fetchData(),
        ownerVM.fetchUserAvailablePoints(),
        ownerVM.fetchBookingHistory(),
      ]);
    } catch (e) {
      debugPrint('❌ Error loading booking data: $e');
    }
  }

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
              fontFamily: AppFonts.outfit,
              fontSize: AppDimens.fontSizeBig,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryBlue : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredBookings(OwnerProfileVM ownerVM) {
    List<dynamic> filteredList;

    if (selectedFilter == 'All') {
      filteredList = ownerVM.bookingHistory;
    } else if (selectedFilter == 'Cancelled') {
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

    return filteredList;
  }

  List<Widget> _buildGroupedBookings(List<dynamic> bookings) {
    return bookings.map((booking) => _buildBookingCard(booking)).toList();
  }

  Widget _buildBookingCard(dynamic booking) {
    return InkWell(
      onTap: () {
        if (booking.status == "Confirmed") {
          final propertyImageBase64 =
              _getPropertyImageByLocation(booking.bookingLocation);

          showDialog(
            context: context,
            builder: (_) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height * 0.55,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: propertyImageBase64.startsWith('assets/')
                            ? AssetImage(propertyImageBase64) as ImageProvider
                            : MemoryImage(
                                propertyImageBase64.startsWith("data:image")
                                    ? Uri.parse(propertyImageBase64)
                                        .data!
                                        .contentAsBytes()
                                    : base64Decode(propertyImageBase64),
                              ),
                        fit: BoxFit.cover,
                        // colorFilter: ColorFilter.mode(
                        //   Colors.black.withOpacity(0.5),
                        //   BlendMode.darken,
                        // ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: ResponsiveSize.scaleHeight(16),
                        ),
                        // Title
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveSize.scaleWidth(50),
                                vertical: ResponsiveSize.scaleHeight(5)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Booking Confirmation',
                              style: TextStyle(
                                fontFamily: AppFonts.outfit,
                                fontSize: AppDimens.fontSizeBig,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const Spacer(),

                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10.0),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                              ),
                              child: Column(
                                children: [
                                  // Location
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Location',
                                        style: TextStyle(
                                          fontFamily: AppFonts.outfit,
                                          fontSize: AppDimens.fontSizeSmall,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        booking.bookingLocation,
                                        style: TextStyle(
                                          fontFamily: AppFonts.outfit,
                                          fontSize: AppDimens.fontSizeBig,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Divider(color: Colors.white30, thickness: 1),
                                  SizedBox(
                                      height: ResponsiveSize.scaleHeight(8)),

                                  // Room Type
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Room Type',
                                        style: TextStyle(
                                          fontFamily: AppFonts.outfit,
                                          fontSize: AppDimens.fontSizeSmall,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          _sanitizeRoomTypeName(
                                              booking.typeRoom),
                                          style: TextStyle(
                                            fontFamily: AppFonts.outfit,
                                            fontSize: AppDimens.fontSizeBig,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                      color: Colors.white30, thickness: 1),
                                  const SizedBox(height: 12),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                        child: Image.asset(
                                          'assets/images/Calendar_booking.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Check-in Date',
                                                  style: TextStyle(
                                                    fontFamily: AppFonts.outfit,
                                                    fontSize:
                                                        AppDimens.fontSizeSmall,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat('dd / MM / yyyy')
                                                      .format(
                                                          booking.arrivalDate),
                                                  style: TextStyle(
                                                    fontFamily: AppFonts.outfit,
                                                    fontSize:
                                                        AppDimens.fontSizeBig,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    ResponsiveSize.scaleHeight(
                                                        12)),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Check-out Date',
                                                  style: TextStyle(
                                                    fontFamily: AppFonts.outfit,
                                                    fontSize:
                                                        AppDimens.fontSizeSmall,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat('dd / MM / yyyy')
                                                      .format(booking
                                                          .departureDate),
                                                  style: TextStyle(
                                                    fontFamily: AppFonts.outfit,
                                                    fontSize:
                                                        AppDimens.fontSizeBig,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  const Divider(
                                      color: Colors.white30, thickness: 1),

                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Points Redeem From',
                                        style: TextStyle(
                                          fontFamily: AppFonts.outfit,
                                          fontSize: AppDimens.fontSizeSmall,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        booking.unitNo ?? 'N/A',
                                        style: TextStyle(
                                          fontFamily: AppFonts.outfit,
                                          fontSize: AppDimens.fontSizeBig,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Total Points
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Point Spend',
                                        style: TextStyle(
                                          fontFamily: AppFonts.outfit,
                                          fontSize: AppDimens.fontSizeSmall,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors.amber, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${booking.pointUsed}',
                                            style: TextStyle(
                                              fontFamily: AppFonts.outfit,
                                              fontSize: AppDimens.fontSizeBig,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: ResponsiveSize.scaleHeight(8)),
                                  TextButton(
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text('Close')),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveSize.scaleHeight(12)),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: const Color(0xFF000241).withOpacity(0.15),
              blurRadius: 10,
            )
          ],
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ResponsiveSize.scaleHeight(37),
                width: ResponsiveSize.scaleWidth(33),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2B9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.hotel,
                    color: AppColors.primaryYellow,
                    size: ResponsiveSize.scaleWidth(16)),
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
                              fontSize: AppDimens.fontSizeSmall,
                              fontFamily: AppFonts.outfit,
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
                                ? const Color(0xFFDCFCE7)
                                : booking.status == 'Pending'
                                    ? const Color(0xFFFFF696)
                                    : const Color(0xFFFEE2E1),
                          ),
                          child: Text(
                            booking.status,
                            style: TextStyle(
                              fontSize: AppDimens.fontSizeSmall,
                              fontFamily: AppFonts.outfit,
                              color: booking.status == 'Confirmed'
                                  ? const Color(0xFF2A7446)
                                  : booking.status == 'Pending'
                                      ? const Color(0xFF926021)
                                      : const Color(0xFFA63636),
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
                        fontSize: AppDimens.fontSizeSmall,
                        fontFamily: AppFonts.outfit,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dates: ${DateFormat('yyyy-MM-dd').format(booking.arrivalDate)} to ${DateFormat('yyyy-MM-dd').format(booking.departureDate)}',
                          style: TextStyle(
                            fontSize: AppDimens.fontSizeSmall,
                            fontFamily: AppFonts.outfit,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 16, color: Colors.purple.shade400),
                            const SizedBox(width: 4),
                            Text(
                              '${booking.pointUsed}',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeSmall,
                                fontFamily: AppFonts.outfit,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   'Submitted: ${DateFormat('dd MMM yyyy HH:mm').format(booking.createdAt)}',
                    //   style: TextStyle(
                    //     fontSize: AppDimens.fontSizeSmall,
                    //     fontFamily: AppFonts.outfit,
                    //     color: Colors.grey.shade500,
                    //     fontStyle: FontStyle.italic,
                    //   ),
                    // ),
                    // const SizedBox(height: 4),
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
    // ✅ Remove unnecessary GlobalDataManager initialization here
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
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  'Free Stay Redemptions',
                  style: TextStyle(
                    color: AppColors.primaryGrey,
                    fontFamily: AppFonts.outfit,
                    fontSize: AppDimens.fontSizeBig,
                    fontWeight: FontWeight.w700,
                  ),
                )),
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
                  color: AppColors.primaryGrey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Center(
                    child: Text(
                      "FAQ",
                      style: TextStyle(
                        fontFamily: AppFonts.outfit,
                        color: Colors.white,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Redemption List',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize: AppDimens.fontSizeBig,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                  height: ResponsiveSize.scaleHeight(330),
                  child: ownerVM.unitAvailablePoints.isEmpty
                      ? const Center(
                          child: Text(
                            "No available points found.",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.outfit),
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
                                      color:
                                          Color(0xFF000241).withOpacity(0.15),
                                      blurRadius: 10,
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
                                          Text(
                                            '${unit.location} - ${unit.unitNo}',
                                            style: TextStyle(
                                              fontFamily: AppFonts.outfit,
                                              fontSize: AppDimens.fontSizeBig,
                                              fontWeight: FontWeight.w700,
                                              fontFamilyFallback: const [
                                                'outfit'
                                              ],
                                              color: AppColors.primaryGrey,
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
                                              color: AppColors.primaryYellow,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Available Points',
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppDimens.fontSizeSmall,
                                                    fontFamily: AppFonts.outfit,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      ResponsiveSize.scaleWidth(
                                                          10),
                                                ),
                                                Text(
                                                  '${unit.redemptionBalancePoints.toInt()}/${unit.redemptionPoints.toInt()}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppDimens.fontSizeSmall,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: AppFonts.outfit,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final globalData =
                                              Provider.of<GlobalDataManager>(
                                                  context,
                                                  listen: false);
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
                                            color: AppColors.primaryGrey,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              "Book Now",
                                              style: TextStyle(
                                                fontFamily: AppFonts.outfit,
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
            SizedBox(height: ResponsiveSize.scaleHeight(5)),
            Center(
              child: Text(
                'Booking History',
                style: TextStyle(
                  fontFamily: AppFonts.outfit,
                  fontSize: AppDimens.fontSizeBig,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: ResponsiveSize.scaleHeight(10)),
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
                child: Builder(
                  builder: (context) {
                    if (_isLoadingLocations) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF3E51FF),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Loading property locations...",
                              style: TextStyle(fontFamily: AppFonts.outfit),
                            ),
                          ],
                        ),
                      );
                    }

                    // Get filtered bookings directly (no async needed)
                    final filteredBookings = _getFilteredBookings(ownerVM);

                    if (filteredBookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "No booking history found.",
                              style: TextStyle(fontFamily: AppFonts.outfit),
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: _loadBookingData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF3E51FF),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadBookingData,
                      color: const Color(0xFF3E51FF),
                      child: ListView(
                        // Key forces rebuild when filter changes or data refreshes
                        key: ValueKey(
                            '${selectedFilter}_${ownerVM.bookingHistory.length}'),
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: _buildGroupedBookings(filteredBookings),
                      ),
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
