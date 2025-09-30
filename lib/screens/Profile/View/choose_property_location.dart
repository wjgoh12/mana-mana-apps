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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalData = context.read<GlobalDataManager>();
      globalData.fetchRedemptionStatesAndLocations();
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
          // Create dropdown options with "All States" as first option
          List<String> dropdownOptions = [];
          if (globalData.availableStates.isNotEmpty) {
            dropdownOptions = [ALL_STATES, ...globalData.availableStates];

            // Auto-select "All States" if nothing is selected
            if (selectedState == null) {
              selectedState = ALL_STATES;
              _handleStateSelection(globalData, ALL_STATES);
            }
          }

          // Get locations to display based on selection
          List<dynamic> locationsToShow = [];
          if (selectedState == ALL_STATES) {
            locationsToShow = globalData.getAllLocationsFromAllStates()
              ..sort((a, b) => (a.locationName ?? '')
                  .toLowerCase()
                  .compareTo((b.locationName ?? '').toLowerCase()));
          } else if (selectedState != null) {
            locationsToShow = globalData.locationsByState[selectedState] ?? [];
          } else if (selectedState != null) {
            locationsToShow = globalData.locationsByState[selectedState] ?? [];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔽 Dropdown for states (including "All States")
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
                            maxHeight: 300, // Limit height for better UX
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

              const SizedBox(height: 16),

              // 🔽 Locations grid
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
                    itemBuilder: (context, index) {
                      final location = locationsToShow[index];
                      return _buildLocationCard(
                        context,
                        location.locationName,
                        location.pic,
                        location.stateName,
                        widget.selectedLocation,
                        widget.selectedUnitNo,
                        showStateName: selectedState ==
                            ALL_STATES, // Show state name when viewing all
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

  // In ChoosePropertyLocation, simplify the _handleStateSelection method
  void _handleStateSelection(GlobalDataManager globalData, String state) {
    if (state == ALL_STATES) {
      // No need to fetch - all locations are already preloaded!
      // Just trigger a rebuild by calling notifyListeners if needed
    } else {
      // For specific states, data should already be available too
      // But you can still call this if you want to ensure fresh data
      globalData.fetchLocationsByState(state);
    }
  }
}

Widget _buildLocationCard(
  BuildContext context,
  String? location,
  String? picBase64,
  String? propertyState,
  String selectedLocation, // from PropertyRedemption
  String selectedUnitNo, {
  // from PropertyRedemption
  bool showStateName = false,
  // New parameter to show state name
}) {
  Uint8List? _decodeBase64(String? base64String) {
    try {
      if (base64String == null || base64String.isEmpty) return null;

      // Case 1: If API already provides "data:image/png;base64,..."
      if (base64String.startsWith("data:image")) {
        return Uri.parse(base64String).data?.contentAsBytes();
      }

      // Case 2: Raw base64 string
      return base64Decode(base64String);
    } catch (e) {
      debugPrint("❌ Failed to decode Base64: $e");
      return null;
    }
  }

  final decodedImage = _decodeBase64(picBase64);

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
              // In _buildLocationCard onTap:
              onTap: () {
                final ownerVM = context.read<OwnerProfileVM>();
                ownerVM
                    .clearRoomTypesForNewLocation(); // Clear before navigating

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: ownerVM,
                      child: SelectDateRoom(
                        location: location ?? "Unknown Location",
                        state: propertyState ?? "Unknown State",
                        ownedLocation: selectedLocation,
                        ownedUnitNo: selectedUnitNo,
                      ),
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.fSize),
                      image: decodedImage != null
                          ? DecorationImage(
                              image: MemoryImage(decodedImage),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image:
                                  AssetImage("assets/images/placeholder.png"),
                              fit: BoxFit.cover,
                            ),
                    ),
                    // Add overlay with state name when showing all states
                    child: showStateName
                        ? Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.fSize),
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
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    propertyState ?? "Unknown State",
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
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          location ?? "Unknown Location",
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
