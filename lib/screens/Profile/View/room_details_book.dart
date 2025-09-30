import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/bookingRoom.dart';
import 'package:mana_mana_app/model/roomType.dart';
import 'package:mana_mana_app/model/unitAvailablePoints.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// This shows the modifications needed for RoomDetails class to handle booking mode
// Add this parameter to the RoomDetails constructor and modify the class accordingly

class RoomDetailsBook extends StatefulWidget {
  final RoomType room;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int quantity;
  final double userPointsBalance;
  final String ownerLocation;
  final String ownerUnitNo;
  final String bookingLocationName;
  final bool isBookingMode; // NEW: Add this parameter

  const RoomDetailsBook({
    Key? key,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.quantity,
    required this.userPointsBalance,
    required this.ownerLocation,
    required this.ownerUnitNo,
    required this.bookingLocationName,
    this.isBookingMode = false,
  }) : super(key: key);

  @override
  _RoomDetailsBookState createState() => _RoomDetailsBookState();
}

class _RoomDetailsBookState extends State<RoomDetailsBook> {
  final TextEditingController _guestNameController = TextEditingController();
  bool _isChecked = false;
  bool _highlightCheckBox = false;
  bool _isSubmitting = false;

  String? _getLocationCode(String locationName) {
    switch (locationName.toUpperCase()) {
      case "EXPRESSIONZ":
        return "EXPR";
      case "CEYLONZ":
        return "CEYL";
      case "SCARLETZ":
        return "SCAR";
      case "MILLERZ":
        return "MILL";
      case "MOSSAZ":
        return "MOSS";
      case "PAXTONZ":
        return "PAXT";
      default:
        return null;
    }
  }

  void sendEmailToCS(String content) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: '',
      queryParameters: {'subject': 'Booking Request', 'body': content},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint('Could not launch email app');
    }
  }

  double totalPoints() => widget.room.roomTypePoints;

  String formattedTotalPoints() {
    final formatter = NumberFormat('#,###');
    return formatter.format(totalPoints());
  }

  @override
  Widget build(BuildContext context) {
    final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);

// get matching state
    final propertyState =
        ownerVM.findPropertyStateForOwner(widget.ownerLocation);
    if (propertyState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("No property state found for ${widget.ownerLocation}")),
      );
      return SizedBox();
    }

    final bookingRoom = BookingRoom(
      roomType: widget.room,
      bookingLocationName: widget.bookingLocationName,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Image banner with back arrow
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: Image.memory(
                        base64Decode(widget.room.pic),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              /// Room details card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Type',
                        style: TextStyle(
                            fontSize: ResponsiveSize.text(15),
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold)),
                    Text(widget.room.roomTypeName,
                        style: TextStyle(
                            fontSize: ResponsiveSize.text(20),
                            fontFamily: 'Outfit',
                            color: Color(0xFF3E51FF),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    /// Check-in / Check-out row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDateCard('Check-In', widget.checkIn),
                        SizedBox(width: ResponsiveSize.scaleWidth(2)),
                        _buildDateCard('Check-Out', widget.checkOut),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// No. of Rooms & Total Points
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('No. of Rooms', '${widget.quantity}'),
                        _buildInfoColumn(
                            'Total Points Redeemed', formattedTotalPoints(),
                            crossEnd: true),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// Guest name input
                    TextField(
                      controller: _guestNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        hintText: 'Guest Name',
                        hintStyle: TextStyle(
                            fontSize: ResponsiveSize.text(14),
                            fontFamily: 'Outfit'),
                      ),
                    ),
                    MyCheckboxWidget(
                      initialValue: _isChecked,
                      highlight: _highlightCheckBox,
                      onChecked: (value) {
                        setState(() {
                          _isChecked = value;
                          if (value) _highlightCheckBox = false;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Booking request will be submitted for review.',
                      style: TextStyle(
                        fontSize: ResponsiveSize.text(12),
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Submit button
                    Center(
                      child: TextButton(
                        onPressed: _isSubmitting
                            ? null // Disable button while submitting
                            : () async {
                                bool isValid = true;

                                // Check validations before setting loading state
                                if (_guestNameController.text.trim().isEmpty) {
                                  isValid = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please enter guest name'),
                                        backgroundColor:
                                            Color.fromARGB(255, 203, 46, 46)),
                                  );
                                }

                                if (!_isChecked) {
                                  isValid = false;
                                  setState(() {
                                    _highlightCheckBox = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please confirm T&C'),
                                        backgroundColor:
                                            Color.fromARGB(255, 203, 46, 46)),
                                  );
                                }

                                // Only set loading state if form is valid
                                if (isValid) {
                                  setState(() {
                                    _isSubmitting = true;
                                  });
                                }

                                if (totalPoints() > widget.userPointsBalance) {
                                  isValid = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Insufficient points for redemption!'),
                                        backgroundColor:
                                            Color.fromARGB(255, 203, 46, 46)),
                                  );
                                }

                                if (isValid) {
                                  final ownerVM = Provider.of<OwnerProfileVM>(
                                      context,
                                      listen: false);

                                  try {
                                    final userEmail = ownerVM.users.isNotEmpty
                                        ? ownerVM.users.first.email ?? ''
                                        : '';
                                    if (userEmail.isEmpty)
                                      throw Exception("No user email");

                                    final locationCode =
                                        _getLocationCode(widget.ownerLocation);
                                    if (locationCode == null)
                                      throw Exception(
                                          "Invalid location: ${widget.ownerLocation}");

                                    final point = UnitAvailablePoint(
                                      location: locationCode,
                                      unitNo: widget.ownerUnitNo,
                                      redemptionBalancePoints:
                                          widget.userPointsBalance,
                                      email: userEmail,
                                      redemptionPoints: totalPoints(),
                                    );

                                    final result = await ownerVM.submitBooking(
                                      bookingRoom: bookingRoom,
                                      point: point,
                                      propertyStates: [
                                        propertyState
                                      ], // wrap in a list if submitBooking expects list
                                      checkIn: widget.checkIn,
                                      checkOut: widget.checkOut,
                                      quantity: widget.quantity,
                                      points: totalPoints(),
                                      guestName:
                                          _guestNameController.text.trim(),
                                    );

                                    if (result != null) {
                                      final emailContent = '''
Booking request submitted!
Guest Name: ${_guestNameController.text}
Check-In: ${widget.checkIn}
Check-Out: ${widget.checkOut}
Total Points: ${totalPoints()}
''';
                                      sendEmailToCS(emailContent);

                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          contentPadding: const EdgeInsets.all(
                                              16), // reduce padding if needed
                                          content: Column(
                                            mainAxisSize: MainAxisSize
                                                .min, // shrink dialog height
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Request Received!',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Outfit'),
                                              ),
                                              SizedBox(
                                                  height: ResponsiveSize
                                                      .scaleHeight(
                                                          3)), // reduce spacing
                                              const Text(
                                                'You will be notified once your booking is confirmed​',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'Outfit'),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF3E51FF),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context); // Close dialog
                                                Navigator.pop(
                                                    context); // Back to room selection
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: const Center(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Outfit')),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to submit booking. Please try again.',
                                            style:
                                                TextStyle(fontFamily: 'Outfit'),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    // Reset submitting state whether successful or not
                                    if (mounted) {
                                      setState(() {
                                        _isSubmitting = false;
                                      });
                                    }
                                  }
                                }
                              },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF3E51FF),
                          fixedSize: const Size(300, 40),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: ResponsiveSize.text(17)),
                              ),
                      ),
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

  Widget _buildDateCard(String title, DateTime? date) {
    return Card(
      color: Colors.white,
      child: Container(
        width: ResponsiveSize.scaleWidth(150),
        height: ResponsiveSize.scaleHeight(60),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: ResponsiveSize.text(11),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit')),
            Text(
              date != null ? DateFormat('EEE, MMM d, yyyy').format(date) : '-',
              style: TextStyle(
                  fontSize: ResponsiveSize.text(12),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  color: Color(0xFF3E51FF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, {bool crossEnd = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment:
            crossEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: ResponsiveSize.text(11), fontFamily: 'Outfit')),
          Text(value,
              style: TextStyle(
                  fontSize: ResponsiveSize.text(16),
                  fontFamily: 'Outfit',
                  color: Color(0xFF3E51FF),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class MyCheckboxWidget extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChecked;
  final bool highlight;

  const MyCheckboxWidget(
      {Key? key,
      this.initialValue = false,
      required this.onChecked,
      this.highlight = false})
      : super(key: key);

  @override
  State<MyCheckboxWidget> createState() => _MyCheckboxWidgetState();
}

class _MyCheckboxWidgetState extends State<MyCheckboxWidget> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant MyCheckboxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      isChecked = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          side: BorderSide(
              color: widget.highlight ? Colors.red : Colors.grey, width: 2),
          onChanged: (value) {
            setState(() {
              isChecked = value ?? false;
            });
            widget.onChecked(isChecked);
          },
        ),
        Row(
          children: [
            Text(
              'Tick box to confirm ',
              style: TextStyle(
                fontSize: ResponsiveSize.text(13),
                fontFamily: 'Outfit',
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontSize: ResponsiveSize.text(18),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: const Color(0xFF3E51FF),
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          // Guarantee
                          Text("Guarantee:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "All bookings must be guaranteed with valid payment or points redemption at the time of reservation. Pending submissions are not a guaranteed reservation until they are confirmed by the reservations team.\n",
                            textAlign: TextAlign.justify,
                          ),

                          // Booking Status
                          Text("Booking Status:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "Pending (your request has been received), Confirmed (your booking has been confirmed), Unavailable (your request has been denied due to hotel unavailability).\n",
                            textAlign: TextAlign.justify,
                          ),

                          // Check-in / Check-out
                          Text("Check-in / Check-out:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "Check-in from 3PM, check-out by 11AM. Early check-in or late check-out is subject to availability and may have extra charges.\n",
                            textAlign: TextAlign.justify,
                          ),

                          // Cancellations
                          Text("Cancellations:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "Cancel at least 3 days before arrival for a full refund of points or payment. Cancellations within 3 days or no-shows are non-refundable.\n",
                            textAlign: TextAlign.justify,
                          ),

                          // Changes
                          Text("Changes:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "Date changes must be made at least 3 days before arrival and are subject to room availability.\n",
                            textAlign: TextAlign.justify,
                          ),

                          // ID
                          Text("ID:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Please present a valid ID at check-in.\n"),

                          // Hotel Rights
                          Text("Hotel Rights:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "The hotel may cancel or adjust bookings in case of misuse or fraud.\n",
                            textAlign: TextAlign.justify,
                          ),

                          // Valuables
                          Text("Valuables:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            "The hotel is not responsible for items left inside the room.\n",
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Center(
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 20),
                          label: Text(
                            "Close",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveSize.text(15),
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'T&C',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: const Color(0xFF3E51FF),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveSize.text(13),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
