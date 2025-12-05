import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/screens/Book_freestay/View/select_date_room.dart';

import 'package:mana_mana_app/widgets/size_utils.dart';

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
    // Defer data loading until after first frame to avoid calling setState
    // during the initial build cycle which can trigger Flutter warnings.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataInBackground();
    });
  }

  Future<void> _loadDataInBackground() async {
    final globalData = context.read<GlobalDataManager>();

    debugPrint('📍 Location screen: Starting data load...');

    try {
      // Check if states are already loaded (from dashboard preload)
      if (globalData.availableStates.isEmpty) {
        debugPrint('🔄 Loading states...');
        await globalData.fetchRedemptionStatesAndLocations();
      } else {
        debugPrint(
            '✅ States already loaded: ${globalData.availableStates.length}');
      }

      // Check if any locations are already cached
      final cachedLocations = globalData.getAllLocationsFromAllStates();
      if (cachedLocations.isNotEmpty) {
        debugPrint('✅ Using ${cachedLocations.length} cached locations');
        if (mounted) {
          setState(() => _isLoadingData = false);
        }
        return;
      }

      // Load locations for all states with a timeout
      debugPrint('🔄 Loading locations for all states...');

      final loadFuture = Future.wait(
        globalData.availableStates.map(
          (state) => globalData.preloadLocationsForState(state),
        ),
      );

      // Wait max 3 seconds for locations to load
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
      // Always clear loading flag
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
                fontFamily: 'outfit',
                fontSize: ResponsiveSize.text(18),
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
          // Show loading indicator while data is being fetched
          if (_isLoadingData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<String> dropdownOptions = [];
          if (globalData.availableStates.isNotEmpty) {
            dropdownOptions = [ALL_STATES, ...globalData.availableStates];

            if (selectedState == null) {
              // Set initial selectedState synchronously but defer expensive
              // fetch work to after build to avoid setState during build.
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
                                    fontSize: 20.fSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'outfit',
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
                              top: BorderSide
                                  .none, // No top border for seamless connection
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    padding: const EdgeInsets.all(16),
                    itemCount: locationsToShow.length,
                    // Add cache extent to reduce memory pressure
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
      // No need to fetch - all locations are already preloaded!
    } else {
      globalData.fetchLocationsByState(state);
    }
  }
}

// Separate StatefulWidget for better memory management
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
  bool _isDecoded = false;

  @override
  bool get wantKeepAlive => true; // Keep state alive to avoid re-decoding

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
      // Decode in a separate isolate/compute to avoid blocking UI
      Uint8List? result;

      if (widget.picBase64!.startsWith("data:image")) {
        result = Uri.parse(widget.picBase64!).data?.contentAsBytes();
      } else {
        result = base64Decode(widget.picBase64!);
      }

      if (mounted) {
        setState(() {
          _decodedImage = result;
          _isDecoded = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Failed to decode image for ${widget.locationName}: $e");
      if (mounted) setState(() => _isDecoded = true);
    }
  }

  @override
  void dispose() {
    _decodedImage = null; // Clear memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
        Navigator.pop(context); // Remove loading dialog

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
              height: ResponsiveSize.scaleHeight(195),
              width: double.infinity,
              child: _isDecoded
                  ? _decodedImage != null
                      ? Image.memory(
                          _decodedImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                                "❌ Error displaying image for ${widget.locationName}: $error");
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder()
                  : const Center(child: CircularProgressIndicator()),
            ),
            Text(
              widget.locationName ?? "Unknown Location",
              style: TextStyle(
                fontSize: ResponsiveSize.text(13),
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
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
                  fontSize: ResponsiveSize.text(11),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Outfit',
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
