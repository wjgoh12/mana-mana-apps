import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/roomType.dart';
import 'package:mana_mana_app/screens/Profile/Widget/quantity_controller.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class RoomtypeCard extends StatefulWidget {
  final RoomType roomType;
  final String displayName;
  final bool isSelected;
  final bool multiSelectable;
  final bool enabled;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final Function(RoomType? room)? onSelect;
  final Function(int quantity)? onQuantityChanged;
  final bool Function(RoomType room, int duration) checkAffordable;

  const RoomtypeCard({
    super.key,
    required this.roomType,
    required this.displayName,
    this.isSelected = false,
    this.enabled = true,
    required this.startDate,
    required this.endDate,
    this.quantity = 1,
    this.onSelect,
    this.onQuantityChanged,
    this.multiSelectable = false,
    required this.checkAffordable,
  });

  @override
  State<RoomtypeCard> createState() => _RoomtypeCardState();
}

class _RoomtypeCardState extends State<RoomtypeCard>
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
  void didUpdateWidget(covariant RoomtypeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent controls selection (multiSelectable==false), reflect
    // updates from parent. If multiSelectable is true, keep local state.
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

  Future<void> _showImageGallery(int initialIndex) async {
    if (!mounted) return;
    int selected = initialIndex;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: StatefulBuilder(builder: (context, setStateDialog) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Large preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _bytes != null
                        ? Image.memory(
                            _bytes!,
                            width: double.infinity,
                            height: ResponsiveSize.scaleHeight(260),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: double.infinity,
                            height: ResponsiveSize.scaleHeight(260),
                            color: Colors.grey[700],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[300],
                              size: ResponsiveSize.scaleHeight(48),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Thumbnails
                  SizedBox(
                    height: ResponsiveSize.scaleHeight(60),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: ResponsiveSize.scaleWidth(8)),
                      itemBuilder: (context, idx) {
                        final isSel = idx == selected;
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() => selected = idx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: isSel
                                  ? Border.all(
                                      color: const Color(0xFFFFCF00), width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _bytes != null
                                  ? Image.memory(
                                      _bytes!,
                                      width: ResponsiveSize.scaleWidth(80),
                                      height: ResponsiveSize.scaleHeight(60),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: ResponsiveSize.scaleWidth(80),
                                      height: ResponsiveSize.scaleHeight(60),
                                      color: Colors.grey[700],
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey[400],
                                        size: ResponsiveSize.scaleHeight(28),
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Close'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
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

    final bool displayedSelected =
        widget.multiSelectable ? _localSelected : widget.isSelected;

    return Container(
      margin: const EdgeInsets.all(8),
      constraints: BoxConstraints(minHeight: displayedSelected ? 380 : 320),
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
                            height: 180,
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
                                color: const Color(0xFFFFCF00),
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

              // Horizontal thumbnails row (uses decoded _bytes if available)
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: ResponsiveSize.scaleHeight(8)),
                child: SizedBox(
                  height: ResponsiveSize.scaleHeight(60),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: 5,
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSize.scaleWidth(12)),
                    separatorBuilder: (_, __) =>
                        SizedBox(width: ResponsiveSize.scaleWidth(8)),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showImageGallery(index),
                        child: _bytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _bytes!,
                                  width: ResponsiveSize.scaleWidth(100),
                                  height: ResponsiveSize.scaleHeight(60),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: ResponsiveSize.scaleWidth(100),
                                height: ResponsiveSize.scaleHeight(60),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey.shade500,
                                  size: ResponsiveSize.scaleHeight(28),
                                ),
                              ),
                      );
                    },
                  ),
                ),
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
                              '2',
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
                        Icon(
                          Icons.local_laundry_service_outlined,
                          size: ResponsiveSize.scaleHeight(16),
                        ),
                        SizedBox(width: ResponsiveSize.scaleWidth(6)),
                        Text(
                          'Washing Machine',
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(11),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (displayedSelected)
                      Column(
                        children: [
                          Divider(height: 1, color: Colors.grey[300]),
                          const SizedBox(height: 12),
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
