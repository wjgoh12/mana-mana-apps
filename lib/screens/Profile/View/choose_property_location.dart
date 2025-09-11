import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/screens/Profile/View/select_date_room.dart';

import 'package:mana_mana_app/widgets/size_utils.dart';

class ChoosePropertyLocation extends StatefulWidget {
  const ChoosePropertyLocation({Key? key}) : super(key: key);

  @override
  State<ChoosePropertyLocation> createState() => _ChoosePropertyLocationState();
}

class _ChoosePropertyLocationState extends State<ChoosePropertyLocation> {
  String? selectedState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<OwnerProfileVM>();
      vm.loadStates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Consumer<OwnerProfileVM>(
        builder: (context, vm, child) {
          if (selectedState == null && vm.states.isNotEmpty) {
            selectedState = vm.states.first;
            vm.fetchLocationsByState(selectedState!);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔽 Dropdown for states
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
                        items: vm.states
                            .map(
                              (state) => DropdownMenuItem<String>(
                                value: state,
                                child: Text(
                                  state,
                                  style: TextStyle(
                                    fontSize: 20.fSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: selectedState,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => selectedState = value);
                            vm.fetchLocationsByState(value);
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                12), // Border radius for the button
                            border: Border.all(
                              color: Colors.grey.shade400,
                            ),
                            color: Colors.white,
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  12), // Border radius for the dropdown menu
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0),
                                )
                              ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔽 Locations grid
              if (vm.isLoadingLocations)
                const Center(child: CircularProgressIndicator())
              else if (vm.locations.isEmpty)
                const Center(child: Text("No locations found"))
              else
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    padding: const EdgeInsets.all(16),
                    childAspectRatio: 0.7,
                    children: vm.locations
                        .map(
                          (loc) => _buildLocationCard(context, loc.locationName,
                              loc.pic, loc.stateName),
                        )
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildLocationCard(
  BuildContext context,
  String? location,
  String? picBase64,
  String? propertyState,
) {
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<OwnerProfileVM>(),
                      child: SelectDateRoom(
                        location: location ?? "Unknown Location",
                        state: propertyState ?? "Unknown State",
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.fSize),
                  image: decodedImage != null
                      ? DecorationImage(
                          image: MemoryImage(decodedImage),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage("assets/images/placeholder.png"),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          location ?? "Unknown Location",
          style: TextStyle(
            fontSize: 20.fSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E51FF),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
