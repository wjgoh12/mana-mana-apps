import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/View/property_list_v3.dart';
import 'package:mana_mana_app/screens/Dashboard_v3/ViewModel/new_dashboardVM_v3.dart';
import 'package:mana_mana_app/screens/Property_detail/View/Widget/typeunit_selection_dropdown.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class property_detail_v3 extends StatefulWidget {
  final List<Map<String, dynamic>> locationByMonth;
  const property_detail_v3({required this.locationByMonth, Key? key})
      : super(key: key);

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

  final GlobalKey _originalDropdownKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    model = PropertyDetailVM();

    if (widget.locationByMonth.isNotEmpty) {
      model.fetchData(widget.locationByMonth);
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Add this method to disable scroll for Overview
  void _onScroll() {
    // Only allow scrolling for UnitDetails, block for Overview
    if (model.selectedView == 'Overview') {
      return; // Block all scroll logic for Overview
    }

    final scrollOffset = _scrollController.offset;

    final collapsedHeight = 100.fSize;
    final dropdownInvisibleHeight = 415.fSize;
    final estatementStickyHeight = 585.fSize;

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
      top += 85.fSize;
    }
    if (showStickyDropdown) {
      top += 70.fSize;
    }
    return top;
  }

  void _toggleFullScreenEstatement() {
    setState(() {
      isFullScreenEstatement = !isFullScreenEstatement;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locationByMonth.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property Details'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No property data available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: model,
      builder: (context, child) {
        return Scaffold(
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
                                    fontSize: 20, fontWeight: FontWeight.bold),
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
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(Icons.image_not_supported,
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
                                icon:
                                    Image.asset('assets/images/GroupBack.png'),
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
                            Container(
                              width: 370.fSize,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownStyleData: DropdownStyleData(
                                  width: 370.fSize,
                                  offset: const Offset(-12.5, -1),
                                  useSafeArea: true,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: const Border(
                                      left: BorderSide(
                                          color: Colors.grey, width: 0.5),
                                      right: BorderSide(
                                          color: Colors.grey, width: 0.5),
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 0.5),
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
                                  ),
                                  maxHeight: 200,
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'Overview',
                                    child: Text('Overview'),
                                  ),
                                  ...model.typeItems
                                      .map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
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
                                        final unit =
                                            parts[1].replaceAll(')', '').trim();

                                        model.updateSelectedView('UnitDetails');
                                        model.updateSelectedTypeUnit(
                                            type, unit);
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
                            SizedBox(height: 20.fSize),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: model.selectedView == 'Overview'
                          ? PropertyOverviewContainer(
                              model: model,
                              locationByMonth: widget.locationByMonth)
                          : UnitDetailsContainer(
                              model: model,
                            ),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      height: 85.fSize,
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Image.asset('assets/images/GroupBack.png'),
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
  final List<Map<String, dynamic>> locationByMonth;
  const PropertyOverviewContainer(
      {super.key, required this.model, required this.locationByMonth});

  @override
  Widget build(BuildContext context) {
    double getTotalNetAfterPOB() {
      return model.unitByMonth
          .where((unit) => unit.slocation == model.property)
          .fold(0.0, (sum, unit) => sum + (model.selectedUnitBlc ?? 0.0));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  color: const Color(0XFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3E51FF).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Image.asset(
                        'assets/images/PropertyOverview1.png',
                        width: 67.fSize,
                        height: 59.fSize,
                      ),
                    ),
                    SizedBox(height: 5.fSize),
                    const Text(
                      'Total Assets',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                        '${model.isLoading ? 0 : model.unitByMonth.where((unit) => unit.slocation?.contains(locationByMonth.first['location']) == true).length - 1}'),
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 17.fSize),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  color: const Color(0XFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3E51FF).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 45),
                  child: Column(
                    children: [
                      SizedBox(height: 5.fSize),
                      Image.asset(
                        'assets/images/PropertyOverview2.png',
                        width: 65.fSize,
                        height: 38.fSize,
                      ),
                      SizedBox(height: 5.fSize),
                      const Text(
                        'Occupancy Rate',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text('${locationByMonth.first['totalAssets'] ?? ''}'),
                      Text(
                          DateFormat('MMMM yyyy').format(
                            DateTime.now(),
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ]),
          SizedBox(height: 10.fSize),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  color: const Color(0XFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3E51FF).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/PropertyOverview3.png',
                        width: 59.fSize,
                        height: 58.fSize,
                      ),
                      const Text(
                        'Monthly Profit',
                        style: TextStyle(
                          fontSize: 12,
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
                                child: const Text(
                                  'RM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${model.locationByMonth.first['total'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 17.fSize),
              Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  color: const Color(0XFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3E51FF).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/PropertyOverview4.png',
                        width: 57.fSize,
                        height: 59.fSize,
                      ),
                      const Text(
                        'Total Net After POB',
                        style: TextStyle(
                          fontSize: 12,
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
                                child: const Text(
                                  'RM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${model.locationByMonth.first['total'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class ContractDetailsContainer extends StatelessWidget {
  final PropertyDetailVM model;
  final NewDashboardVM_v3 model2;
  final List<Map<String, dynamic>> locationByMonth;

  const ContractDetailsContainer(
      {super.key,
      required this.model,
      required this.model2,
      required this.locationByMonth});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: model.fetchData(locationByMonth),
      builder: (context, snapshot) {
        final hasData = snapshot.connectionState == ConnectionState.done;
        final unitType = hasData && model.locationByMonth.isNotEmpty
            ? model.locationByMonth.first['unitType'] as String?
            : '';

        return Container(
          //alignment: Alignment.spaceBetween,
          width: 400.fSize,
          height: 50.fSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.fSize),
            border: Border.all(color: const Color(0xFF5092FF)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 5, top: 5, bottom: 10),
                        child: Text(
                          'Contract Type',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 5, top: 5, bottom: 10),
                        child: Text(
                          (model.locationByMonth.first['owners'] ?? [])
                              .where((owner) =>
                                  owner['unitNo'] == model.selectedUnitNo)
                              .map((owner) => owner['contractType'] ?? '')
                              .join(' '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5092FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    width: 1,
                    height: 30,
                    child: Container(
                      color: const Color(0xFF5092FF),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 10),
                      child: Text('Contract End Date',
                          style: TextStyle(
                            fontSize: 10,
                          )),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 3, top: 5, bottom: 10),
                      child: Text(
                        (model.locationByMonth.first['owners'] ?? [])
                            .where((owner) =>
                                owner['unitNo'] == model.selectedUnitNo)
                            .map((owner) => owner['endDate'] ?? '')
                            .join(' '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5092FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                    padding: const EdgeInsets.only(left: 15, top: 25),
                    child: Image.asset(
                      'assets/images/Group.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, top: 1),
                    child: Text('Owner(s)',
                        style: TextStyle(
                          fontSize: 12,
                        )),
                  )
                ],
              ),
              //SizedBox(width: 5.fSize),
              Container(
                alignment: Alignment.topLeft,
                width: 300,
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (var owner
                            in model.locationByMonth.first['owners'] ?? []) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 1),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 1.width),
                          owner['unitNo'] == model.selectedUnitNo
                              ? Text(owner['ownerName'] ?? '')
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
            height: 125,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 125,
                  height: 125,
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
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/PropertyOverview2.png',
                            width: 39.fSize,
                            height: 22.fSize,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Occupancy Rate',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          Text(
                              '${model.locationByMonth.first['occupancy'] ?? ''}% Active',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: 5.fSize),
                          Text(
                              DateFormat('MMMM yyyy').format(
                                DateTime.now(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 125,
                  height: 125,
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
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/PropertyOverview3.png',
                            width: 30.fSize,
                            height: 30.fSize,
                          ),
                          const SizedBox(height: 13),
                          const Text(
                            'Monthly Profit',
                            style: TextStyle(
                              fontSize: 10,
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
                                    child: const Text(
                                      'RM',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${model.selectedUnitPro.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                              DateFormat('MMMM yyyy').format(
                                DateTime.now(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 125,
                  height: 125,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF3E51FF).withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/PropertyOverview4.png',
                            width: 30.fSize,
                            height: 30.fSize,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Net After POB',
                            style: TextStyle(
                              fontSize: 9,
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
                                    child: const Text(
                                      'RM',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${model.selectedUnitBlc.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                              DateFormat('MMMM yyyy').format(
                                DateTime.now(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          StickyEstatementBar(
              onBack: () => Navigator.pop(context),
              yearOptions: model.yearItems,
              model: model),
          EStatementContainer(model: model)
        ],
      ),
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
          print(
              'selectedYearValue changed to: ${widget.model.selectedYearValue}');
        }

        if (widget.model.isDateLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // if (widget.model.selectedYearValue == null ||
        //     widget.model.selectedYearValue!.isEmpty) {
        //   return Container(
        //     decoration: const BoxDecoration(
        //       color: Colors.white,
        //     ),
        //     height: 500,
        //     child: Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Icon(
        //             Icons.calendar_today_outlined,
        //             size: 48,
        //             color: Colors.grey.shade400,
        //           ),
        //           SizedBox(height: 16),
        //           Text(
        //             'Please select a year to view statements',
        //             style: TextStyle(
        //               fontSize: 16,
        //               color: Colors.grey.shade600,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   );
        // }

        final allItems = widget.model.unitByMonth;
        final filteredItems = allItems.where((item) {
          return item.iyear != null &&
              item.iyear.toString() ==
                  widget.model.selectedYearValue.toString();
        }).toList();
        if (filteredItems.isEmpty) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            height: 200,
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
            'Sept',
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

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          height: 500,
          child: ListView.builder(
            itemCount: filteredItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              final item = filteredItems[i];

              if (widget.model.selectedView != 'Overview' &&
                  item.sunitno != widget.model.selectedUnitNo) {
                return const SizedBox.shrink();
              }

              return InkWell(
                hoverColor: Colors.grey.shade50,
                onTap: () => widget.model.downloadPdfStatement(context),
                child: Container(
                  height: 50.fSize,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                          '${item.slocation} ${item.sunitno} ${monthNumberToName(item.imonth ?? 0)} ${item.iyear}'),
                    ],
                  ),
                ),
              );
            },
          ),
        );
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
      height: 70.fSize,
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
                          child: Text('Overview'),
                        ),
                        ...model.typeItems.map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
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
    return Container(
      height: 60.fSize,
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
              value: widget.model.selectedYearValue,
              hint: widget.model.yearItems.isNotEmpty
                  ? const Text('Select Year')
                  : const Text('-'),
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
            ),
            const SizedBox(width: 8),
          ],
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
