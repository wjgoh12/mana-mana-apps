import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/screens/Profile/Data/roomtype.dart';

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
  @override
  Widget build(BuildContext context) {
    String totalPoints() {
      return (widget.room.points * widget.nights).toString();
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
                          const Text('Check-In'),
                          Text(
                            widget.checkIn != null
                                ? DateFormat('EEE, MMM d, yyyy')
                                    .format(widget.checkIn!)
                                : '-',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF3E51FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
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

                      const SizedBox(width: 80),

                      /// Right column: Check-out & total points
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Check-Out'),
                          Text(
                            widget.checkOut != null
                                ? DateFormat('EEE, MMM d, yyyy')
                                    .format(widget.checkOut!)
                                : '-',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF3E51FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
