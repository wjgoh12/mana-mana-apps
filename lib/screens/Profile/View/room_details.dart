import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/bookingRoom.dart';
import 'package:mana_mana_app/model/roomType.dart';
import 'package:mana_mana_app/model/unitAvailablePoints.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:provider/provider.dart';

class RoomDetails extends StatefulWidget {
  final RoomType room;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int quantity;
  final double userPointsBalance;
  final String ownerLocation;
  final String ownerUnitNo;
  final String bookingLocationName;
  final bool isBookingMode;

  const RoomDetails({
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
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  final TextEditingController _guestNameController = TextEditingController();
  bool _isChecked = false;
  bool _highlightCheckBox = false;
  bool _isSubmitting = false;

  // TODO: Replace with your actual admin email
  // ignore: constant_identifier_names
  static const String ADMIN_EMAIL = 'admin@example.com';

  // Send email notification to admin (via backend API)
  Future<void> sendEmailNotificationToAdmin({
    required String guestName,
    required String userEmail,
    required DateTime? checkIn,
    required DateTime? checkOut,
    required int points,
    required String roomType,
    required String bookingLocation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-backend-api.com/send-booking-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': ADMIN_EMAIL,
          'subject': 'New Booking Request - $bookingLocation',
          'guestName': guestName,
          'userEmail': userEmail,
          'roomType': roomType,
          'bookingLocation': bookingLocation,
          'checkIn': checkIn?.toIso8601String(),
          'checkOut': checkOut?.toIso8601String(),
          'totalPoints': points,
          'submissionDateTime': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send email notification');
      }

      debugPrint('✅ Email notification sent to admin: $ADMIN_EMAIL');
    } catch (e) {
      debugPrint('❌ Error sending email notification: $e');
      // Don’t throw, so booking still goes through
    }
  }

  double totalPoints() => widget.room.roomTypePoints;

  String formattedTotalPoints() {
    final formatter = NumberFormat('#,###');
    return formatter.format(totalPoints());
  }

  String sanitizeRoomTypeName(String raw) {
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
  Widget build(BuildContext context) {
    final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);
    final displayRoom = sanitizeRoomTypeName(widget.room.roomTypeName);

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
                    Text(displayRoom,
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
                    const SizedBox(height: 16),

                    /// Expandable Terms Widget
                    ExpandableTermsWidget(
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
                            ? null
                            : () async {
                                bool isValid = true;

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
                                  setState(() {
                                    _isSubmitting = true;
                                  });

                                  final ownerVM = Provider.of<OwnerProfileVM>(
                                      context,
                                      listen: false);

                                  try {
                                    // Record submission date/time at the moment of booking

                                    final userEmail = ownerVM.users.isNotEmpty
                                        ? ownerVM.users.first.email ?? ''
                                        : '';
                                    if (userEmail.isEmpty)
                                      throw Exception("No user email");

                                    final point = UnitAvailablePoint(
                                      location: widget.ownerLocation,
                                      unitNo: widget.ownerUnitNo,
                                      redemptionBalancePoints:
                                          widget.userPointsBalance,
                                      email: userEmail,
                                      redemptionPoints: totalPoints(),
                                    );

                                    final result = await ownerVM.submitBooking(
                                      bookingRoom: bookingRoom,
                                      point: point,
                                      propertyStates: [propertyState],
                                      checkIn: widget.checkIn,
                                      checkOut: widget.checkOut,
                                      quantity: widget.quantity,
                                      points: totalPoints(),
                                      guestName:
                                          _guestNameController.text.trim(),
                                    );

                                    if (result != null) {
                                      // Send email notification to admin
                                      // await sendEmailNotificationToAdmin(
                                      //   guestName:
                                      //       _guestNameController.text.trim(),
                                      //   userEmail: userEmail,
                                      //   checkIn: widget.checkIn,
                                      //   checkOut: widget.checkOut,
                                      //   points: totalPoints(),
                                      //   roomType: widget.room.roomTypeName,
                                      //   bookingLocation:
                                      //       widget.bookingLocationName,
                                      // );

                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
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
                                                      .scaleHeight(3)),
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
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                Navigator.pop(context);
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
                    const SizedBox(height: 20),
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

// Expandable Terms Widget
class ExpandableTermsWidget extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChecked;
  final bool highlight;

  const ExpandableTermsWidget({
    Key? key,
    this.initialValue = false,
    required this.onChecked,
    this.highlight = false,
  }) : super(key: key);

  @override
  State<ExpandableTermsWidget> createState() => _ExpandableTermsWidgetState();
}

class _ExpandableTermsWidgetState extends State<ExpandableTermsWidget> {
  late bool isChecked;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant ExpandableTermsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      isChecked = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expandable T&C Card
        Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Header
              InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF3E51FF),
                      ),
                      const SizedBox(width: 8),
                      GradientText1(
                        text: isExpanded
                            ? 'Hide Terms & Conditions'
                            : 'View Terms & Conditions',
                        style: TextStyle(
                          fontSize: ResponsiveSize.text(13),
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable content
              if (isExpanded)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: ResponsiveSize.text(14),
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTermItem(
                        'Guarantee',
                        'All bookings must be guaranteed with valid payment or points redemption at the time of reservation. Pending submissions are not a guaranteed reservation until they are confirmed by the reservations team.',
                      ),
                      _buildTermItem(
                        'Booking Status',
                        'Pending (your request has been received), Confirmed (your booking has been confirmed), Unavailable (your request has been denied due to hotel unavailability).',
                      ),
                      _buildTermItem(
                        'Check-in / Check-out',
                        'Check-in from 3PM, check-out by 11AM. Early check-in or late check-out is subject to availability and may have extra charges.',
                      ),
                      _buildTermItem(
                        'Cancellations',
                        'Cancel at least 3 days before arrival for a full refund of points or payment. Cancellations within 3 days or no-shows are non-refundable.',
                      ),
                      _buildTermItem(
                        'Changes',
                        'Date changes must be made at least 3 days before arrival and are subject to room availability.',
                      ),
                      _buildTermItem(
                        'ID',
                        'Please present a valid ID at check-in.',
                      ),
                      _buildTermItem(
                        'Hotel Rights',
                        'The hotel may cancel or adjust bookings in case of misuse or fraud.',
                      ),
                      _buildTermItem(
                        'Valuables',
                        'The hotel is not responsible for items left inside the room.',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Checkbox row
        Row(
          children: [
            Checkbox(
              value: isChecked,
              side: BorderSide(
                color: widget.highlight ? Colors.red : Colors.grey,
                width: 2,
              ),
              onChanged: (value) {
                setState(() {
                  isChecked = value ?? false;
                });
                widget.onChecked(isChecked);
              },
            ),
            Expanded(
              child: Text(
                'I have read and agree to the T&C',
                style: TextStyle(
                  fontSize: ResponsiveSize.text(13),
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: TextStyle(
              fontSize: ResponsiveSize.text(12),
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              content,
              style: TextStyle(
                fontSize: ResponsiveSize.text(11),
                fontFamily: 'Outfit',
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
