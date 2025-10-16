import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/roomType.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class RoomtypeCard extends StatefulWidget {
  final RoomType roomType;
  final String displayName;
  final bool isSelected;
  final bool enabled;
  final DateTime startDate;
  final DateTime endDate;
  final Function(RoomType? room)? onSelect;
  final bool Function(RoomType room, int duration) checkAffordable;

  const RoomtypeCard({
    super.key,
    required this.roomType,
    required this.displayName,
    this.isSelected = false,
    this.enabled = true,
    required this.startDate,
    required this.endDate,
    this.onSelect,
    required this.checkAffordable,
  });

  @override
  State<RoomtypeCard> createState() => _RoomtypeCardState();
}

class _RoomtypeCardState extends State<RoomtypeCard>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _bytes;
  bool _decoding = false;

  @override
  void initState() {
    super.initState();
    _decodeOnce();
  }

  Future<void> _decodeOnce() async {
    if (_bytes != null || _decoding) return;
    _decoding = true;

    try {
      if (widget.roomType.pic.isEmpty) {
        _bytes = null;
      } else if (widget.roomType.pic.startsWith('data:image')) {
        // data URI: parse
        final data = Uri.parse(widget.roomType.pic).data;
        _bytes = data?.contentAsBytes();
      } else {
        _bytes = base64Decode(widget.roomType.pic);
      }
    } catch (e) {
      // decoding failed -> leave _bytes null
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
    super.build(context); // for AutomaticKeepAliveClientMixin

    // Use the cached _bytes (or placeholder)
    final imageWidget = _bytes != null
        ? Image.memory(
            _bytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
          )
        : Container(
            width: double.infinity,
            height: 180,
            color: Colors.grey[300],
            child: const Center(
              child:
                  Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            ),
          );

    final int duration = widget.endDate.difference(widget.startDate).inDays;
    final bool canAfford = widget.checkAffordable(widget.roomType, duration);

    return Container(
      margin: const EdgeInsets.all(8),
      height: 320,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
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

              if (widget.isSelected) {
                widget.onSelect?.call(null);
              } else {
                widget.onSelect?.call(widget.roomType);
              }
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: imageWidget,
                  ),
                ),
                // Unaffordable overlay
                if (!canAfford)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                // selection overlay
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: widget.isSelected ? 0.55 : 0.0,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                        Text(
                          '${NumberFormat("#,###").format(widget.roomType.roomTypePoints)} points',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveSize.text(12),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // disabled overlay when not affordable
                if (!widget.enabled)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          // Room Info Section - Enhanced
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                      Text(
                        '1 King Bed',
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
                  mainAxisAlignment: MainAxisAlignment.end,
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
                    Text(
                      '2 Adults, 1 Child',
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
          ),
          SizedBox(
            height: ResponsiveSize.scaleHeight(5),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
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
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.bathtub_outlined,
                      size: ResponsiveSize.scaleHeight(16),
                    ),
                    SizedBox(width: ResponsiveSize.scaleWidth(6)),
                    Text(
                      'Bathtub',
                      style: TextStyle(
                        fontSize: ResponsiveSize.text(11),
                        fontFamily: 'Outfit',
                      ),
                    ),
                    SizedBox(width: ResponsiveSize.scaleWidth(25)),
                    Icon(Icons.local_laundry_service_outlined,
                        size: ResponsiveSize.scaleHeight(16)),
                    SizedBox(width: ResponsiveSize.scaleWidth(6)),
                    Text(
                      'Washing Machine',
                      style: TextStyle(
                        fontSize: ResponsiveSize.text(11),
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
