import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/roomtype.dart';
import 'package:mana_mana_app/screens/profile/widgets/quantity_controller.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class RoomtypeCardDetail extends StatefulWidget {
  final RoomType roomType;
  final String displayName;
  final bool isSelected;
  final bool multiSelectable;
  final bool enabled;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final int numberofPax;
  final int numBedrooms;
  final Function(RoomType? room)? onSelect;
  final Function(int quantity)? onQuantityChanged;
  final bool Function(RoomType room, int duration) checkAffordable;

  const RoomtypeCardDetail({
    super.key,
    required this.roomType,
    required this.displayName,
    this.isSelected = false,
    this.enabled = true,
    required this.startDate,
    required this.endDate,
    this.quantity = 1,
    this.numberofPax = 1,
    this.numBedrooms = 1,
    this.onSelect,
    this.onQuantityChanged,
    this.multiSelectable = false,
    required this.checkAffordable,
  });

  @override
  State<RoomtypeCardDetail> createState() => _RoomtypeCardDetailState();
}

class _RoomtypeCardDetailState extends State<RoomtypeCardDetail>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _bytes;
  bool _decoding = false;
  // Local selection state used when multiSelectable == true
  bool _localSelected = false;

  @override
  void initState() {
    super.initState();
    _localSelected = widget.isSelected;
    _decodeOnce();
  }

  @override
  void didUpdateWidget(covariant RoomtypeCardDetail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.multiSelectable && oldWidget.isSelected != widget.isSelected) {
      _localSelected = widget.isSelected;
    }
  }

  Future<void> _decodeOnce() async {
    if (_bytes != null || _decoding) return;
    _decoding = true;

    try {
      if (widget.roomType.pic.isEmpty) {
        _bytes = null;
      } else if (widget.roomType.pic.startsWith('data:image')) {
        final data = Uri.parse(widget.roomType.pic).data;
        _bytes = data?.contentAsBytes();
      } else {
        _bytes = base64Decode(widget.roomType.pic);
      }
    } catch (e) {
      _bytes = null;
    } finally {
      if (mounted) {
        _decoding = false;
        setState(() {});
      }
    }
  }

  @override
  bool get wantKeepAlive => true; // keep decoded bytes alive

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFCF00);
    super.build(context); // for AutomaticKeepAliveClientMixin

    // Use the cached _bytes (or placeholder)
    final imageWidget = _bytes != null
        ? Image.memory(
            _bytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.width >= 600 ? 200 : 180,
          )
        : Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width >= 600 ? 230 : 180,
            color: Colors.grey[300],
            child: const Center(
              child:
                  Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            ),
          );

    final int duration = widget.endDate.difference(widget.startDate).inDays;
    final bool canAfford = widget.checkAffordable(widget.roomType, duration);

    final bool displayedSelected =
        widget.multiSelectable ? _localSelected : widget.isSelected;

    return Container(
      margin: const EdgeInsets.all(8),
      constraints: BoxConstraints(
          minHeight: displayedSelected
              ? (MediaQuery.of(context).size.width >= 600 ? 450 : 380)
              : (MediaQuery.of(context).size.width >= 600 ? 400 : 350)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (!canAfford) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Insufficient points for ${widget.displayName}. Required points: ${NumberFormat("#,###").format(widget.roomType.roomTypePoints)}',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            if (!widget.enabled) return;

            // If multiSelectable is enabled, manage selection locally so
            // multiple cards can be selected independently. Otherwise,
            // fallback to parent-controlled selection behavior (single-select).
            if (widget.multiSelectable) {
              _localSelected = !_localSelected;
              setState(() {});
              if (_localSelected) {
                widget.onSelect?.call(widget.roomType);
              } else {
                widget.onSelect?.call(null);
              }
            } else {
              if (widget.isSelected) {
                widget.onSelect?.call(null);
              } else {
                widget.onSelect?.call(widget.roomType);
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Stack Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height:
                          MediaQuery.of(context).size.width >= 600 ? 200 : 180,
                      child: imageWidget,
                    ),
                  ),
                  // Unaffordable overlay
                  if (!canAfford)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  // selection overlay - use Positioned.fill so the badge
                  // is always centered vertically within the image area
                  Positioned.fill(
                    child: Stack(
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: displayedSelected ? 0.55 : 0.0,
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.width >= 600
                                ? 200
                                : 180,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        if (displayedSelected)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: yellow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'You\'ve Selected This Unit',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveSize.text(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // bottom gradient + name + points
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.displayName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveSize.text(12),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // disabled overlay when not affordable
                  if (!widget.enabled)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Room Info Section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Info',
                            style: TextStyle(
                              fontSize: ResponsiveSize.text(11),
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.roomType.numBedrooms == 1)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.roomType.bedroomDetails.isNotEmpty)
                                  Row(
                                    children: [
                                      Text(
                                        'Room 1',
                                        style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'Outfit',
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(8)),
                                      // Only render bedroom1 icon + text if value exists
                                      Image.asset('assets/images/bed_img.png',
                                          height:
                                              ResponsiveSize.scaleHeight(14),
                                          width: ResponsiveSize.scaleWidth(14)),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(4)),
                                      Text(
                                        '${widget.roomType.bedroomDetails[0].bedtype1} bed ',
                                        style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'Outfit',
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      // Only render the second bed icon + value when room1BedType2 is present
                                      if (widget.roomType.bedroomDetails[0]
                                          .bedtype2.isNotEmpty) ...[
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(8)),
                                        Image.asset('assets/images/bed_img.png',
                                            height:
                                                ResponsiveSize.scaleHeight(14),
                                            width:
                                                ResponsiveSize.scaleWidth(14)),
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(4)),
                                        Text(
                                          '${widget.roomType.bedroomDetails[0].bedtype2} bed ',
                                          style: TextStyle(
                                            fontSize: ResponsiveSize.text(11),
                                            fontFamily: 'Outfit',
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                if (widget.roomType.bedroomDetails.length > 1)
                                  Row(
                                    children: [
                                      Text(
                                        'Room 2',
                                        style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'Outfit',
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(8)),
                                      // Only show icon + text when bedRoom2 has value
                                      Image.asset('assets/images/bed_img.png',
                                          height:
                                              ResponsiveSize.scaleHeight(14),
                                          width: ResponsiveSize.scaleWidth(14)),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(4)),
                                      Text(
                                        '${widget.roomType.bedroomDetails[1].bedtype1} bed ',
                                        style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'Outfit',
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      // Only render room2BedType2 when it is non-empty
                                      if (widget.roomType.bedroomDetails[1]
                                          .bedtype2.isNotEmpty) ...[
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(8)),
                                        Image.asset('assets/images/bed_img.png',
                                            height:
                                                ResponsiveSize.scaleHeight(14),
                                            width:
                                                ResponsiveSize.scaleWidth(14)),
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(4)),
                                        Text(
                                          '${widget.roomType.bedroomDetails[1].bedtype2} bed ',
                                          style: TextStyle(
                                            fontSize: ResponsiveSize.text(11),
                                            fontFamily: 'Outfit',
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          if (widget.roomType.numBedrooms == 2)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.roomType.bedroomDetails.isNotEmpty)
                                  Row(
                                    children: [
                                      Text(
                                        'Room 1',
                                        style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'Outfit',
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(8)),
                                      Image.asset('assets/images/bed_img.png',
                                          height:
                                              ResponsiveSize.scaleHeight(14),
                                          width: ResponsiveSize.scaleWidth(14)),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(4)),
                                      Text(
                                        '${widget.roomType.bedroomDetails[0].bedtype1} bed ',
                                        style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'Outfit',
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      // only show second bed type when present
                                      if (widget.roomType.bedroomDetails[0]
                                          .bedtype2.isNotEmpty) ...[
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(8)),
                                        Image.asset('assets/images/bed_img.png',
                                            height:
                                                ResponsiveSize.scaleHeight(14),
                                            width:
                                                ResponsiveSize.scaleWidth(14)),
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(4)),
                                        Text(
                                          '${widget.roomType.bedroomDetails[0].bedtype2} bed ',
                                          style: TextStyle(
                                            fontSize: ResponsiveSize.text(11),
                                            fontFamily: 'Outfit',
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                if (widget.roomType.bedroomDetails.length > 1)
                                  Row(
                                    children: [
                                      Text(
                                        'Room 2',
                                        style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'Outfit',
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(8)),
                                      Image.asset('assets/images/bed_img.png',
                                          height:
                                              ResponsiveSize.scaleHeight(14),
                                          width: ResponsiveSize.scaleWidth(14)),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(4)),
                                      Text(
                                        '${widget.roomType.bedroomDetails[1].bedtype1} bed ',
                                        style: TextStyle(
                                          fontSize: ResponsiveSize.text(11),
                                          fontFamily: 'Outfit',
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (widget.roomType.bedroomDetails[1]
                                          .bedtype2.isNotEmpty) ...[
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(8)),
                                        Image.asset('assets/images/bed_img.png',
                                            height:
                                                ResponsiveSize.scaleHeight(14),
                                            width:
                                                ResponsiveSize.scaleWidth(14)),
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(4)),
                                        Text(
                                          '${widget.roomType.bedroomDetails[1].bedtype2} bed ',
                                          style: TextStyle(
                                            fontSize: ResponsiveSize.text(11),
                                            fontFamily: 'Outfit',
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          if (widget.roomType.numBedrooms == 0)
                            Text(
                              'Null',
                              style: TextStyle(
                                fontSize: ResponsiveSize.text(11),
                                fontFamily: 'Outfit',
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'No of Guests',
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(11),
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/roomtypeguest.png',
                              height: ResponsiveSize.scaleHeight(14),
                              width: ResponsiveSize.scaleWidth(14),
                            ),
                            SizedBox(width: ResponsiveSize.scaleWidth(6)),
                            Text(
                              widget.numberofPax.toString(),
                              style: TextStyle(
                                fontSize: ResponsiveSize.text(11),
                                fontFamily: 'Outfit',
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amenities Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Amenities Available',
                      style: TextStyle(
                        fontSize: ResponsiveSize.text(11),
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Builder(builder: (context) {
                        final bedroomDetails = widget.roomType.bedroomDetails;
                        final hasAnyFacilities = bedroomDetails.any(
                            (bedroom) => bedroom.bedroomFacilities.isNotEmpty);

                        if (!hasAnyFacilities) {
                          return Text(
                            'None',
                            style: TextStyle(
                              fontSize: ResponsiveSize.text(11),
                              fontFamily: 'Outfit',
                              color: Colors.grey[600],
                            ),
                          );
                        }

                        // Build facilities grouped by room
                        List<Widget> roomFacilityWidgets = [];
                        for (int i = 0; i < bedroomDetails.length; i++) {
                          final bedroom = bedroomDetails[i];
                          if (bedroom.bedroomFacilities.isNotEmpty) {
                            for (final facility in bedroom.bedroomFacilities) {
                              roomFacilityWidgets.add(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Room ${i + 1}',
                                      style: TextStyle(
                                        fontSize: ResponsiveSize.text(11),
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                        width: ResponsiveSize.scaleWidth(12)),
                                    if (facility.icon.isNotEmpty)
                                      Image.memory(
                                        base64Decode(facility.icon),
                                        height: ResponsiveSize.scaleHeight(16),
                                        width: ResponsiveSize.scaleWidth(16),
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Fallback if image decode fails
                                          return Icon(
                                            Icons.check_circle_outline,
                                            size:
                                                ResponsiveSize.scaleHeight(16),
                                            color: Colors.grey[600],
                                          );
                                        },
                                      ),
                                    if (facility.icon.isNotEmpty)
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(4)),
                                    Text(
                                      facility.facilitiesName,
                                      style: TextStyle(
                                        fontSize: ResponsiveSize.text(11),
                                        fontFamily: 'Outfit',
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: roomFacilityWidgets.map((widget) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: ResponsiveSize.scaleHeight(6)),
                              child: widget,
                            );
                          }).toList(),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (displayedSelected)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Number of Rooms:',
                                style: TextStyle(
                                  fontSize: ResponsiveSize.text(11),
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            QuantityController(
                              initialValue: widget.quantity,
                              onChanged: (val) {
                                widget.onQuantityChanged?.call(val);
                              },
                            ),
                          ],
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
}
