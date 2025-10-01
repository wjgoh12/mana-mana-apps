import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/screens/Profile/View/select_date_room.dart';

import 'package:mana_mana_app/widgets/size_utils.dart';

class ChoosePropertyLocation extends StatefulWidget {
  final String selectedLocation;
  final String selectedUnitNo;
  const ChoosePropertyLocation({
    Key? key,
    required this.selectedLocation,
    required this.selectedUnitNo,
  }) : super(key: key);

  @override
  State<ChoosePropertyLocation> createState() => _ChoosePropertyLocationState();
}

class _ChoosePropertyLocationState extends State<ChoosePropertyLocation> {
  String? selectedState;
  static const String ALL_STATES = "All States";
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // print("🚀 ChoosePropertyLocation: initState called");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalData = context.read<GlobalDataManager>();
      // print("🔄 ChoosePropertyLocation: Fetching states and locations");
      globalData.fetchRedemptionStatesAndLocations().then((_) {
        // print("✅ ChoosePropertyLocation: States fetched, available states: ${globalData.availableStates}");
        // After states are loaded, initialize with "All States"
        if (!_hasInitialized && mounted) {
          setState(() {
            selectedState = ALL_STATES;
            _hasInitialized = true;
          });
          // print("🌍 ChoosePropertyLocation: Set to All States, fetching all locations");
          // Fetch all locations for all states
          globalData.fetchAllLocationsForAllStates().then((_) {
            // print("✅ ChoosePropertyLocation: All locations fetched");
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Choose Property Location',
          style: TextStyle(fontSize: 20.fSize, fontWeight: FontWeight.bold),
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
          // print("🔄 Consumer rebuild - Available states: ${globalData.availableStates.length}, Selected state: $selectedState, Has initialized: $_hasInitialized");
          
          List<String> dropdownOptions = [];
          if (globalData.availableStates.isNotEmpty) {
            dropdownOptions = [ALL_STATES, ...globalData.availableStates];

            // Initialize selectedState only once when states are loaded
            if (selectedState == null && !_hasInitialized) {
              // print("🔄 Initializing selectedState to All States");
              selectedState = ALL_STATES;
              _hasInitialized = true;
              // Trigger fetching all locations
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // print("🌍 PostFrameCallback: Fetching all locations for all states");
                globalData.fetchAllLocationsForAllStates();
              });
            }
          }

          List<dynamic> locationsToShow = [];
          if (selectedState == ALL_STATES) {
            locationsToShow = globalData.getAllLocationsFromAllStates();
            // print("🔍 All States selected - Found ${locationsToShow.length} locations");
            if (locationsToShow.isNotEmpty) {
              locationsToShow.sort((a, b) {
                final aName = a.locationName.toLowerCase();
                final bName = b.locationName.toLowerCase();
                return aName.compareTo(bName);
              });
            }
          } else if (selectedState != null) {
            locationsToShow = globalData.locationsByState[selectedState] ?? [];
            // print("🔍 State '$selectedState' selected - Found ${locationsToShow.length} locations");
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (globalData.isLoadingStates)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (dropdownOptions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No states found"),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: ResponsiveSize.scaleWidth(200),
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
                              border: Border.all(color: Colors.grey.shade400),
                              color: Colors.white,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (globalData.isLoadingLocations)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (locationsToShow.isEmpty)
                const Expanded(child: Center(child: Text("No locations found")))
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
      globalData.fetchAllLocationsForAllStates();
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

  const LocationCard({
    Key? key,
    required this.locationName,
    required this.picBase64,
    required this.propertyState,
    required this.selectedLocation,
    required this.selectedUnitNo,
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
      // debugPrint("❌ Failed to decode image for ${widget.locationName}: $e");
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.fSize),
              ),
              child: InkWell(
                onTap: () {
                  final ownerVM = context.read<OwnerProfileVM>();
                  ownerVM.clearRoomTypesForNewLocation();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: ownerVM,
                        child: SelectDateRoom(
                          location: widget.locationName ?? "Unknown Location",
                          state: widget.propertyState ?? "Unknown State",
                          ownedLocation: widget.selectedLocation,
                          ownedUnitNo: widget.selectedUnitNo,
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.fSize),
                  child: _isDecoded
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background image with caching
                            _decodedImage != null
                                ? Image.memory(
                                    _decodedImage!,
                                    fit: BoxFit.cover,
                                    cacheHeight: 400, // Reduce memory footprint
                                    cacheWidth: 400,
                                    errorBuilder: (context, error, stackTrace) {
                                      // debugPrint(
                                      //     "❌ Error displaying image for ${widget.locationName}: $error");
                                      return _buildPlaceholder();
                                    },
                                  )
                                : _buildPlaceholder(),
                            // Overlay with state name
                            if (widget.showStateName)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.propertyState ?? "Unknown State",
                                  style: TextStyle(
                                    fontSize: 12.fSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Outfit',
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.locationName ?? "Unknown Location",
            style: TextStyle(
              fontSize: 16.fSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              color: const Color(0xFF3E51FF),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
