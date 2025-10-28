import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/enhanced_statement_dropdown.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/enhanced_statement_container.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Profile/View/financial_details.dart';
import 'package:mana_mana_app/screens/Profile/View/property_redemption.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/unit_overview_container.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AllPropertyNewScreen extends StatefulWidget {
  const AllPropertyNewScreen({super.key});

  @override
  State<AllPropertyNewScreen> createState() => _AllPropertyNewScreenState();
}

class _AllPropertyNewScreenState extends State<AllPropertyNewScreen> {
  String monthNumberToName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Unknown';
  }

  Widget buildCard(String title, String value, String footer,
      {bool isCurrency = true}) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        color: Colors.white,
        child: Container(
          height: ResponsiveSize.scaleHeight(90),
          padding: EdgeInsets.all(ResponsiveSize.scaleWidth(8.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'outfit',
                  fontSize: ResponsiveSize.text(11),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    if (isCurrency)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: Transform.translate(
                          offset: const Offset(0, -4),
                          child: Text(
                            'RM',
                            style: TextStyle(
                              fontFamily: 'outfit',
                              fontSize: ResponsiveSize.text(10),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontFamily: 'outfit',
                        fontSize: ResponsiveSize.text(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveSize.scaleHeight(4)),
              Text(
                footer,
                style: TextStyle(
                  fontFamily: 'outfit',
                  fontSize: ResponsiveSize.text(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global data manager at the top level
        ChangeNotifierProvider.value(value: GlobalDataManager()),
        // Dashboard ViewModel that will use cached data
        ChangeNotifierProvider(
          create: (_) {
            final model = NewDashboardVM_v3();
            // Initialize data once - will use cached data if already loaded
            model.fetchData();
            return model;
          },
        ),
        // Property Detail ViewModel that will use cached data
        ChangeNotifierProvider(
          create: (_) => PropertyDetailVM(),
        ),
      ],
      child: Consumer2<NewDashboardVM_v3, PropertyDetailVM>(
        builder: (context, dashboardModel, propertyModel, child) {
          // Initialize property detail model with dashboard data
          if (dashboardModel.locationByMonth.isNotEmpty &&
              !propertyModel.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              propertyModel.fetchData(dashboardModel.locationByMonth);
            });
          }

          return Scaffold(
            backgroundColor: Colors.white, // Replace with a valid Color
            appBar: propertyAppBar(context, () => Navigator.of(context).pop()),
            body: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              // decoration: const BoxDecoration(
              //   image: DecorationImage(
              //     image:
              //         AssetImage('assets/images/background_mana_property.webp'),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: ResponsiveSize.scaleHeight(8),
                    ),
                    _unitDropDown(),
                    // Display UnitOverviewContainer when a unit is selected
                    Builder(
                      builder: (context) {
                        // print(
                        //     '🔄 UnitOverviewContainer Builder triggered - selectedProperty: ${propertyModel.selectedProperty}, selectedUnitNo: ${propertyModel.selectedUnitNo}, selectedType: ${propertyModel.selectedType}');
                        if (propertyModel.selectedProperty != null &&
                            propertyModel.selectedUnitNo != null &&
                            propertyModel.selectedType != null) {
                          // print('✅ Showing UnitOverviewContainer');
                          return const UnitOverviewContainer();
                        }
                        // print('❌ Hiding UnitOverviewContainer');
                        return const SizedBox.shrink();
                      },
                    ),
                    SizedBox(
                      height: ResponsiveSize.scaleHeight(15),
                    ),
                    _quickLinks(context),
                    SizedBox(
                      height: ResponsiveSize.scaleHeight(15),
                    ),
                    // Enhanced Statement Dropdown
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: ResponsiveSize.scaleHeight(20),
                            ),
                            Builder(
                              builder: (context) {
                                // print(
                                //     '🔄 Statement Dropdown Builder triggered - selectedProperty: ${propertyModel.selectedProperty}, selectedUnitNo: ${propertyModel.selectedUnitNo}, selectedType: ${propertyModel.selectedType}');
                                if (propertyModel.selectedProperty != null &&
                                    propertyModel.selectedUnitNo != null &&
                                    propertyModel.selectedType != null) {
                                  // print('✅ Showing Statement Dropdown');
                                  return EnhancedStatementDropdown(
                                    onBack: () => Navigator.pop(context),
                                    yearOptions: propertyModel.yearItems,
                                    monthOptions: propertyModel.monthItems,
                                    model: propertyModel,
                                  );
                                }
                                // print('❌ Hiding Statement Dropdown');
                                return const SizedBox.shrink();
                              },
                            ),
                            Builder(
                              builder: (context) {
                                // print(
                                //     '🔄 Statement Container Builder triggered - selectedProperty: ${propertyModel.selectedProperty}, selectedUnitNo: ${propertyModel.selectedUnitNo}, selectedType: ${propertyModel.selectedType}');
                                if (propertyModel.selectedProperty != null &&
                                    propertyModel.selectedUnitNo != null &&
                                    propertyModel.selectedType != null) {
                                  // print('✅ Showing Statement Container');
                                  return EnhancedStatementContainer(
                                      model: propertyModel);
                                }
                                // print('❌ Hiding Statement Container');
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Enhanced Statement Container
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 1),
          );
        },
      ),
    );
  }
}

Widget _unitDropDown() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Unit:',
        //   style: TextStyle(
        //       fontSize: ResponsiveSize.text(18),
        //       fontWeight: FontWeight.bold,
        //       fontFamily: 'Outfit'),
        // ),
        SizedBox(height: ResponsiveSize.scaleHeight(8)),
        const PropertyUnitSelector(),
      ],
    ),
  );
}

Widget _quickLinks(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(
          left: ResponsiveSize.scaleWidth(10),
          bottom: ResponsiveSize.scaleHeight(8),
        ),
        child: Text(
          'Quick Links',
          style: TextStyle(
            fontSize: ResponsiveSize.text(18),
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ),
      SizedBox(height: ResponsiveSize.scaleHeight(10)),
      Padding(
        padding:
            EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(10)),
        child: Row(
          children: [
            //1
            Expanded(
              child: SizedBox(
                height: ResponsiveSize.scaleHeight(65),
                width: ResponsiveSize.scaleWidth(190),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Create and initialize the VM
                          final ownerVm = OwnerProfileVM();
                          final globalData = Provider.of<GlobalDataManager>(
                              context,
                              listen: false);

                          launchUrl(Uri.parse(
                              'https://booking.manamanasuites.com/inst/#group?groupId=24567&promoCode=OWNERZB89A9'));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: ResponsiveSize.scaleWidth(9)),
                                CircleAvatar(
                                  radius: ResponsiveSize.scaleWidth(20),
                                  backgroundColor: Color(0xFF606060),
                                  child: Image.asset(
                                    'assets/images/Calendar_booking.png',
                                    width: ResponsiveSize.scaleWidth(20),
                                    height: ResponsiveSize.scaleWidth(20),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: ResponsiveSize.scaleWidth(8)),
                                Text(
                                  'Make a Booking',
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ResponsiveSize.text(12),
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Positioned(
                      //   right: 0,
                      //   bottom: 5,
                      //   child: Image.asset(
                      //     'assets/images/make_booking_deco.png',
                      //     fit: BoxFit.cover,
                      //     width: 24,
                      //     height: 31,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            //3
            Expanded(
              child: SizedBox(
                height: ResponsiveSize.scaleHeight(65),
                width: ResponsiveSize.scaleWidth(190),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Create and initialize the VM
                          final vm = OwnerProfileVM();
                          vm.fetchBookingHistory();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider.value(value: vm),
                                ],
                                builder: (context, child) {
                                  return const PropertyRedemption();
                                },
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: ResponsiveSize.scaleWidth(9)),
                                CircleAvatar(
                                  radius: ResponsiveSize.scaleWidth(20),
                                  backgroundColor: Color(0XFF606060),
                                  child: Image.asset(
                                    'assets/images/pillow_free_redemption.png',
                                    width: ResponsiveSize.scaleWidth(25),
                                    height: ResponsiveSize.scaleWidth(25),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: ResponsiveSize.scaleWidth(8)),
                                Text(
                                  'Free Stay \nRedemption',
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: ResponsiveSize.text(12),
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Positioned(
                      //   right: 0,
                      //   bottom: 5,
                      //   child: Image.asset(
                      //     'assets/images/make_booking_deco.png',
                      //     fit: BoxFit.cover,
                      //     width: 24,
                      //     height: 31,
                      //   ),
                      // ),
                      // position at the right corner
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    ],
  );
}

class PropertyOverviewSection extends StatelessWidget {
  const PropertyOverviewSection({super.key});

  String _monthNumberToName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Unknown';
  }

  Widget _buildCard(String title, String value, String footer,
      {bool isCurrency = true}) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        color: Colors.white,
        child: Container(
          height: ResponsiveSize.scaleHeight(90),
          padding: EdgeInsets.all(ResponsiveSize.scaleWidth(8.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'outfit',
                  fontSize: ResponsiveSize.text(11),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    if (isCurrency)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: Transform.translate(
                          offset: const Offset(0, -4),
                          child: Text(
                            'RM',
                            style: TextStyle(
                              fontFamily: 'outfit',
                              fontSize: ResponsiveSize.text(10),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontFamily: 'outfit',
                        fontSize: ResponsiveSize.text(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveSize.scaleHeight(4)),
              Text(
                footer,
                style: TextStyle(
                  fontFamily: 'outfit',
                  fontSize: ResponsiveSize.text(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NewDashboardVM_v3, PropertyDetailVM>(
      builder: (context, dashboardModel, propertyModel, child) {
        if (propertyModel.selectedProperty == null ||
            propertyModel.selectedUnitNo == null) {
          return const SizedBox
              .shrink(); // Don't show anything if no unit is selected
        }

        // Get data from PropertyDetailVM
        final totalPro = propertyModel.selectedUnitPro?.total ?? 0.0;
        final formattedTotalPro = totalPro.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

        final totalBlc = propertyModel.selectedUnitBlc?.total ?? 0.0;
        final formattedTotalBlc = totalBlc.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

        final location = propertyModel.selectedProperty ?? 'Unknown';
        final unitNo = propertyModel.selectedUnitNo ?? 'Unknown';

        DateTime now = DateTime.now();
        String shortMonth = _monthNumberToName(now.month);
        String year = now.year.toString();

        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCard(
                      'Monthly Profit', formattedTotalPro, '$shortMonth $year'),
                  const SizedBox(width: 8),
                  _buildCard('Net Profit After POB', formattedTotalBlc,
                      '$shortMonth $year'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCard('$year Accumulated Profit', formattedTotalBlc,
                      '$shortMonth $year'),
                  const SizedBox(width: 8),
                  _buildCard(
                      'Group Occupancy',
                      '${dashboardModel.getUnitOccupancyFromCache(location, unitNo)}',
                      '$shortMonth $year',
                      isCurrency: false),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class PropertyUnitSelector extends StatefulWidget {
  const PropertyUnitSelector({super.key});

  @override
  State<PropertyUnitSelector> createState() => _PropertyUnitSelectorState();
}

class _PropertyUnitSelectorState extends State<PropertyUnitSelector> {
  String? selectedProperty;
  String? selectedUnit;

  void _handlePropertySelection(String? value, BuildContext context) {
    if (value == null) return;

    final model = Provider.of<NewDashboardVM_v3>(context, listen: false);
    final firstUnitData =
        model.ownerUnits.where((unit) => unit.location == value).firstOrNull;

    final firstUnit = firstUnitData?.unitno;

    setState(() {
      selectedProperty = value;
      selectedUnit = firstUnit;
    });

    final propertyModel = Provider.of<PropertyDetailVM>(context, listen: false);

    if (firstUnitData != null && firstUnit != null) {
      // Update the selection BEFORE updating type/unit
      propertyModel.updateSelection(value, firstUnit);

      // Update the PropertyDetailVM with the correct unit type and unit number
      propertyModel.updateSelectedTypeUnit(
          firstUnitData.type?.toString() ?? '', firstUnit);
    }

    // Don't call fetchData here - data is already loaded globally
    // Calling fetchData resets property to locationByMonth[0]['location']
  }

  void _handleUnitSelection(String? value, BuildContext context) {
    print(
        '🎯 _handleUnitSelection called with: value=$value, property=$selectedProperty');

    if (value == null || selectedProperty == null) {
      print(
          '❌ Invalid selection: value=$value, selectedProperty=$selectedProperty');
      return;
    }

    setState(() {
      selectedUnit = value;
    });
    print('✅ Local state updated: selectedUnit=$selectedUnit');

    final propertyModel = Provider.of<PropertyDetailVM>(context, listen: false);
    final dashboardModel =
        Provider.of<NewDashboardVM_v3>(context, listen: false);

    // Find all matching units to check for duplicates
    final matchingUnits = dashboardModel.ownerUnits
        .where(
            (unit) => unit.location == selectedProperty && unit.unitno == value)
        .toList();

    print('🔍 Found ${matchingUnits.length} matching units for $value:');
    for (var unit in matchingUnits) {
      print(
          '   - Location: ${unit.location}, Unit: ${unit.unitno}, Type: ${unit.type}');
    }

    // Find the unit type for the selected unit - use firstWhere to ensure we get the exact match
    final selectedUnitData = matchingUnits.firstOrNull;

    // print('🔍 Found unit data: ${selectedUnitData?.type} for unit $value');

    if (selectedUnitData != null) {
      // Update the PropertyDetailVM with the correct unit type and unit number
      // print('🔄 Calling updateSelectedTypeUnit...');

      // Also update the selection BEFORE updating type/unit
      propertyModel.updateSelection(selectedProperty!, value);

      propertyModel.updateSelectedTypeUnit(
          selectedUnitData.type?.toString() ?? '', value);
    }

    // Don't call fetchData here - data is already loaded globally
    // Calling fetchData resets property to locationByMonth[0]['location']
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardModel =
          Provider.of<NewDashboardVM_v3>(context, listen: false);
      final propertyModel =
          Provider.of<PropertyDetailVM>(context, listen: false);

      final firstProperty = dashboardModel.ownerUnits
          .map((unit) => unit.location)
          .where((location) => location != null)
          .firstOrNull;

      if (firstProperty != null) {
        setState(() {
          selectedProperty = firstProperty;
        });

        final firstUnitData = dashboardModel.ownerUnits
            .where((unit) => unit.location == firstProperty)
            .firstOrNull;

        final firstUnit = firstUnitData?.unitno;

        if (firstUnit != null && firstUnitData != null) {
          setState(() {
            selectedUnit = firstUnit;
          });

          // Update the PropertyDetailVM with the correct unit type and unit number
          propertyModel.updateSelectedTypeUnit(
              firstUnitData.type?.toString() ?? '', firstUnit);

          // Update the PropertyDetailVM with initial selection
          propertyModel.updateSelection(firstProperty, firstUnit);

          // Fetch data for the initial unit
          if (dashboardModel.locationByMonth.isNotEmpty) {
            propertyModel.fetchData(dashboardModel.locationByMonth);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<NewDashboardVM_v3>(context);

    // Get properties
    final properties = model.ownerUnits
        .map((unit) => unit.location)
        .where((location) => location != null)
        .toSet()
        .toList();

    // Get units for selected property with debugging
    final allUnitsForProperty = model.ownerUnits
        .where((unit) => unit.location == selectedProperty)
        .toList();

    // print('📊 All units for $selectedProperty:');
    for (var unit in allUnitsForProperty) {
      // print('   - Unit: ${unit.unitno}, Type: ${unit.type}');
    }

    // Create a map to store unique unit numbers with their types
    final Map<String, String> uniqueUnits = {};
    for (var unit in allUnitsForProperty) {
      if (unit.unitno != null) {
        if (!uniqueUnits.containsKey(unit.unitno) ||
            uniqueUnits[unit.unitno] != unit.type?.toString()) {
          uniqueUnits[unit.unitno!] = unit.type?.toString() ?? '';
        }
      }
    }
    final units = uniqueUnits.keys.toList();

    return Row(
      children: [
        // SizedBox(width: ResponsiveSize.scaleWidth(16)),
        // Label
        // Text(
        //   'Unit:',
        //   style: TextStyle(
        //     fontFamily: 'Outfit',
        //     fontSize: ResponsiveSize.text(18),
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        // const SizedBox(width: 8),

        // Property dropdown
        Container(
          width: ResponsiveSize.scaleWidth(160),
          height: ResponsiveSize.scaleHeight(50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveSize.scaleWidth(15)),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: ResponsiveSize.scaleWidth(8)),
              CircleAvatar(
                backgroundColor: Color(0xFF606060),
                child: Image.asset('assets/images/building.png',
                    width: ResponsiveSize.scaleWidth(20),
                    height: ResponsiveSize.scaleWidth(20)),
              ),
              SizedBox(width: ResponsiveSize.scaleWidth(8)),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    value: selectedProperty,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: ResponsiveSize.text(18),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: ResponsiveSize.scaleWidth(20),
                    ),
                    items: properties.map((property) {
                      return DropdownMenuItem(
                        value: property,
                        child: Text(
                          property ?? '',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: ResponsiveSize.text(12),
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      width: ResponsiveSize.scaleWidth(
                          160), // Exact container width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.zero,
                          bottomLeft:
                              Radius.circular(ResponsiveSize.scaleWidth(15)),
                          bottomRight:
                              Radius.circular(ResponsiveSize.scaleWidth(15)),
                        ),
                        color: Colors.white,
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade200),
                          right: BorderSide(color: Colors.grey.shade200),
                          bottom: BorderSide(color: Colors.grey.shade200),
                          top: BorderSide
                              .none, // No top border for seamless connection
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      offset: const Offset(-51, 8), // Perfect alignment
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        _handlePropertySelection(value, context);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: ResponsiveSize.scaleWidth(8)),
            ],
          ),
        ),
        // SizedBox(width: ResponsiveSize.scaleWidth(8)),
        // Text(
        //   ' > ',
        //   style: TextStyle(
        //     fontFamily: 'Outfit',
        //     fontSize: ResponsiveSize.text(18),
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        // Unit dropdown
        SizedBox(width: ResponsiveSize.scaleWidth(20)),
        Container(
          width: ResponsiveSize.scaleWidth(161),
          height: ResponsiveSize.scaleHeight(50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveSize.scaleWidth(15)),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.25),
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: ResponsiveSize.scaleWidth(8)),
              CircleAvatar(
                backgroundColor: Color(0xFF606060),
                child: Image.asset('assets/images/unit.png',
                    width: ResponsiveSize.scaleWidth(20),
                    height: ResponsiveSize.scaleWidth(20)),
              ),
              SizedBox(width: ResponsiveSize.scaleWidth(6)),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    value: selectedUnit,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: ResponsiveSize.text(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: ResponsiveSize.scaleWidth(20),
                    ),
                    items: units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(
                          unit,
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: ResponsiveSize.text(12)),
                        ),
                      );
                    }).toList(),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      width: ResponsiveSize.scaleWidth(
                          161), // Exact container width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius
                              .zero, // No top border radius for seamless connection
                          topRight: Radius
                              .zero, // No top border radius for seamless connection
                          bottomLeft:
                              Radius.circular(ResponsiveSize.scaleWidth(15)),
                          bottomRight:
                              Radius.circular(ResponsiveSize.scaleWidth(15)),
                        ),
                        color: Colors.white,
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade200),
                          right: BorderSide(color: Colors.grey.shade200),
                          bottom: BorderSide(color: Colors.grey.shade200),
                          top: BorderSide
                              .none, // No top border for seamless connection
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      offset: const Offset(-51, 8), // Perfect alignment
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        _handleUnitSelection(value, context);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: ResponsiveSize.scaleWidth(4)),
            ],
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.grey.shade300),
        //   ),
        //   child: DropdownButtonHideUnderline(
        //     child: DropdownButton<String>(
        //       value: selectedUnit,
        //       hint: const Text('Select Unit'),
        //       items: units.map((unit) {
        //         return DropdownMenuItem(
        //           value: unit,
        //           child: Text(
        //             unit ?? '',
        //             style: TextStyle(
        //               fontFamily: 'Outfit',
        //               fontSize: ResponsiveSize.text(16),
        //             ),
        //           ),
        //         );
        //       }).toList(),
        //       onChanged: (value) {
        //         setState(() {
        //           selectedUnit = value;
        //         });
        //       },
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 16),
      ],
    );
  }
}

class EStatementContainer extends StatefulWidget {
  final PropertyDetailVM model;
  const EStatementContainer({Key? key, required this.model}) : super(key: key);

  @override
  State<EStatementContainer> createState() => _EStatementContainerState();
}

class _EStatementContainerState extends State<EStatementContainer> {
  String? _lastPrintedValue;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, child) {
        if (_lastPrintedValue != widget.model.selectedYearValue) {
          _lastPrintedValue = widget.model.selectedYearValue;
          // print(
          //     'selectedYearValue changed to: ${widget.model.selectedYearValue}');
        }

        if (widget.model.isDateLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allItems = widget.model.unitByMonth;
        final seen = <String>{};
        final filteredItems = allItems.where((item) {
          final isSameYear = item.iyear != null &&
              item.iyear.toString() ==
                  widget.model.selectedYearValue.toString();

          if (!isSameYear) return false;

          final key =
              '${item.slocation}-${item.sunitno}-${item.imonth}-${item.iyear}';
          if (seen.contains(key)) {
            return false; // duplicate, skip
          } else {
            seen.add(key);
            return true; // first occurrence, keep
          }
        }).toList();

        if (filteredItems.isEmpty) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              height: 500,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No statements found !',
                      style: TextStyle(
                        fontFamily: 'outfit',
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        String monthNumberToName(int month) {
          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];
          if (month >= 1 && month <= 12) {
            return months[month - 1];
          } else {
            return 'Unknown';
          }
        }

        if (filteredItems.length > 6) {
          return SizedBox(
            height: 500,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, i) {
                      final item = filteredItems[i];

                      if (widget.model.selectedView != 'Overview' &&
                          item.sunitno != widget.model.selectedUnitNo) {
                        return const SizedBox.shrink();
                      }

                      return InkWell(
                        onTap: () => widget.model
                            .downloadSpecificPdfStatement(context, item),
                        child: Container(
                          height: ResponsiveSize.scaleHeight(50),
                          padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveSize.scaleWidth(10)),
                          child: Row(
                            children: [
                              Text(
                                '${item.slocation} ${item.sunitno} ${monthNumberToName(item.imonth ?? 0)} ${item.iyear}',
                                style: TextStyle(
                                  fontFamily: 'outfit',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: 800,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: filteredItems.map((item) {
                if (widget.model.selectedView != 'Overview' &&
                    item.sunitno != widget.model.selectedUnitNo) {
                  return const SizedBox.shrink();
                }

                return InkWell(
                  onTap: () =>
                      widget.model.downloadSpecificPdfStatement(context, item),
                  child: Container(
                    height: ResponsiveSize.scaleHeight(50),
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSize.scaleWidth(10)),
                    child: Row(
                      children: [
                        Text(
                          '${item.slocation} ${item.sunitno} ${monthNumberToName(item.imonth ?? 0)} ${item.iyear}',
                          style: const TextStyle(
                            fontFamily: 'outfit',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
