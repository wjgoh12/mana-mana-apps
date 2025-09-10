import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/roomtype.dart';
import 'package:mana_mana_app/screens/Profile/View/property_redemption.dart';
import 'package:mana_mana_app/screens/Profile/View/select_date_room.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:url_launcher/url_launcher.dart';

class RoomDetails extends StatefulWidget {
  final RoomType room;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int nights;
  final int quantity;

  const RoomDetails({
    Key? key,
    required this.room,
    this.checkIn,
    this.checkOut,
    this.nights = 1,
    this.quantity = 1,
  }) : super(key: key);

  /// Correct total points calculation

  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  final TextEditingController _guestNameController = TextEditingController();
  bool _isChecked = false; // Checkbox state
  bool _highlightCheckBox = false;

  void sendEmailToCS(String content) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'wjingggoh15@gmail.com',
      queryParameters: {
        'subject': 'Booking Request',
        'body': content,
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint('Could not launch email app');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showError = !_isChecked;
    int totalPoints() {
      return widget.room.points * widget.nights * widget.quantity;
    }

    String formattedTotalPoints() {
      final formatter = NumberFormat('#,###');
      return formatter.format(totalPoints());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image banner with arrow
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
                    child: Image.asset(
                      widget.room.image,
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
                            // spreadRadius: 2,
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
                  const Text('Room Type Selected'),
                  Text(
                    widget.room.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Color(0xFF3E51FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: ResponsiveSize.scaleWidth(150),
                            height: ResponsiveSize.scaleHeight(60),
                            child: Card(
                              color: Colors.white,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Check-In',
                                      style: TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      widget.checkIn != null
                                          ? DateFormat('EEE, MMM d, yyyy')
                                              .format(widget.checkIn!)
                                          : '-',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF3E51FF),
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'No. of Rooms',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '${widget.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xFF3E51FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 35),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Check-Out',
                                    style: TextStyle(
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    widget.checkOut != null
                                        ? DateFormat('EEE, MMM d, yyyy')
                                            .format(widget.checkOut!)
                                        : '-',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF3E51FF),
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Total Points Redeemed',
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '${formattedTotalPoints()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E51FF),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _guestNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 0.1,
                        ),
                      ),
                      hintText: 'Guest Name',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  MyCheckboxWidget(
                    initialValue: _isChecked,
                    highlight: _highlightCheckBox,
                    onChecked: (value) {
                      setState(() {
                        _isChecked = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('Booking request will be submitted for review.'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          bool isValid = true;
                          // Handle submit action
                          if (_guestNameController.text.trim().isEmpty) {
                            isValid = false;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter guest name'),
                                backgroundColor:
                                    Color.fromARGB(255, 203, 46, 46),
                              ),
                            );
                          }
                          if (!_isChecked) {
                            isValid = false;
                            setState(() {
                              _highlightCheckBox = true;
                            });
                            // Future.delayed(
                            //   const Duration(seconds: 1),
                            //   () {
                            //     setState(
                            //       () {
                            //         _highlightCheckBox = false;
                            //       },
                            //     );
                            //   },
                            // );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please confirm T&C'),
                                backgroundColor:
                                    Color.fromARGB(255, 203, 46, 46),
                                //highlight the checkbox
                              ),
                            );
                          }
                          //if user point balance insufficient
                          // Check if user has enough points
                          if (totalPoints() >
                              SelectDateRoom.getUserPointsBalance()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Insufficient points for redemption!'),
                                backgroundColor:
                                    Color.fromARGB(255, 203, 46, 46),
                              ),
                            );
                            isValid = false;
                          }

                          // Send email to CS team
                          if (isValid) {
                            final emailContent = '''
                              Booking request submitted!
                              Guest Name: ${_guestNameController.text}
                              Check-In: ${widget.checkIn}
                              Check-Out: ${widget.checkOut}
                              Total Points: ${totalPoints()}
                              ''';
                            sendEmailToCS(emailContent);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking Request Submit!'),
                              ),
                            );
                            // Navigate back to propertyRedemption page
                            // Navigator.pushAndRemoveUntil(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             const PropertyRedemption()),
                            //     ModalRoute.withName(
                            //         '/Profile/View/owner_profile_v3.dart'));

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyRedemption(),
                              ),
                              (route) => route.isFirst,
                            );

                            // The return type 'PropertyRedemption' isn't a 'void', as required by the closure's context.
                            // The `return` statement here was causing the error because the `onPressed` callback expects a `void` return.
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF3E51FF),
                          ),
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(300, 40),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
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
    );
  }
}

class MyCheckboxWidget extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChecked;
  final bool highlight; // NEW

  const MyCheckboxWidget({
    Key? key,
    this.initialValue = false,
    required this.onChecked,
    this.highlight = false,
  }) : super(key: key);

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
    // Update local state if parent changes initialValue
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
        const Text('Tick box to confirm T&C'),
      ],
    );
  }
}
