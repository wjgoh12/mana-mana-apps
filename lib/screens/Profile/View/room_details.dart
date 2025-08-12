import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/Profile/Data/roomtype.dart';
import 'package:url_launcher/url_launcher.dart';

class RoomDetails extends StatefulWidget {
  final RoomType room;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int nights;

  const RoomDetails({
    Key? key,
    required this.room,
    this.checkIn,
    this.checkOut,
    this.nights = 1,
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
      path: 'cs@yourcompany.com',
      query: Uri.encodeFull('subject=Booking Request&body=$content'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email app';
    }
  }

  @override
  Widget build(BuildContext context) {
    String totalPoints() {
      final formatter = NumberFormat('#,###');
      return formatter.format(widget.room.points * widget.nights);
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /// Left column: Check-in & rooms
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
                                  const Text('Check-In'),
                                  Text(
                                    widget.checkIn != null
                                        ? DateFormat('EEE, MMM d, yyyy')
                                            .format(widget.checkIn!)
                                        : '-',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF3E51FF),
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('No. of Rooms'),
                          Text(
                            '${widget.room.quantity}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF3E51FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 70),

                      /// Right column: Check-out & total points
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
                                  const Text('Check-Out'),
                                  Text(
                                    widget.checkOut != null
                                        ? DateFormat('EEE, MMM d, yyyy')
                                            .format(widget.checkOut!)
                                        : '-',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF3E51FF),
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('Total Points Redeemed'),
                          Text(
                            '${totalPoints()}',
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
                    onChecked: (value) {
                      setState(() {
                        _isChecked = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  const Text('Booking request will be submitted for review.'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Handle submit action
                          if (_guestNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter guest name'),
                              ),
                            );
                            return;
                          } else if (!_isChecked) {
                            setState(() {
                              _highlightCheckBox = true;
                            });
                            Future.delayed(const Duration(seconds: 1), () {
                              setState(() {
                                _highlightCheckBox = false;
                              });
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please confirm T&C'),
                                //highlight the checkbox
                              ),
                            );
                            return;
                          }
                          // Send email to CS team
                          final emailContent = '''
                            Booking request submitted!
                            Guest Name: ${_guestNameController.text}
                            Check-In: ${widget.checkIn}
                            Check-Out: ${widget.checkOut}
                            Total Points: ${totalPoints()}
                          ''';
                          sendEmailToCS(emailContent);
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

  const MyCheckboxWidget({
    Key? key,
    this.initialValue = false,
    required this.onChecked,
  }) : super(key: key);

  @override
  State<MyCheckboxWidget> createState() => _MyCheckboxWidgetState();
}

class _MyCheckboxWidgetState extends State<MyCheckboxWidget> {
  bool isChecked = false; // start unchecked

  void toggleIsChecked(bool value) {
    setState(() {
      isChecked = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = value ?? false;
              print('Checkbox is now: $isChecked');
            });
          },
        ),
        const Text('Tick box to confirm T&C'),
      ],
    );
  }
}
