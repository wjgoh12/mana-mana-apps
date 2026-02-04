import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/profile/view_model/owner_profile_view_model.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/screens/book_freestay/view/select_date_room/select_date_room.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ignore: avoid_web_libraries_in_flutter

class ChoosePropertyLocation extends StatefulWidget {
  final String selectedLocation;
  final String selectedUnitNo;
  final double points;
  const ChoosePropertyLocation({
    Key? key,
    required this.selectedLocation,
    required this.selectedUnitNo,
    required this.points,
  }) : super(key: key);

  @override
  State<ChoosePropertyLocation> createState() => _ChoosePropertyLocationState();
}

class _ChoosePropertyLocationState extends State<ChoosePropertyLocation> {
  String? selectedState;
  // ignore: constant_identifier_names
  static const String ALL_STATES = "All States";
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataInBackground();
    });
  }

  Future<void> _loadDataInBackground() async {
    final globalData = context.read<GlobalDataManager>();

    debugPrint('📍 Location screen: Starting data load...');

    try {
      if (globalData.availableStates.isEmpty) {
        debugPrint('🔄 Loading states...');
        await globalData.fetchRedemptionStatesAndLocations();
      } else {
        debugPrint(
            '✅ States already loaded: ${globalData.availableStates.length}');
      }

      final cachedLocations = globalData.getAllLocationsFromAllStates();
      if (cachedLocations.isNotEmpty) {
        debugPrint('✅ Using ${cachedLocations.length} cached locations');
        if (mounted) {
          setState(() => _isLoadingData = false);
        }
        return;
      }

      debugPrint('🔄 Loading locations for all states...');

      final loadFuture = Future.wait(
        globalData.availableStates.map(
          (state) => globalData.preloadLocationsForState(state),
        ),
      );

      await loadFuture.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⚠️ Location load timeout - displaying partial data');
          return <void>[];
        },
      );

      final totalLocations = globalData.getAllLocationsFromAllStates().length;
      debugPrint('✅ Loaded $totalLocations locations');

      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    } catch (e) {
      debugPrint('❌ Error loading location data: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    } finally {
      globalData.clearLocationLoadingFlag();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 13.width,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
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
            Text(
              'Choose Property Location',
              style: TextStyle(
                color: const Color(0xFF000241),
                fontFamily: AppFonts.outfit,
                fontSize: AppDimens.fontSizeBig,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
        ),
      ),
      body: Consumer<GlobalDataManager>(
        builder: (context, globalData, child) {
          if (_isLoadingData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<String> dropdownOptions = [];
          if (globalData.availableStates.isNotEmpty) {
            dropdownOptions = [ALL_STATES, ...globalData.availableStates];

            if (selectedState == null) {
              selectedState = ALL_STATES;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _handleStateSelection(globalData, ALL_STATES);
              });
            }
          }

          List<dynamic> locationsToShow = [];
          if (selectedState == ALL_STATES) {
            locationsToShow = globalData.getAllLocationsFromAllStates()
              ..sort((a, b) => (a.locationName)
                  .toLowerCase()
                  .compareTo((b.locationName).toLowerCase()));
          } else if (selectedState != null) {
            locationsToShow = globalData.locationsByState[selectedState] ?? [];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: ResponsiveSize.scaleWidth(300),
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Text("Select State"),
                        items: dropdownOptions
                            .map(
                              (state) => DropdownMenuItem<String>(
                                value: state,
                                child: Text(
                                  state,
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeBig,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: AppFonts.outfit,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: selectedState,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => selectedState = value);
                            _handleStateSelection(globalData, value);
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade500),
                            color: Colors.white,
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.zero,
                              topRight: Radius.zero,
                              bottomLeft: Radius.circular(
                                  ResponsiveSize.scaleWidth(15)),
                              bottomRight: Radius.circular(
                                  ResponsiveSize.scaleWidth(15)),
                            ),
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(color: Colors.grey.shade500),
                              right: BorderSide(color: Colors.grey.shade500),
                              bottom: BorderSide(color: Colors.grey.shade500),
                              top: BorderSide.none,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          offset: const Offset(0, 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (locationsToShow.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text("No locations available for this state"),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: kIsWeb
                          ? (MediaQuery.of(context).size.width >= 600
                              ? 0.85
                              : 0.70)
                          : (MediaQuery.of(context).size.width >= 600
                              ? 1.0
                              : 0.65),
                    ),
                    padding: const EdgeInsets.all(26),
                    itemCount: locationsToShow.length,
                    cacheExtent: 400,
                    itemBuilder: (context, index) {
                      final location = locationsToShow[index];
                      return LocationCard(
                        key: ValueKey(
                            '${location.locationName}_${location.stateName}'),
                        locationName: location.locationName,
                        picBase64: location.pic,
                        propertyState: location.stateName,
                        selectedLocation: widget.selectedLocation,
                        selectedUnitNo: widget.selectedUnitNo,
                        showStateName: selectedState == ALL_STATES,
                        points: widget.points,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleStateSelection(GlobalDataManager globalData, String state) {
    if (state == ALL_STATES) {
    } else {
      globalData.fetchLocationsByState(state);
    }
  }
}

class LocationCard extends StatefulWidget {
  final String? locationName;
  final String? picBase64;
  final String? propertyState;
  final String selectedLocation;
  final String selectedUnitNo;
  final bool showStateName;
  final double points;

  const LocationCard({
    Key? key,
    required this.locationName,
    required this.picBase64,
    required this.propertyState,
    required this.selectedLocation,
    required this.selectedUnitNo,
    required this.points,
    this.showStateName = false,
  }) : super(key: key);

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _decodedImage;
  String? _dataUrl; // For web: use data URL instead of Image.memory
  String? _htmlViewType; // For web: unique view type for HtmlElementView
  bool _isDecoded = false;
  bool _isUrl = false;
  bool _isSvg = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _decodeImageAsync();
  }

  Future<void> _decodeImageAsync() async {
    if (widget.picBase64 == null || widget.picBase64!.isEmpty) {
      if (mounted) setState(() => _isDecoded = true);
      return;
    }

    try {
      // Check if it's a URL (http/https)
      if (widget.picBase64!.startsWith('http')) {
        if (mounted) setState(() => _isUrl = true);
        return;
      }

      // Check if it specifies SVG in data header
      bool isHeaderSvg =
          widget.picBase64!.toLowerCase().contains('image/svg+xml');

      // Otherwise, it's Base64 (data:image or raw)
      Uint8List? result;
      if (widget.picBase64!.startsWith("data:image")) {
        result = Uri.parse(widget.picBase64!).data?.contentAsBytes();
      } else {
        // Sanitize Base64 string: remove all whitespace/newlines
        String cleanBase64 = widget.picBase64!.replaceAll(RegExp(r'\s+'), '');

        // Fix Base64 padding if necessary (length must be multiple of 4)
        int missingPadding = (4 - (cleanBase64.length % 4)) % 4;
        if (missingPadding > 0) {
          cleanBase64 += '=' * missingPadding;
          debugPrint(
              "⚠️ Added $missingPadding padding characters to Base64 for ${widget.locationName}");
        }

        result = base64Decode(cleanBase64);
      }

      // Check for SVG signature in bytes using binary check (safe for PNG/JPG)
      bool isContentSvg = false;
      if (result != null && result.length >= 4) {
        // Check for SVG: starts with '<svg' or '<?xml' (after optional whitespace/BOM)
        // SVG bytes: '<' = 0x3C, 's' = 0x73, 'v' = 0x76, 'g' = 0x67
        // XML bytes: '<' = 0x3C, '?' = 0x3F, 'x' = 0x78, 'm' = 0x6D
        int startIdx = 0;
        // Skip BOM if present (EF BB BF)
        if (result.length >= 3 &&
            result[0] == 0xEF &&
            result[1] == 0xBB &&
            result[2] == 0xBF) {
          startIdx = 3;
        }
        // Skip whitespace
        while (startIdx < result.length &&
            (result[startIdx] == 0x20 ||
                result[startIdx] == 0x0A ||
                result[startIdx] == 0x0D ||
                result[startIdx] == 0x09)) {
          startIdx++;
        }

        if (startIdx + 4 <= result.length) {
          // Check for '<svg' (case insensitive for 's')
          if (result[startIdx] == 0x3C &&
              (result[startIdx + 1] == 0x73 || result[startIdx + 1] == 0x53) &&
              (result[startIdx + 2] == 0x76 || result[startIdx + 2] == 0x56) &&
              (result[startIdx + 3] == 0x67 || result[startIdx + 3] == 0x47)) {
            isContentSvg = true;
          }
          // Check for '<?xml' which likely indicates SVG
          else if (result[startIdx] == 0x3C &&
              result[startIdx + 1] == 0x3F &&
              (result[startIdx + 2] == 0x78 || result[startIdx + 2] == 0x58)) {
            isContentSvg = true;
          }
        }
        debugPrint(
            "🔍 Image Check [${widget.locationName}]: IsSVG=$isContentSvg, Size=${result.length} bytes");
      }

      if (mounted) {
        setState(() {
          _decodedImage = result;
          _isSvg = isHeaderSvg || isContentSvg;
          // For web: create data URL and register HTML element
          if (kIsWeb && result != null && !_isSvg) {
            _dataUrl = 'data:image/png;base64,${base64Encode(result)}';
            _htmlViewType =
                'img-${widget.locationName}-${DateTime.now().millisecondsSinceEpoch}';
            _registerHtmlImage();
          }
          _isDecoded = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Failed to decode image for ${widget.locationName}: $e");
      // Fallback: If it's a URL but didn't start with http (e.g. malformed), try treating as one
      if (mounted) setState(() => _isDecoded = true);
    }
  }

  @override
  void dispose() {
    _decodedImage = null;
    super.dispose();
  }

  void _registerHtmlImage() {
    if (!kIsWeb || _dataUrl == null || _htmlViewType == null) return;

    // registerHtmlView(_htmlViewType!, _dataUrl!);
  }

  Widget _buildWebImage() {
    if (_htmlViewType != null) {
      return HtmlElementView(viewType: _htmlViewType!);
    }
    return _buildPlaceholder();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return InkWell(
      onTap: () async {
        final ownerVM = context.read<OwnerProfileVM>();
        ownerVM.clearRoomTypesForNewLocation();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await ownerVM.fetchUserAvailablePoints();

        // ignore: use_build_context_synchronously
        Navigator.pop(context);

        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: ownerVM,
              child: SelectDateRoom(
                location: widget.locationName ?? "Unknown Location",
                state: widget.propertyState ?? "Unknown State",
                ownedLocation: widget.selectedLocation,
                ownedUnitNo: widget.selectedUnitNo,
                points: widget.points,
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.fSize),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: kIsWeb
                  ? ResponsiveSize.scaleHeight(280)
                  : ResponsiveSize.scaleHeight(200),
              width: double.infinity,
              child: kIsWeb
                  ? _isUrl
                      ? Image.network(
                          widget.picBase64!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                                "❌ PWA Image.network failed for ${widget.locationName}");
                            return _buildPlaceholder();
                          },
                        )
                      : _decodedImage != null
                          ? (_isSvg
                              ? SvgPicture.memory(
                                  _decodedImage!,
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (_) =>
                                      _buildPlaceholder(),
                                )
                              : _buildWebImage())
                          : _buildPlaceholder()
                  : _isDecoded
                      ? (_decodedImage != null
                          ? (_isSvg
                              ? SvgPicture.memory(
                                  _decodedImage!,
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (_) =>
                                      _buildPlaceholder(),
                                )
                              : Image.memory(
                                  _decodedImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, memoryError, stackTrace) {
                                    debugPrint(
                                        "❌ Image.memory failed for ${widget.locationName}: $memoryError");
                                    return _buildPlaceholder();
                                  },
                                ))
                          : _buildPlaceholder())
                      : const Center(child: CircularProgressIndicator()),
            ),
            Text(
              widget.locationName ?? "Unknown Location",
              style: TextStyle(
                fontSize: AppDimens.fontSizeSmall,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.outfit,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.showStateName) ...[
              SizedBox(height: 4.fSize),
              Text(
                widget.propertyState ?? "Unknown State",
                style: TextStyle(
                  fontSize: AppDimens.fontSizeSmall,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.outfit,
                  color: Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }
}
