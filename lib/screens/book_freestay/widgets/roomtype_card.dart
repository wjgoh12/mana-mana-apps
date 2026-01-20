import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/roomtype.dart';
import 'package:mana_mana_app/screens/book_freestay/widgets/quantity_controller.dart';
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
  final int numberofPax;
  final int numBedrooms;
  final double? displayedPoints;

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
    this.numberofPax = 1,
    this.numBedrooms = 1,
    this.onSelect,
    this.onQuantityChanged,
    this.multiSelectable = false,
    required this.checkAffordable,
    this.displayedPoints,
  });

  @override
  State<RoomtypeCard> createState() => _RoomtypeCardState();
}

class _RoomtypeCardState extends State<RoomtypeCard>
    with AutomaticKeepAliveClientMixin {
  // Hold up to 5 decoded images (nullable entries for missing/bad images).
  List<Uint8List?> _images = [];
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
    // If the underlying RoomType changed, clear and re-decode images so
    // the thumbnails and gallery update accordingly.
    if (oldWidget.roomType.pic != widget.roomType.pic ||
        oldWidget.roomType.pic2 != widget.roomType.pic2 ||
        oldWidget.roomType.pic3 != widget.roomType.pic3 ||
        oldWidget.roomType.pic4 != widget.roomType.pic4 ||
        oldWidget.roomType.pic5 != widget.roomType.pic5) {
      _images = [];
      _decodeOnce();
    }
  }

  Future<void> _decodeOnce() async {
    // If we've already attempted to decode (images list filled), skip.
    if (_images.isNotEmpty || _decoding) return;
    _decoding = true;

    try {
      final pics = [
        widget.roomType.pic,
        widget.roomType.pic2,
        widget.roomType.pic3,
        widget.roomType.pic4,
        widget.roomType.pic5,
      ];

      _images = <Uint8List?>[];
      for (final p in pics) {
        if (p.isEmpty) {
          _images.add(null);
          continue;
        }

        try {
          if (p.startsWith('data:image')) {
            final data = Uri.parse(p).data;
            _images.add(data?.contentAsBytes());
          } else {
            _images.add(base64Decode(p));
          }
        } catch (e) {
          // If one image fails to decode, add null and continue with others
          _images.add(null);
        }
      }
    } finally {
      if (mounted) {
        _decoding = false;
        setState(() {});
      }
    }
  }

  Future<void> _showImageGallery(int initialIndex) async {
    if (!mounted) return;
    // Always start the gallery focused on the first image (index 0).
    // This ignores the passed-in initialIndex so the dialog consistently
    // points to the first image when opened.
    int selected = 0;

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
                    child: Builder(builder: (_) {
                      // Guard against selected being out of range
                      final Uint8List? selectedImage =
                          (selected >= 0 && selected < _images.length)
                              ? _images[selected]
                              : null;

                      if (selectedImage != null) {
                        return Image.memory(
                          selectedImage,
                          width: double.infinity,
                          height: ResponsiveSize.scaleHeight(260),
                          fit: BoxFit.cover,
                        );
                      }

                      // No image for this slot: render nothing (empty box)
                      return SizedBox(
                        width: double.infinity,
                        height: ResponsiveSize.scaleHeight(260),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Thumbnails
                  SizedBox(
                    height: ResponsiveSize.scaleHeight(60),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      // If we decoded images, iterate over that length; otherwise
                      // show zero items (no thumbnails).
                      itemCount: _images.isNotEmpty ? _images.length : 0,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: ResponsiveSize.scaleWidth(8)),
                      itemBuilder: (context, idx) {
                        final isSel = idx == selected;
                        final Uint8List? bytes =
                            (idx < _images.length) ? _images[idx] : null;

                        // If this particular image is missing, render an empty
                        // box (blank) so the layout stays consistent without
                        // forcing a null image use.
                        if (bytes == null) {
                          return SizedBox(
                            width: ResponsiveSize.scaleWidth(80),
                            height: ResponsiveSize.scaleHeight(60),
                          );
                        }

                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() => selected = idx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: isSel
                                  ? Border.all(
                                      color: AppColors.primaryYellow, width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                bytes,
                                width: ResponsiveSize.scaleWidth(80),
                                height: ResponsiveSize.scaleHeight(60),
                                fit: BoxFit.cover,
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

    // Use the first available decoded image (if any), otherwise show placeholder
    final Uint8List? firstImage =
        _images.firstWhere((i) => i != null, orElse: () => null);

    final imageWidget = firstImage != null
        ? Image.memory(
            firstImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
          )
        // No image: render nothing (empty box) so the UI doesn't show a
        // placeholder icon.
        : SizedBox(
            width: double.infinity,
            height: 180,
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
                          'Insufficient points for ${widget.displayName}. Required points: ${NumberFormat("#,###").format(widget.displayedPoints ?? widget.roomType.roomTypePoints)}',
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
                                color: AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'You\'ve Selected This Unit',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppDimens.fontSizeSmall,
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
                              fontSize: AppDimens.fontSizeSmall,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${NumberFormat("#,###").format(widget.displayedPoints ?? widget.roomType.roomTypePoints)} points',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppDimens.fontSizeSmall,
                              fontFamily: AppFonts.outfit,
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

              // Horizontal thumbnails row (uses decoded images if available)
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: ResponsiveSize.scaleHeight(8)),
                child: SizedBox(
                  height: ResponsiveSize.scaleHeight(60),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: false,
                    // Use the number of decoded images; if none decoded, show
                    // zero thumbnails (nothing).
                    itemCount: _images.isNotEmpty ? _images.length : 0,
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSize.scaleWidth(12)),
                    separatorBuilder: (_, __) =>
                        SizedBox(width: ResponsiveSize.scaleWidth(8)),
                    itemBuilder: (context, index) {
                      final Uint8List? bytes =
                          (_images.isNotEmpty && index < _images.length)
                              ? _images[index]
                              : null;
                      return GestureDetector(
                        onTap: () => _showImageGallery(index),
                        child: bytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  bytes,
                                  width: ResponsiveSize.scaleWidth(100),
                                  height: ResponsiveSize.scaleHeight(60),
                                  fit: BoxFit.cover,
                                ),
                              )
                            // No thumbnail: keep the slot empty (blank)
                            : SizedBox(
                                width: ResponsiveSize.scaleWidth(0),
                                height: ResponsiveSize.scaleHeight(60),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Info',
                            style: TextStyle(
                              fontSize: AppDimens.fontSizeSmall,
                              fontFamily: AppFonts.outfit,
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
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontFamily: AppFonts.outfit,
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
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontFamily: AppFonts.outfit,
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
                                            fontSize: AppDimens.fontSizeSmall,
                                            fontFamily: AppFonts.outfit,
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
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontFamily: AppFonts.outfit,
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
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontFamily: AppFonts.outfit,
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
                                            fontSize: AppDimens.fontSizeSmall,
                                            fontFamily: AppFonts.outfit,
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
                                if (widget.roomType.bedroomDetails.length > 0 &&
                                    widget.roomType.bedroomDetails[0].bedtype1
                                        .isNotEmpty)
                                  Row(
                                    children: [
                                      Text(
                                        'Room 1',
                                        style: TextStyle(
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontFamily: AppFonts.outfit,
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
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontFamily: AppFonts.outfit,
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
                                            fontSize: AppDimens.fontSizeSmall,
                                            fontFamily: AppFonts.outfit,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                if (widget.roomType.bedroomDetails.length > 1 &&
                                    widget.roomType.bedroomDetails[1].bedtype1
                                        .isNotEmpty)
                                  Row(
                                    children: [
                                      Text(
                                        'Room 2',
                                        style: TextStyle(
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontFamily: AppFonts.outfit,
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
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontFamily: AppFonts.outfit,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (widget.roomType.bedroomDetails
                                                  .length >
                                              1 &&
                                          widget.roomType.bedroomDetails[1]
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
                                            fontSize: AppDimens.fontSizeSmall,
                                            fontFamily: AppFonts.outfit,
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
                                fontSize: AppDimens.fontSizeSmall,
                                fontFamily: AppFonts.outfit,
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
                            fontSize: AppDimens.fontSizeSmall,
                            fontFamily: AppFonts.outfit,
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
                                fontSize: AppDimens.fontSizeSmall,
                                fontFamily: AppFonts.outfit,
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
                        fontSize: AppDimens.fontSizeSmall,
                        fontFamily: AppFonts.outfit,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: widget.roomType.bedroomDetails.isNotEmpty &&
                              widget.roomType.bedroomDetails[0]
                                  .bedroomFacilities.isNotEmpty
                          ? Wrap(
                              spacing: ResponsiveSize.scaleWidth(12),
                              runSpacing: ResponsiveSize.scaleHeight(6),
                              children: widget
                                  .roomType.bedroomDetails[0].bedroomFacilities
                                  .map((facility) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Decode and display base64 icon
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
                                          width: ResponsiveSize.scaleWidth(6)),
                                    Text(
                                      '${facility.facilitiesName}\n',
                                      style: TextStyle(
                                        fontSize: AppDimens.fontSizeSmall,
                                        fontFamily: AppFonts.outfit,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                          : Text(
                              'None',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeSmall,
                                fontFamily: AppFonts.outfit,
                                color: Colors.grey[600],
                              ),
                            ),
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
                                      fontSize: AppDimens.fontSizeSmall,
                                      fontFamily: AppFonts.outfit,
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
