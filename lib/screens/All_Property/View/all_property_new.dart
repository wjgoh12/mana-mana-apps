import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/enhanced_statement_dropdown.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/enhanced_statement_container.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Profile/View/choose_property_location_book.dart';
import 'package:mana_mana_app/screens/Profile/View/financial_details.dart';
import 'package:mana_mana_app/screens/Profile/View/property_redemption.dart';
import 'package:mana_mana_app/screens/Profile/View/choose_property_location.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/unit_overview_container.dart';
import 'package:provider/provider.dart';

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
            backgroundColor: const Color(0XFFFFFFFF),
            appBar: propertyAppBar(context, () => Navigator.of(context).pop()),
            body: SingleChildScrollView(
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
                  // Enhanced Statement Container
                  Builder(
                    builder: (context) {
                      // print(
                      //     '🔄 Statement Container Builder triggered - selectedProperty: ${propertyModel.selectedProperty}, selectedUnitNo: ${propertyModel.selectedUnitNo}, selectedType: ${propertyModel.selectedType}');
                      if (propertyModel.selectedProperty != null &&
                          propertyModel.selectedUnitNo != null &&
                          propertyModel.selectedType != null) {
                        // print('✅ Showing Statement Container');
                        return EnhancedStatementContainer(model: propertyModel);
                      }
                      // print('❌ Hiding Statement Container');
                      return const SizedBox.shrink();
                    },
                  ),
                ],
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
            EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(20)),
        child: Row(
          children: [
            //1
            Expanded(
              child: SizedBox(
                height: ResponsiveSize.scaleWidth(120),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  FinancialDetails(),
                          transitionDuration: const Duration(milliseconds: 300),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 300),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                          ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                          child: Icon(
                            Icons.wallet,
                            size: ResponsiveSize.scaleWidth(40),
                            color: Colors
                                .white, // important! acts as a mask for the gradient
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Financial Details',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(12),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //2
            Expanded(
              child: SizedBox(
                height: ResponsiveSize.scaleWidth(120),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Create and initialize the VM
                      final ownerVm = OwnerProfileVM();
                      final globalData = Provider.of<GlobalDataManager>(context,
                          listen: false);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiProvider(
                            providers: [
                              // Provide GlobalDataManager first
                              ChangeNotifierProvider.value(
                                value: globalData,
                              ),
                              // Then provide OwnerProfileVM
                              ChangeNotifierProvider.value(
                                value: ownerVm,
                              ),
                            ],
                            child: const ChoosePropertyLocationBook(
                              selectedLocation: '',
                              selectedUnitNo: '',
                            ),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                          ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                          child: Icon(
                            Icons.book,
                            size: ResponsiveSize.scaleWidth(40),
                            color: Colors
                                .white, // important! acts as a mask for the gradient
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Make a Booking',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(12),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //3
            Expanded(
              child: SizedBox(
                height: ResponsiveSize.scaleWidth(120),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
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
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                          ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                          child: Icon(
                            Icons.hotel,
                            size: ResponsiveSize.scaleWidth(40),
                            color: Colors
                                .white, // important! acts as a mask for the gradient
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Free Stay Redemption',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveSize.text(12),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
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
      // Update the PropertyDetailVM with the correct unit type and unit number
      propertyModel.updateSelectedTypeUnit(
          firstUnitData.type?.toString() ?? '', firstUnit);

      // Also update the selection
      propertyModel.updateSelection(value, firstUnit);
    }

    if (model.locationByMonth.isNotEmpty) {
      propertyModel.fetchData(model.locationByMonth);
    }
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
      propertyModel.updateSelectedTypeUnit(
          selectedUnitData.type?.toString() ?? '', value);

      // Also update the selection
      propertyModel.updateSelection(selectedProperty!, value);
    }

    if (dashboardModel.locationByMonth.isNotEmpty) {
      // print('📡 Calling fetchData...');
      propertyModel.fetchData(dashboardModel.locationByMonth);
    }
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

    print('📊 All units for $selectedProperty:');
    for (var unit in allUnitsForProperty) {
      print('   - Unit: ${unit.unitno}, Type: ${unit.type}');
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
        const SizedBox(width: 16),
        // Label
        Text(
          'Unit:',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: ResponsiveSize.text(18),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),

        // Property dropdown
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: selectedProperty,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: ResponsiveSize.text(18),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            // icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            items: properties.map((property) {
              return DropdownMenuItem(
                value: property,
                child: Text(
                  property ?? '',
                  style: TextStyle(
                      fontFamily: 'Outfit', fontSize: ResponsiveSize.text(14)),
                ),
              );
            }).toList(),
            dropdownStyleData: const DropdownStyleData(
              maxHeight: 200,
              // width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                color: Colors.white,
              ),
              offset: Offset(0, 0),
            ),
            onChanged: (value) {
              if (value != null) {
                _handlePropertySelection(value, context);
              }
            },
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
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: selectedUnit,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: ResponsiveSize.text(14),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            // icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            items: units.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(
                  unit,
                  style: TextStyle(
                      fontFamily: 'Outfit', fontSize: ResponsiveSize.text(14)),
                ),
              );
            }).toList(),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: ResponsiveSize.scaleWidth(120),
              decoration: const BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                color: Colors.white,
              ),
              offset: const Offset(0, 0),
            ),
            onChanged: (value) {
              if (value != null) {
                _handleUnitSelection(value, context);
              }
            },
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
        const SizedBox(width: 16),
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
