import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/screens/Property_detail/View/Widget/occupancy_percent_text.dart';
import 'package:mana_mana_app/widgets/occupancy_text.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/property_list_v3.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/View/Widget/typeunit_selection_dropdown.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class property_detail_v3 extends StatefulWidget {
  final List<Map<String, dynamic>> locationByMonth;
  final String? initialType;
  final String? initialUnitNo;
  final String initialTab;

  const property_detail_v3({
    required this.locationByMonth,
    this.initialType,
    this.initialUnitNo,
    this.initialTab = 'overview',
    Key? key,
  }) : super(key: key);

  @override
  State<property_detail_v3> createState() => _property_detail_v3State();
}

class _property_detail_v3State extends State<property_detail_v3> {
  late PropertyDetailVM model;
  late NewDashboardVM_v3 model2;
  bool isCollapsed = false;
  bool showStickyDropdown = false;
  bool showStickyEstatement = false;
  bool isFullScreenEstatement = false;
  late String currentTab;

  final GlobalKey _originalDropdownKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    model = PropertyDetailVM();
    model2 = NewDashboardVM_v3();

    print('PropertyDetailV3: initState called');
    print(
        'PropertyDetailV3: locationByMonth length: ${widget.locationByMonth.length}');

    if (widget.locationByMonth.isNotEmpty) {
      print('PropertyDetailV3: Calling model.fetchData');
      model.fetchData(widget.locationByMonth);
    }

    // Load occupancy data for the dashboard view model
    if (widget.locationByMonth.isNotEmpty) {
      print('PropertyDetailV3: Calling model2.fetchData');
      model2.fetchData();
    }

// Only update selectedView if initialTab is provided
    switch (widget.initialTab) {
      case 'unitDetails':
        model.updateSelectedView('UnitDetails');
        break;
      case 'recentActivity':
        model.updateSelectedView('RecentActivity');
        break;
      default:
        model.updateSelectedView('Overview');
    }
    //model.updateSelectedView('UnitDetails');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.locationByMonth.isNotEmpty) {
        print(
            'PropertyDetailV3: Post frame callback - calling getAverageOccupancyByLocation');
        model2.getAverageOccupancyByLocation(
            widget.locationByMonth.first['location'] ?? '');
      }
    });

    _scrollController.addListener(_onScroll);

    if (widget.initialType != null && widget.initialUnitNo != null) {
      model.updateSelectedView('UnitDetails');
      model.updateSelectedTypeUnit(widget.initialType!, widget.initialUnitNo!);
    }

    currentTab = widget.initialTab;
  }

  void switchTab(String tab) {
    setState(
      () {
        currentTab = tab;
      },
    );
  }

  @override
  // void dispose() {
  //   _scrollController.removeListener(_onScroll);
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  // Add this method to disable scroll for Overview
  void _onScroll() {
    // Only allow scrolling for UnitDetails, block for Overview
    if (model.selectedView == 'Overview') {
      return; // Block all scroll logic for Overview
    }

    final scrollOffset = _scrollController.offset;

    final isMobile = Responsive.isMobile(context);
    final collapsedHeight = isMobile ? 100.fSize : 120.fSize;
    final dropdownInvisibleHeight = isMobile ? 415.fSize : 350.fSize;
    final estatementStickyHeight = isMobile ? 600.fSize : 720.fSize;

    setState(() {
      isCollapsed = scrollOffset > collapsedHeight;

      showStickyDropdown = scrollOffset > dropdownInvisibleHeight &&
          model.selectedView != 'Overview';

      showStickyEstatement = scrollOffset > estatementStickyHeight + 80 &&
          model.selectedView == 'UnitDetails';
    });
  }

  double _calculateStickyEstatementTop() {
    double top = 0;

    if (isCollapsed) {
      top += 80.fSize;
    }
    if (showStickyDropdown) {
      top += 80.fSize;
    }
    return top;
  }

  void _toggleFullScreenEstatement() {
    setState(() {
      isFullScreenEstatement = !isFullScreenEstatement;
    });
  }

  Widget getCurrentTabWidget() {
    switch (currentTab) {
      case 'unitDetails':
        return UnitDetailsContainer(model: model);
      default:
        return PropertyOverviewContainer(
            model: model,
            model2: model2,
            locationByMonth: widget.locationByMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locationByMonth.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Property Details'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SliverToBoxAdapter(
                child: getCurrentTabWidget(),
              ),
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No property data available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider<NewDashboardVM_v3>(
      create: (_) => model2,
      child: ListenableBuilder(
        listenable: model,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                if (isFullScreenEstatement)
                  Container(
                    color: Colors.white,
                    child: SafeArea(
                      child: Column(
                        children: [
                          Container(
                            height: 50.fSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade300, width: 1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 10,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _toggleFullScreenEstatement,
                                  icon: const Icon(Icons.close),
                                ),
                                const Text(
                                  'eStatements',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const Text('Year'),
                                const SizedBox(width: 8),
                                DropdownButton2<String>(
                                  value: model.selectedYearValue,
                                  hint: const Text('Select Year'),
                                  items: model.yearItems
                                      .map((year) => DropdownMenuItem(
                                            value: year,
                                            child: Text(year),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      model.updateSelectedYear(val);
                                    }
                                  },
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ),
                          Expanded(
                            child: EStatementContainer(model: model),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isFullScreenEstatement)
                  CustomScrollView(
                    controller: _scrollController,
                    physics: model.selectedView == 'Overview'
                        ? const NeverScrollableScrollPhysics() // Lock scroll for Overview
                        : const AlwaysScrollableScrollPhysics(), // Allow scroll for UnitDetails
                    slivers: [
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        expandedHeight: 290.fSize,
                        pinned: true,
                        backgroundColor: Colors.white,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              widget.locationByMonth.first['location'] != null
                                  ? Image.asset(
                                      'assets/images/${widget.locationByMonth.first['location'].toString().toUpperCase()}.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: Icon(
                                                Icons.image_not_supported,
                                                size: 64),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported,
                                            size: 64),
                                      ),
                                    ),
                              Positioned(
                                top: 30,
                                left: 10,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Image.asset(
                                      'assets/images/GroupBack.png'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          key: _originalDropdownKey,
                          decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.only(top: 30.fSize),
                          child: Column(
                            children: [
                              Text(
                                widget.locationByMonth.first['location']
                                        ?.toString() ??
                                    'Unknown Property',
                                style: const TextStyle(fontSize: 30),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/map_pin.png',
                                      width: 14.fSize, height: 17.fSize),
                                  Text(model.locationRoad),
                                ],
                              ),
                              SizedBox(height: 10.fSize),
                              OptimizedPropertyDropdown(
                                model: model,
                                width: 370.fSize,
                              ),
                              SizedBox(height: 10.fSize),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: model.selectedView == 'Overview'
                            ? PropertyOverviewContainer(
                                model: model,
                                model2: model2,
                                locationByMonth: widget.locationByMonth)
                            : UnitDetailsContainer(model: model),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 1.5),
                      ),
                    ],
                  ),
                if (!isFullScreenEstatement) ...[
                  if (isCollapsed)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        height: 110.fSize,
                        child: SafeArea(
                          bottom: false,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon:
                                    Image.asset('assets/images/GroupBack.png'),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Property(s)',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (showStickyDropdown)
                    Positioned(
                      top: isCollapsed ? 85.fSize : 0,
                      left: 0,
                      right: 0,
                      child: StickyDropdownBar(
                        model: model,
                        locationByMonth: widget.locationByMonth,
                      ),
                    ),
                  if (showStickyEstatement)
                    Positioned(
                      top: _calculateStickyEstatementTop(),
                      left: 0,
                      right: 0,
                      child: StickyEstatementBar(
                        onBack: () => Navigator.pop(context),
                        onFullScreen: _toggleFullScreenEstatement,
                        yearOptions: model.yearItems,
                        model: model,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight, maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.maxHeight != maxHeight ||
        oldDelegate.minHeight != minHeight ||
        oldDelegate.child != child;
  }
}

class MonthlyStatementContainer extends StatelessWidget {
  final PropertyDetailVM model;
  const MonthlyStatementContainer({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.width,
      decoration: BoxDecoration(
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0XFF120051).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
            spreadRadius: -1.0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(6.width, 3.height, 5.width, 2.height),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (model.isLoading) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return model.isDateLoading
                    ? const CircularProgressIndicator()
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildGradientText('Year'),
                              SizedBox(width: 2.width),
                              TypeUnitSelectionDropdown(
                                label: 'Year',
                                list: model.yearItems,
                                onChanged: (_) {
                                  model.updateSelectedYear(_!);
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildGradientText('Month'),
                              SizedBox(width: 2.width),
                              model.isMonthLoadng
                                  ? const CircularProgressIndicator()
                                  : TypeUnitSelectionDropdown(
                                      label: 'Month',
                                      list: model.monthItems,
                                      onChanged: (_) {
                                        model.updateSelectedMonth(_!);
                                      },
                                    ),
                            ],
                          )
                        ],
                      );
              },
            ),
            SizedBox(height: 4.height),
            ElevatedButton(
              onPressed: () => model.downloadPdfStatement(context),
              // () async {
              // print(property);
              // print(selectedYearValue);
              // print(selectedMonthValue);
              // print(selectedType);
              // print(selectedUnitNo);
              // await ownerPropertyList_repository.downloadPdfStatement(
              //     context,
              //     property,
              //     selectedYearValue,
              //     selectedMonthValue,
              //     selectedType,
              //     selectedUnitNo);
              // },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF4313E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.width, vertical: 0.5.height),
                child: model.isDownloading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Download PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )
            // _buildMonthlyStatementContent(),
          ],
        ),
      ),
    );
  }
}

class AnnualStatementContainer extends StatelessWidget {
  final PropertyDetailVM model;
  const AnnualStatementContainer({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.width,
      decoration: BoxDecoration(
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0XFF3E51FF).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(6.width, 3.height, 5.width, 2.height),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (model.isLoading) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return model.isDateLoading
                    ? const CircularProgressIndicator()
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildGradientText('Year'),
                              SizedBox(width: 2.width),
                              TypeUnitSelectionDropdown(
                                label: 'Year',
                                list: model.yearItems,
                                onChanged: (_) {
                                  model.updateSelectedAnnualYear(_!);
                                },
                              ),
                            ],
                          ),
                        ],
                      );
              },
            ),
            SizedBox(height: 4.height),
            ElevatedButton(
              onPressed: () => model.downloadAnnualPdfStatement(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFF4313E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.width, vertical: 0.5.height),
                child: model.isAnnualDownloading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Download PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )
            // _buildMonthlyStatementContent(),
          ],
        ),
      ),
    );
  }
}

class PropertyOverviewContainer extends StatelessWidget {
  final PropertyDetailVM model;
  final NewDashboardVM_v3 model2;
  final List<Map<String, dynamic>> locationByMonth;

  const PropertyOverviewContainer({
    super.key,
    required this.model,
    required this.model2,
    required this.locationByMonth,
  });

  // Helper method to calculate total Monthly Profit for the property
  double _getTotalMonthlyProfit() {
    if (model.unitByMonth.isEmpty) return 0.0;

    return model.unitByMonth
        .where((unit) =>
            unit.slocation == locationByMonth.first['location'] &&
            unit.stranscode == 'NOPROF')
        .fold(0.0, (sum, unit) => sum + (unit.total ?? 0.0));
  }

  // Helper method to calculate total Net After POB for the property
  double _getTotalNetAfterPOB() {
    if (model.unitByMonth.isEmpty) return 0.0;

    return model.unitByMonth
        .where((unit) =>
            unit.slocation == locationByMonth.first['location'] &&
            unit.stranscode == 'OWNBAL')
        .fold(0.0, (sum, unit) => sum + (unit.total ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
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

    DateTime now = DateTime.now();
    String shortMonth = monthNumberToName(now.month);
    String year = now.year.toString();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) => (value / 375.0) * screenWidth;
    double responsiveHeight(double value) => (value / 812.0) * screenHeight;
    double responsiveFont(double value) => (value / 812.0) * screenHeight;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsiveWidth(10)),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _overviewBox(
              context,
              width: responsiveWidth(160),
              height: responsiveHeight(160),
              image: 'assets/images/PropertyOverview1.png',
              imageWidth: responsiveWidth(67),
              imageHeight: responsiveHeight(59),
              title: 'Total Assets',
              value:
                  '${model.isLoading ? 0 : model.unitByMonth.where((unit) => unit.slocation?.contains(locationByMonth.first['location']) == true).length - 1}',
              subtitle: '$shortMonth $year',
              responsiveFont: responsiveFont,
            ),
            SizedBox(width: responsiveWidth(17)),
            _overviewBox(
              context,
              width: responsiveWidth(160),
              height: responsiveHeight(160),
              image: 'assets/images/PropertyOverview2.png',
              imageWidth: responsiveWidth(65),
              imageHeight: responsiveHeight(38),
              title: 'Occupancy Rate',
              subtitle: '$shortMonth $year',
              child: Consumer<NewDashboardVM_v3>(
                builder: (context, dashboardVM, child) {
                  return OccupancyText(
                    location: locationByMonth.first['location'],
                    unitNo: null,
                    showTotal: true,
                    showPercentageOnly: true,
                    viewModel: dashboardVM,
                  );
                },
              ),
              responsiveFont: responsiveFont,
            ),
          ]),
          SizedBox(height: responsiveHeight(10)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _overviewBox(
              context,
              width: responsiveWidth(160),
              height: responsiveHeight(160),
              image: 'assets/images/PropertyOverview3.png',
              imageWidth: responsiveWidth(59),
              imageHeight: responsiveHeight(58),
              title: 'Monthly Profit',
              subtitle: '$shortMonth $year',
              child: RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Transform.translate(
                        offset: const Offset(0, -4),
                        child: Text(
                          'RM',
                          style: TextStyle(
                            fontSize: responsiveFont(12),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: model.selectedView == 'Overview'
                          ? '${_getTotalMonthlyProfit().toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                          : '${model.selectedUnitPro?.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') ?? '0.00'}',
                      style: TextStyle(
                        fontSize: responsiveFont(16),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              responsiveFont: responsiveFont,
            ),
            SizedBox(width: responsiveWidth(17)),
            _overviewBox(
              context,
              width: responsiveWidth(160),
              height: responsiveHeight(160),
              image: 'assets/images/PropertyOverview4.png',
              imageWidth: responsiveWidth(57),
              imageHeight: responsiveHeight(59),
              title: 'Total Net After POB',
              subtitle: '$shortMonth $year',
              child: RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Transform.translate(
                        offset: const Offset(0, -4),
                        child: Text(
                          'RM',
                          style: TextStyle(
                            fontSize: responsiveFont(12),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: model.selectedView == 'Overview'
                          ? '${_getTotalNetAfterPOB().toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                          : '${model.selectedUnitBlc?.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') ?? '0.00'}',
                      style: TextStyle(
                        fontSize: responsiveFont(16),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              responsiveFont: responsiveFont,
            ),
          ]),
        ],
      ),
    );
  }

  /// ✅ Reusable Box Widget
  Widget _overviewBox(
    BuildContext context, {
    required double width,
    required double height,
    required String image,
    required double imageWidth,
    required double imageHeight,
    required String title,
    String? value,
    String? subtitle,
    Widget? child,
    required double Function(double) responsiveFont,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E51FF).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, width: imageWidth, height: imageHeight),
          SizedBox(height: responsiveFont(5)),
          Text(title, style: TextStyle(fontSize: responsiveFont(12))),
          if (value != null)
            Text(value,
                style: TextStyle(
                  fontSize: responsiveFont(14),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
          if (child != null) child,
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(fontSize: responsiveFont(10)),
            ),
        ],
      ),
    );
  }

  double getAverageOccupancyRate() {
    if (model.locationByMonth.isEmpty) return 0.0;

    double totalOccupancy = 0.0;
    int count = 0;

    for (var location in model.locationByMonth) {
      if (location['occupancy'] != null) {
        totalOccupancy += location['occupancy'];
        count++;
      }
    }

    return totalOccupancy / count;
  }
}

class ContractDetailsContainer extends StatelessWidget {
  final PropertyDetailVM model;
  final NewDashboardVM_v3 model2;
  final List<Map<String, dynamic>> locationByMonth;

  const ContractDetailsContainer({
    super.key,
    required this.model,
    required this.model2,
    required this.locationByMonth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) => (value / 375.0) * screenWidth;
    double responsiveHeight(double value) => (value / 812.0) * screenHeight;
    double responsiveFont(double value) => (value / 812.0) * screenHeight;

    return Builder(
      builder: (context) {
        final hasData = model.locationByMonth.isNotEmpty;
        final unitType = hasData && model.locationByMonth.isNotEmpty
            ? model.locationByMonth.first['unitType'] as String?
            : '';

        return Padding(
          padding: EdgeInsets.all(responsiveWidth(10)),
          child: Container(
            width: responsiveWidth(380),
            height: responsiveHeight(40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(responsiveHeight(50)),
              border: Border.all(color: const Color(0xFF5092FF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Contract Type
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Contract Type ',
                        style: TextStyle(fontSize: responsiveFont(10)),
                      ),
                      Text(
                        (model.locationByMonth.isNotEmpty &&
                                model.locationByMonth.first['owners'] != null)
                            ? (model.locationByMonth.first['owners'] as List)
                                .where((owner) =>
                                    owner['unitNo'] == model.selectedUnitNo)
                                .map((owner) => owner['contractType'] ?? '')
                                .join('')
                            : '',
                        style: TextStyle(
                          fontSize: responsiveFont(11),
                          color: const Color(0xFF5092FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                SizedBox(
                  height: responsiveHeight(30),
                  child: VerticalDivider(
                    color: const Color(0xFF5092FF),
                    thickness: 1,
                  ),
                ),

                // Contract End Date
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Contract End Date ',
                        style: TextStyle(fontSize: responsiveFont(10)),
                      ),
                      Text(
                        (model.locationByMonth.isNotEmpty &&
                                model.locationByMonth.first['owners'] != null)
                            ? (model.locationByMonth.first['owners'] as List)
                                .where((owner) =>
                                    owner['unitNo'] == model.selectedUnitNo)
                                .map((owner) {
                                final rawDate = owner['endDate'];
                                if (rawDate == null || rawDate.isEmpty) {
                                  return '';
                                }
                                try {
                                  final date = DateTime.parse(rawDate);
                                  return DateFormat('dd MMM yyyy').format(date);
                                } catch (e) {
                                  return rawDate;
                                }
                              }).join(' ')
                            : '',
                        style: TextStyle(
                          fontSize: responsiveFont(11),
                          color: const Color(0xFF5092FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UnitDetailsContainer extends StatelessWidget {
  final PropertyDetailVM model;

  const UnitDetailsContainer({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height
    double responsiveFont(double value) =>
        (value / 812.0) * screenHeight; // font scaling

    double responsivePadding = isMobile ? 10 : 15;
    //double responsiveFont = isMobile ? 12 : 16;
    double responsiveFont2 = isMobile ? 10 : 12;
    double responsiveFont3 = isMobile ? 15 : 18;
    final totalPro = model.selectedUnitPro?.total ?? 0.0;
    final formattedTotalPro = totalPro.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    final totalBlc = model.selectedUnitBlc?.total ?? 0.0;
    final formattedTotalBlc = totalBlc.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    final location = model.locationByMonth.first['location'] ?? 'Unknown';
    final unitNo = model.selectedUnitNo ?? 'Unknown';

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
      if (month >= 1 && month <= 12) {
        return months[month - 1];
      } else {
        return 'Unknown';
      }
    }

    /// Converts a month number (1-12) to its corresponding month name.
    ///
    /// Returns 'Unknown' if [month] is not in the range 1-12.
    ///
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

    DateTime now = DateTime.now();
    String shortMonth = _monthNumberToName(now.month);
    String year = now.year.toString();
    final NewDashboardVM_v3 model2 = NewDashboardVM_v3();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 25.fSize),
          ContractDetailsContainer(
              model: model,
              model2: model2,
              locationByMonth: model.locationByMonth),
          Row(
            children: [
              Column(
                children: [
                  Padding(
                    // Fix: Removed duplicate 'padding' argument
                    padding: EdgeInsets.only(
                        left: responsivePadding, top: responsivePadding),
                    child: Image.asset(
                      'assets/images/Group.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: responsivePadding, top: 1),
                    child: Text('Owner(s)',
                        style: TextStyle(
                          fontSize: responsiveFont(12),
                        )),
                  )
                ],
              ),
              //SizedBox(width: 5.fSize),
              Container(
                alignment: Alignment.centerLeft,
                width: responsiveWidth(300),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (var owner
                            in model.locationByMonth.first['owners'] ?? []) ...[
                          Padding(
                            padding: EdgeInsets.only(left: responsivePadding),
                            child: Tooltip(
                              message: owner['unitNo'] == model.selectedUnitNo
                                  ? '${owner['ownerName']} - Unit ${owner['unitNo']}'
                                  : 'Unknown Owner',
                              child: CircleAvatar(
                                radius: 13,
                                backgroundColor:
                                    owner['unitNo'] == model.selectedUnitNo
                                        ? Colors.blue
                                        : Colors.transparent,
                                child: Text(
                                  owner['unitNo'] == model.selectedUnitNo
                                      ? getInitials(owner['ownerName'] ?? '')
                                      : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsiveFont(12),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 1.width),
                          owner['unitNo'] == model.selectedUnitNo
                              ? Text(owner['ownerName'] ?? '',
                                  style:
                                      TextStyle(fontSize: responsiveFont(12)))
                              : Text(''),
                          SizedBox(width: 2.width),
                        ]
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 2.height),
          Container(
            // height: 125,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsivePadding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: responsiveWidth(110),
                      height: isMobile
                          ? 125
                          : MediaQuery.of(context).size.height * 0.25,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3E51FF).withOpacity(0.15),
                              blurRadius: responsiveFont(10),
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/PropertyOverview2.png',
                                width: 39.fSize,
                                height: 22.fSize,
                              ),
                              SizedBox(height: responsiveHeight(15)),
                              Text(
                                'Occupancy Rate',
                                style: TextStyle(
                                  fontSize: responsiveFont(11),
                                ),
                              ),
                              FutureBuilder<String>(
                                future: model2.getUnitOccupancy(
                                  model.locationByMonth.first['location'],
                                  model.selectedUnitNo ?? '',
                                ),
                                builder: (context, snapshot) {
                                  // if (snapshot.connectionState ==
                                  //     ConnectionState.waiting) {
                                  //   return const Text('Loading...',
                                  //       style: TextStyle(
                                  //           fontSize: 15,
                                  //           fontWeight: FontWeight.bold));
                                  // } else
                                  if (snapshot.hasError) {
                                    return Text(
                                      'Error',
                                      style: TextStyle(
                                          fontSize: responsiveFont(15),
                                          fontWeight: FontWeight.bold),
                                    );
                                  } else {
                                    return Text(
                                      snapshot.data ?? '',
                                      style: TextStyle(
                                        fontSize: responsiveFont(10),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: 5.fSize),
                              Text(
                                'As of Month ${model2.propertyOccupancy.isNotEmpty ? _getLatestOccupancyDate(model2.propertyOccupancy, _monthNumberToName) : '$shortMonth $year'}',
                                style: TextStyle(
                                  fontSize: responsiveFont(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: responsivePadding),
                    SizedBox(
                      width: responsiveWidth(110),
                      height: isMobile
                          ? 125
                          : MediaQuery.of(context).size.height * 0.25,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF3E51FF).withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/PropertyOverview3.png',
                                width: 30.fSize,
                                height: 30.fSize,
                              ),
                              const SizedBox(height: 13),
                              Text(
                                'Monthly Profit',
                                style: TextStyle(
                                  fontSize: responsiveFont(11),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: Transform.translate(
                                        offset: const Offset(0, -4),
                                        child: Text(
                                          'RM',
                                          style: TextStyle(
                                            fontSize: responsiveFont(10),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$formattedTotalPro',
                                      style: TextStyle(
                                        fontSize: responsiveFont(15),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 3.fSize),
                              Text(
                                '$shortMonth $year',
                                style: TextStyle(
                                  fontSize: responsiveFont(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: responsivePadding),
                    SizedBox(
                      width: responsiveWidth(110),
                      height: isMobile
                          ? 125
                          : MediaQuery.of(context).size.height * 0.25,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3E51FF).withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/PropertyOverview4.png',
                                width: 30.fSize,
                                height: 30.fSize,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Net After POB',
                                style: TextStyle(
                                  fontSize: responsiveFont(11),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: Transform.translate(
                                        offset: const Offset(0, -4),
                                        child: Text(
                                          'RM',
                                          style: TextStyle(
                                            fontSize: responsiveFont(10),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$formattedTotalBlc',
                                      style: TextStyle(
                                        fontSize: responsiveFont(15),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text('$shortMonth $year',
                                  style: TextStyle(
                                    fontSize: responsiveFont(10),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
          SizedBox(height: 15),
          SizedBox(
              height: 0.5,
              width: isMobile ? 400 : 800,
              child:
                  Container(color: const Color.fromARGB(255, 152, 152, 152))),
          StickyEstatementBar(
              onBack: () => Navigator.pop(context),
              yearOptions: model.yearItems,
              model: model),
          EStatementContainer(model: model),
        ],
      ),
    );
  }

  String _getLatestOccupancyDate(Map<String, dynamic> propertyOccupancy,
      String Function(int) monthNumberToName) {
    int latestMonth = 0;
    int latestYear = 0;
    String latestMonthName = '';

    propertyOccupancy.values.forEach((location) {
      location['units'].values.forEach((unit) {
        if (unit['year'] > latestYear ||
            (unit['year'] == latestYear && unit['month'] > latestMonth)) {
          latestMonth = unit['month'];
          latestYear = unit['year'];
          latestMonthName = monthNumberToName(latestMonth);
        }
      });
    });

    return '$latestMonthName $latestYear';
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
    final isMobile = Responsive.isMobile(context);
    double responsivePadding = isMobile ? 10 : 20;
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
        final filteredItems = allItems.where((item) {
          return item.iyear != null &&
              item.iyear.toString() ==
                  widget.model.selectedYearValue.toString();
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
          // More than one screen, allow scrolling
          return SizedBox(
            height: 500,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    //physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, i) {
                      final item = filteredItems[i];

                      if (widget.model.selectedView != 'Overview' &&
                          item.sunitno != widget.model.selectedUnitNo) {
                        return const SizedBox.shrink();
                      }

                      return InkWell(
                        onTap: () => widget.model.downloadPdfStatement(context),
                        child: Container(
                          height: 50.fSize,
                          padding: EdgeInsets.symmetric(
                              horizontal: responsivePadding),
                          child: Row(
                            children: [
                              Text(
                                '${item.slocation} ${item.sunitno} ${monthNumberToName(item.imonth ?? 0)} ${item.iyear}',
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
                  onTap: () => widget.model.downloadPdfStatement(context),
                  child: Container(
                    height: 50.fSize,
                    padding:
                        EdgeInsets.symmetric(horizontal: responsivePadding),
                    child: Row(
                      children: [
                        Text(
                          '${item.slocation} ${item.sunitno} ${monthNumberToName(item.imonth ?? 0)} ${item.iyear}',
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

class StickyDropdownBar extends StatelessWidget {
  final PropertyDetailVM model;
  final List<Map<String, dynamic>> locationByMonth;

  const StickyDropdownBar({
    Key? key,
    required this.model,
    required this.locationByMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.fSize,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  locationByMonth.first['location'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 40.fSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.only(right: 10, bottom: 3),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        maxHeight: 200,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(Icons.keyboard_arrow_down),
                        iconSize: 20,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: 'Overview',
                          child: Text(
                            'Overview',
                            style: TextStyle(
                                fontSize: 12, decoration: TextDecoration.none),
                          ),
                        ),
                        ...model.typeItems.map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          if (newValue == 'Overview') {
                            model.updateSelectedView('Overview');
                          } else {
                            final parts = newValue.split(' (');
                            if (parts.length == 2) {
                              final type = parts[0].trim();
                              final unit = parts[1].replaceAll(')', '').trim();

                              model.updateSelectedView('UnitDetails');
                              model.updateSelectedTypeUnit(type, unit);
                            }
                          }
                        }
                      },
                      hint: const Text('Select Unit'),
                      value: model.selectedView == 'Overview'
                          ? 'Overview'
                          : (model.selectedType != null &&
                                  model.selectedUnitNo != null)
                              ? '${model.selectedType!.trim()} (${model.selectedUnitNo!.trim()})'
                              : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StickyEstatementBar extends StatefulWidget {
  final VoidCallback onBack;
  final List<String> yearOptions;
  final PropertyDetailVM model;
  final VoidCallback? onFullScreen;
  const StickyEstatementBar({
    required this.onBack,
    required this.yearOptions,
    required this.model,
    this.onFullScreen,
    Key? key,
  }) : super(key: key);

  @override
  _StickyEstatementBarState createState() => _StickyEstatementBarState();
}

class _StickyEstatementBarState extends State<StickyEstatementBar> {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    double responsivePadding = isMobile ? 5 : 20;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsivePadding),
      child: Container(
        height: 95.fSize,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 8),
              const Text(
                'eStatements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Text('Year'),
              const SizedBox(width: 8),
              DropdownButton2<String>(
                underline: const SizedBox(),
                buttonStyleData: ButtonStyleData(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 0.5),

                    //remove text underline of the dropdown bar
                  ),
                ),
                value: widget.model.selectedYearValue,
                hint: widget.model.yearItems.isNotEmpty
                    ? const Text(
                        'Select Year',
                        style: TextStyle(
                            fontSize: 10, decoration: TextDecoration.none),
                      )
                    : const Text(
                        '-',
                        style: TextStyle(
                            fontSize: 10, decoration: TextDecoration.none),
                      ),
                items: widget.yearOptions
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    widget.model.updateSelectedYear(val);
                  }
                },
                dropdownStyleData: DropdownStyleData(
                  offset: const Offset(0, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: const Border(
                      left: BorderSide(color: Colors.grey, width: 0.5),
                      right: BorderSide(color: Colors.grey, width: 0.5),
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                      // top: BorderSide.none  // so no border at top
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0),
                        blurRadius: 10,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildGradientText(String text) {
  return GradientText1(
    text: text,
    style: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 17.fSize,
      fontWeight: FontWeight.w700,
    ),
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF2900B7), Color(0xFF120051)],
    ),
  );
}

class OptimizedPropertyDropdown extends StatefulWidget {
  final PropertyDetailVM model;
  final double width;

  const OptimizedPropertyDropdown({
    Key? key,
    required this.model,
    required this.width,
  }) : super(key: key);

  @override
  State<OptimizedPropertyDropdown> createState() =>
      _OptimizedPropertyDropdownState();
}

class _OptimizedPropertyDropdownState extends State<OptimizedPropertyDropdown> {
  List<DropdownMenuItem<String>>? _cachedItems;
  List<String>? _lastTypeItems;
  String? _cachedValue;

  // Static decoration objects to avoid recreation
  static final _containerDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey, width: 0.5),
    borderRadius: BorderRadius.circular(4),
  );

  static final _dropdownDecoration = BoxDecoration(
    color: Colors.white,
    border: const Border(
      left: BorderSide(color: Colors.grey, width: 0.5),
      right: BorderSide(color: Colors.grey, width: 0.5),
      bottom: BorderSide(color: Colors.grey, width: 0.5),
    ),
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(4),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const _textStyle = TextStyle(fontSize: 12);
  static const _hintText = Text('Select Unit');
  static const _loadingText =
      Text('Loading...', style: TextStyle(fontSize: 12, color: Colors.grey));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, child) {
        // Show loading state while data is being fetched
        if (widget.model.isLoading || widget.model.typeItems.isEmpty) {
          return Container(
            width: widget.width,
            decoration: _containerDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButton2<String>(
              isExpanded: true,
              underline: const SizedBox(),
              dropdownStyleData: DropdownStyleData(
                width: widget.width,
                offset: const Offset(-12.5, -1),
                useSafeArea: true,
                decoration: _dropdownDecoration,
                maxHeight: 200,
              ),
              items: const [
                DropdownMenuItem<String>(
                  value: 'Overview',
                  child: Text('Overview', style: _textStyle),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue == 'Overview') {
                  widget.model.updateSelectedView('Overview');
                }
              },
              hint: _loadingText,
              value: 'Overview',
            ),
          );
        }

        // Only rebuild items if typeItems changed
        if (_lastTypeItems == null ||
            !_listEquals(_lastTypeItems!, widget.model.typeItems)) {
          _buildCachedItems();
          _lastTypeItems = List.from(widget.model.typeItems);
        }

        // Cache the computed value
        final currentValue = _computeSelectedValue();
        if (_cachedValue != currentValue) {
          _cachedValue = currentValue;
        }

        return Container(
          width: widget.width,
          decoration: _containerDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButton2<String>(
            isExpanded: true,
            underline: const SizedBox(),
            dropdownStyleData: DropdownStyleData(
              width: widget.width,
              offset: const Offset(-12.5, -1),
              useSafeArea: true,
              decoration: _dropdownDecoration,
              maxHeight: 200,
            ),
            items: _cachedItems,
            onChanged: _handleChange,
            hint: _hintText,
            value: _cachedValue,
          ),
        );
      },
    );
  }

  void _buildCachedItems() {
    _cachedItems = [
      const DropdownMenuItem<String>(
        value: 'Overview',
        child: Text('Overview', style: _textStyle),
      ),
      ...widget.model.typeItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: _textStyle),
        );
      }),
    ];
  }

  String? _computeSelectedValue() {
    if (widget.model.selectedView == 'Overview') {
      return 'Overview';
    }

    if (widget.model.selectedType != null &&
        widget.model.selectedUnitNo != null) {
      return '${widget.model.selectedType!.trim()} (${widget.model.selectedUnitNo!.trim()})';
    }

    return null;
  }

  void _handleChange(String? newValue) {
    if (newValue == null) return;

    if (newValue == 'Overview') {
      widget.model.updateSelectedView('Overview');
    } else {
      final parts = newValue.split(' (');
      if (parts.length == 2) {
        final type = parts[0].trim();
        final unit = parts[1].replaceAll(')', '').trim();

        widget.model.updateSelectedView('UnitDetails');
        widget.model.updateSelectedTypeUnit(type, unit);
      }
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class ResponsiveScale {
  final BuildContext context;
  late double screenWidth;
  late double screenHeight;

  ResponsiveScale(this.context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  double width(double value) => (value / 375.0) * screenWidth; // base width
  double height(double value) => (value / 812.0) * screenHeight; // base height
  double font(double value) => (value / 812.0) * screenHeight; // font scaling
}
