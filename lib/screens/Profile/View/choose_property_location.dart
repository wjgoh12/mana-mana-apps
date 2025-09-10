import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
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
          style: TextStyle(
            fontSize: 20.fSize,
            fontWeight: FontWeight.bold,
          ),
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔽 Dropdown for states
              Container(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: const Text("Select State"),
                    items: vm.states
                        .map((state) => DropdownMenuItem<String>(
                              value: state,
                              child: Text(
                                state,
                                style: TextStyle(
                                  fontSize: 20.fSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                        .toList(),
                    value: selectedState,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => selectedState = value);
                        vm.fetchLocationsByState(value);
                      }
                    },
                  ),
                ),
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
                        .map((loc) => _buildLocationCard(
                            context, loc.locationName, loc.pic))
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
    BuildContext context, String location, String picBase64) {
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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SelectDateRoom()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.fSize),
                  image: picBase64.isNotEmpty
                      ? DecorationImage(
                          image: MemoryImage(
                            // decode base64 pic string into bytes
                            Uri.parse(picBase64).data!.contentAsBytes(),
                          ),
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
          location,
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
