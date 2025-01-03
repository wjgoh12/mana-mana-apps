import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/total_bymonth_single_type_unit.dart';
import 'package:mana_mana_app/provider/global_owner_state.dart';
import 'package:mana_mana_app/provider/global_unitByMonth_state.dart';
import 'package:mana_mana_app/repository/property_list.dart';
import 'package:mana_mana_app/screens/Dashboard/View/statistic_dashboard.dart';
import 'package:mana_mana_app/screens/PropertyDetail/propertyDetailVM.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/overall_revenue_container.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/widgets/property_stack.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class propertyDetailScreen extends StatefulWidget {
  List<Map<String, dynamic>> locationByMonth;
  propertyDetailScreen(this.locationByMonth, {super.key});

  @override
  State<propertyDetailScreen> createState() =>
      _PersonalMillerzSquare1ScreenState();
}

class _PersonalMillerzSquare1ScreenState extends State<propertyDetailScreen> {
  final PropertyListRepository ownerPropertyList_repository =
      PropertyListRepository();
  bool isClicked = false;
  // List.generate(4, (index) => (DateTime.now().month - index).toString());
  String? selectedValue;
  String? selectedYearValue;
  // = DateTime.now().year.toString();
  String? selectedMonthValue = '';
  // selectedMonthValue = personalMillerzSquareVM().monthItems.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b);
  String? selectedType;
  List<singleUnitByMonth> unitByMonth = [];
  String? selectedUnitNo;
  var selectedUnitBlc;
  var selectedUnitPro;
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  void toggleIsClicked() {
    setState(() {
      isClicked = !isClicked;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String property = widget.locationByMonth[0]['location'];
      unitByMonth = await ownerPropertyList_repository.getUnitByMonth();
      if (unitByMonth.isNotEmpty) {
        GlobalUnitByMonthState.instance.setUnitByMonthData(unitByMonth);
        selectedMonthValue = propertyDetailVM().monthItems.isNotEmpty
            ? propertyDetailVM()
                .monthItems
                .reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
            : '';
        selectedYearValue = propertyDetailVM().yearItems.isNotEmpty
            ? propertyDetailVM()
                .yearItems
                .reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)
            : '';
      }

      _initializeData(property);
    });
  }

  void _initializeData(property) {
    List<OwnerPropertyList> ownerData =
        GlobalOwnerState.instance.getOwnerData();
    // List<String> typeItems = ownerData
    // .where((types) => types.location == property)
    // .map((types) => types.type.toString())
    // .toList();
    if (ownerData.isNotEmpty) {
      setState(() {
        selectedType = ownerData
            .firstWhere((data) => data.location == property,
                orElse: () => OwnerPropertyList(type: '', unitno: ''))
            .type
            .toString();
        selectedUnitNo = ownerData
            .firstWhere((data) => data.location == property,
                orElse: () => OwnerPropertyList(type: '', unitno: ''))
            .unitno
            .toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: propertyDetailVM(),
        builder: (context, _) {
          final propertyDetailVM model = propertyDetailVM();
          String property = widget.locationByMonth[0]['location'];

          return Scaffold(
            backgroundColor: const Color(0XFFFFFFFF),
            appBar: propertyAppBar(
              context,
              () => Navigator.of(context).pop(),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.width),
                child: Column(
                  children: [
                    SizedBox(height: 2.height),
                    _buildPropertyHeader(property),
                    SizedBox(height: 2.height),
                    // _buildOverallRevenue(),
                    SizedBox(height: 2.height),
                    _buildTypeAndUnitSelection(property),
                    SizedBox(height: 2.height),
                    _buildUnitRevenue(property),
                    // SizedBox(height: 1.height),
                    // _buildStatisticsSection(),
                    // SizedBox(height: 5.height),
                    _buildMonthlyStatementSection(),
                    SizedBox(height: 3.height),
                    _buildMonthlyStatementContainer(property),
                    SizedBox(height: 1.height),
                    // _buildAgreementsSection(),
                    SizedBox(height: 3.height),
                    // _buildAgreementContainer(),
                    SizedBox(height: 10.height),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildPropertyHeader(property) {
    String locationRoad = '';
    switch (property.toUpperCase()) {
      case "EXPRESSIONZ":
        locationRoad = "@ Jalan Tun Razak";
        break;
      case "CEYLONZ":
        locationRoad = "@ Persiaran Raja Chulan";
        break;
      case "SCARLETZ":
        locationRoad = "@ Jalan Yap Kwan Seng";
        break;
      case "MILLERZ":
        locationRoad = "@ Old Klang Road";
        break;
      case "MOSSAZ":
        locationRoad = "@ Empire City";
        break;
      case "PAXTONZ":
        locationRoad = "@ Empire City";
        break;
      default:
        locationRoad = "";
        break;
    }
    return propertyStack(
      image: property,
      text1: property,
      text2: locationRoad,
      width: 86.width,
      height: 12.height,
    );
  }

  Widget _buildOverallRevenue() {
    return const OverallRevenueContainer(
      text1: 'Overall Revenue',
      text2: 'RM 9,999.99',
      text3: '100%',
      text4: 'Overall Balance To Owner',
      text5: 'RM 8,888.88',
      text6: '88%',
      color: Color(0XFFFFFFFF),
      backgroundColor: Color(0XFF4313E9),
    );
  }

  Widget _buildTypeAndUnitSelection(property) {
    List<OwnerPropertyList> ownerData =
        GlobalOwnerState.instance.getOwnerData();

    List<String> typeItems = ownerData
        .where((types) => types.location == property)
        .map((types) => '${types.type} (${types.unitno})')
        .toList();

    // List<String> typeItems = ownerData
    //     .where((types) => types.location == property)
    //     .map((types) => types.type.toString())
    //     .toList();
    if (typeItems.isNotEmpty) {
      selectedType =
          selectedType == '' ? typeItems.first.split(" (")[0] : selectedType;
      selectedUnitNo = selectedUnitNo == ''
          ? typeItems.first.split(" (")[1].replaceAll(")", "")
          : selectedUnitNo;
      // selectedType =
      //     selectedType == '' ? typeItems.first.split(" ")[0] : selectedType;
      // selectedUnitNo =
      //     selectedUnitNo == '' ? typeItems.first.split(" ")[1] : selectedUnitNo;
    }
    // List<String> unitNoItems = ownerData
    //     .where((types) => types.location == property)
    //     .map((types) => types.unitno.toString())
    //     .toList();
    // selectedUnitNo = selectedUnitNo == '' ? unitNoItems.first : selectedUnitNo;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildGradientText('Unit No'),
        SizedBox(width: 3.width),
        NewDropdownButton(
          label: 'Unit No',
          list: typeItems,
          onChanged: (_) {
            setState(() {
              selectedType = _?.split(" (")[0];
              selectedUnitNo = _?.split(" (")[1].replaceAll(")", "");
            });
          },
        ),
        // const Spacer(),
        // _buildGradientText('Unit'),
        // SizedBox(width: 1.width),
        // NewDropdownButton(
        //   list: unitNoItems,
        //   onChanged: (_) {
        //     List<singleUnitByMonth> _singleUnitByMonth =
        //         GlobalUnitByMonthState.instance.getUnitByMonthData();

        //     setState(() {
        //       selectedUnitNo = _;
        //       var now = DateTime.now();
        //       selectedUnit = _singleUnitByMonth.firstWhere(
        //         (unit) =>
        //             unit.slocation == property &&
        //             unit.stype == selectedType &&
        //             unit.sunitno == selectedUnitNo &&
        //             unit.imonth == now.month &&
        //             unit.iyear == now.year,
        //         orElse: () => _singleUnitByMonth.firstWhere(
        //           (unit) =>
        //               unit.slocation == property &&
        //               unit.stype == selectedType &&
        //               unit.sunitno == selectedUnitNo,
        //           orElse: () => singleUnitByMonth(total: 0.00),
        //         ),
        //       );
        //     });
        //   },
        // ),
      ],
    );
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

  Widget _buildUnitRevenue(property) {
    List<singleUnitByMonth> _singleUnitByMonth =
        GlobalUnitByMonthState.instance.getUnitByMonthData();

    int unitLatestMonth = 0;
    int unitLatestYear = 0;
    var now = DateTime.now();
    // unitLatestMonth = _singleUnitByMonth
    //     .where((unit) => unit.iyear == now.year)
    //     .map((unit) => unit.imonth ?? 0)
    //     .reduce((value, element) => value > element ? value : element);

    print('All _singleUnitByMonth:');
    for (var unit in _singleUnitByMonth) {
      print(
          'Location: ${unit.slocation}, Type: ${unit.stype}, Unit No: ${unit.sunitno}, Month: ${unit.imonth}, Year: ${unit.iyear}, Total: ${unit.total}');
    }

    var filteredYears = _singleUnitByMonth
        .where((unit) =>
            unit.slocation == property &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo)
        .map((unit) => unit.iyear ?? 0)
        .toList();
    if (filteredYears.isNotEmpty) {
      unitLatestYear = filteredYears
          .reduce((value, element) => value > element ? value : element);
    } else {
      unitLatestYear = 0;
    }
    var filteredMonths = _singleUnitByMonth
        .where((unit) =>
            unit.slocation == property &&
            unit.stype == selectedType &&
            unit.sunitno == selectedUnitNo &&
            unit.iyear == unitLatestYear)
        .map((unit) => unit.imonth ?? 0)
        .toList();

    if (filteredMonths.isNotEmpty) {
      unitLatestMonth = filteredMonths
          .reduce((value, element) => value > element ? value : element);
    } else {
      unitLatestMonth = 0; // or handle accordingly
    }

    return ListenableBuilder(
        listenable: propertyDetailVM(),
        builder: (context, _) {
          var now = DateTime.now();
          selectedUnitBlc = _singleUnitByMonth.firstWhere(
              (unit) =>
                  unit.slocation == property &&
                  unit.stype == selectedType &&
                  unit.sunitno == selectedUnitNo &&
                  unit.imonth == unitLatestMonth &&
                  unit.iyear == unitLatestYear &&
                  unit.stranscode == 'OWNBAL',
              orElse: () => singleUnitByMonth(total: 0.00));
          selectedUnitPro = _singleUnitByMonth.firstWhere(
              (unit) =>
                  unit.slocation == property &&
                  unit.stype == selectedType &&
                  unit.sunitno == selectedUnitNo &&
                  unit.imonth == unitLatestMonth &&
                  unit.iyear == unitLatestYear &&
                  unit.stranscode == 'NOPROF',
              orElse: () => singleUnitByMonth(total: 0.00));

          return OverallRevenueContainer(
            text1: 'Monthly Profit',
            text2:
                'RM ${selectedUnitPro.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0.00'}',
            // text2: 'RM ${selectedUnitPro.total?.toStringAsFixed(2) ?? '0.00'}',
            text3: '${_getMonthName(unitLatestMonth)} ${unitLatestYear}',
            text4: 'Net After POB​',
            text5:
                'RM ${selectedUnitBlc.total?.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '0.00'}',
            // text5: 'RM ${selectedUnitBlc.total?.toStringAsFixed(2) ?? '0.00'}',
            text6: '${_getMonthName(unitLatestMonth)} ${unitLatestYear}',
            color: const Color(0XFF4313E9),
            backgroundColor: const Color(0XFFFFFFFF),
          );
        });
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 20.fSize,
            fontWeight: FontWeight.w800,
            color: const Color(0XFF4313E9),
          ),
        ),
        SizedBox(height: 1.height),
        const StatisticTable(),
      ],
    );
  }

  Widget _buildMonthlyStatementSection() {
    return Row(
      children: [
        Text(
          'Monthly Statement',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 20.fSize,
            fontWeight: FontWeight.w800,
            color: const Color(0XFF4313E9),
          ),
        ),
        const Spacer(),
        // IconButton(
        //   onPressed: () => Navigator.of(context)
        //       .push(MaterialPageRoute(builder: (_) => const StatementPage())),
        //   iconSize: 4.height,
        //   icon: const Icon(Icons.arrow_right_rounded),
        // ),
        Image.asset(
          'assets/images/patterns.png',
          width: 12.width,
          height: 10.height,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildMonthlyStatementContainer(property) {
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
            _buildYearMonthSelection(),
            SizedBox(height: 4.height),
            _buttonDownloadPdf(property),
            // _buildMonthlyStatementContent(),
          ],
        ),
      ),
    );
  }

  Widget _buttonDownloadPdf(property) {
    return ElevatedButton(
      onPressed: () async {
        print(property);
        print(selectedYearValue);
        print(selectedMonthValue);
        print(selectedType);
        print(selectedUnitNo);
        await ownerPropertyList_repository.downloadPdfStatement(
            context,
            property,
            selectedYearValue,
            selectedMonthValue,
            selectedType,
            selectedUnitNo);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0XFF4313E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 8.width, vertical: 0.5.height),
        child: Text(
          'Download PDF',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.fSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildYearMonthSelection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (propertyDetailVM().isLoading) {
          // Check if data is still loading
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(), // Display a loading spinner
            ),
          );
        }
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildSelectionItem('Year', propertyDetailVM().yearItems),
            _buildSelectionItem('Month', propertyDetailVM().monthItems),
          ],
        );
      },
    );
  }

  Widget _buildSelectionItem(String label, List<String> items) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGradientText(label),
        SizedBox(width: 2.width),
        NewDropdownButton(
          label: label,
          list: items,
          onChanged: (_) {
            setState(() {
              if (label == 'Year') {
                selectedYearValue = _;
              } else if (label == 'Month') {
                selectedMonthValue = _;
                print(selectedMonthValue);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildMonthlyStatementContent() {
    return Column(
      children: [
        _buildMonthRow(),
        if (isClicked) _buildClickedContent(),
        _buildDivider(),
        _monthlyStatementRow(
            '01 - 31 March', Icons.keyboard_arrow_down_outlined),
        _buildDivider(),
        _monthlyStatementRow(
            '01 - 29 February', Icons.keyboard_arrow_down_outlined),
        _buildDivider(),
        _monthlyStatementRow(
            '01 - 31 January', Icons.keyboard_arrow_down_outlined),
      ],
    );
  }

  Widget _buildMonthRow() {
    return Row(
      children: [
        Text(
          '01 - 30 April',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w600,
            fontSize: 15.fSize,
            color: const Color(0XFF888888),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: toggleIsClicked,
          child: Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 4.height,
            color: const Color(0XFF4313E9),
          ),
        ),
      ],
    );
  }

  Widget _buildClickedContent() {
    return Row(
      children: [
        Text(
          'SCARLETZ - 11-03 - APR2024',
          style: TextStyle(
            color: const Color(0XFF0044CC).withOpacity(0.8),
            fontFamily: 'Open Sans',
            fontSize: 15.fSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          'PDF',
          style: TextStyle(
            color: const Color(0XFF0044CC).withOpacity(0.8),
            fontFamily: 'Open Sans',
            fontSize: 15.fSize,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: const Color(0XFF0044CC).withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0XFF888888),
      thickness: 0.5.fSize,
    );
  }

  Widget _buildAgreementsSection() {
    return Row(
      children: [
        Text(
          'Agreement(s)',
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 20.fSize,
            fontWeight: FontWeight.w800,
            color: const Color(0XFF4313E9),
          ),
        ),
        const Spacer(),
        Image.asset(
          'assets/images/patterns.png',
          width: 12.width,
          height: 10.height,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildAgreementContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.width),
      width: 86.width,
      height: 6.height,
      decoration: BoxDecoration(
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: const Color(0XFF120051).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
            spreadRadius: -1.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'SCARLETZ - 11-03 - APR2024',
            style: TextStyle(
              color: const Color(0XFF0044CC).withOpacity(0.8),
              fontFamily: 'Open Sans',
              fontSize: 15.fSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'PDF',
            style: TextStyle(
              color: const Color(0XFF0044CC).withOpacity(0.8),
              fontFamily: 'Open Sans',
              fontSize: 15.fSize,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: const Color(0XFF0044CC).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthlyStatementRow(String text, IconData icon) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w600,
            fontSize: 15.fSize,
            color: const Color(0XFF888888),
          ),
        ),
        const Spacer(),
        Icon(
          icon,
          size: 4.height,
          color: const Color(0XFF4313E9),
        ),
      ],
    );
  }
}

//scrollable chart container
// Widget _chartContainer() {
//   return Container(
//     width: 90.width,
//     height: 30.height,
//     decoration: BoxDecoration(
//       color: const Color(0XFFFFFFFF),
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: const Color(0XFF120051).withOpacity(0.1),
//           blurRadius: 6,
//           offset: const Offset(0, 3),
//           spreadRadius: -1.0,
//         ),
//       ],
//     ),
//     child: SingleChildScrollView(
//       child: Column(
//         children: [
//           Padding(
//             padding:
//                 EdgeInsets.only(top: 2.height, left: 6.width, right: 5.width),
//             child: Row(
//               children: [
//                 Text(
//                   'Monthly Overall Earnings',
//                   style: TextStyle(
//                     fontFamily: 'Open Sans',
//                     fontSize: 8.fSize,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0XFF4313E9),
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   width: 2.width,
//                   height: 2.width,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: gradientColor1,
//                   ),
//                 ),
//                 SizedBox(width: 1.width),
//                 Text(
//                   'Overall Revenue',
//                   style: TextStyle(
//                     fontFamily: 'Open Sans',
//                     fontSize: 8.fSize,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0XFF888888),
//                   ),
//                 ),
//                 SizedBox(width: 2.width),
//                 Container(
//                   width: 2.width,
//                   height: 2.width,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: gradientColor2,
//                   ),
//                 ),
//                 SizedBox(width: 1.width),
//                 Text(
//                   'Overall Revenue',
//                   style: TextStyle(
//                     fontFamily: 'Open Sans',
//                     fontSize: 8.fSize,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0XFF888888),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Align(
//             alignment: const Alignment(-0.8, 0),
//             child: Text(
//               '(Ringgit in thousands)',
//               style: TextStyle(
//                 fontFamily: 'Open Sans',
//                 fontSize: 6.fSize,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0XFF4313E9),
//               ),
//             ),
//           ),
//           BarChartSample7(),
//           Padding(
//             padding:
//                 EdgeInsets.only(left: 6.width, right: 5.width, top: 1.height),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     SizedBox(width: 20.width),
//                     SizedBox(width: 5.width),
//                     SizedBox(
//                       width: 25.width,
//                       child: Text(
//                         'Monthly Revenue',
//                         style: TextStyle(
//                           color: const Color(0XFF888888),
//                           fontSize: 8.fSize,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Open Sans',
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     SizedBox(
//                       width: 25.width,
//                       child: Text(
//                         'Monthly Rental Income',
//                         style: TextStyle(
//                           color: const Color(0XFF888888),
//                           fontSize: 8.fSize,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Open Sans',
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 1.height),
//                 revenueChartRow('April 2024', 'RM 0', 'RM 0'),
//                 SizedBox(height: 0.5.height),
//                 Divider(
//                   color: Color(0XFF888888),
//                   thickness: 0.5.fSize,
//                 ),
//                 SizedBox(height: 0.5.height),
//                 revenueChartRow('Mar 2024', 'RM 4,562.40', 'RM 4,562.40'),
//                 SizedBox(height: 0.5.height),
//                 Divider(
//                   color: Color(0XFF888888),
//                   thickness: 0.5.fSize,
//                 ),
//                 SizedBox(height: 0.5.height),
//                 revenueChartRow('Feb 2024', 'RM 100,562.40', 'RM 100,562.40'),
//                 SizedBox(height: 0.5.height),
//                 Divider(
//                   color: Color(0XFF888888),
//                   thickness: 0.5.fSize,
//                 ),
//                 SizedBox(height: 0.5.height),
//                 revenueChartRow('Jan 2024', 'RM 60,562.40', 'RM 60,562.40'),
//                 SizedBox(height: 3.height),
//               ],
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

class NewDropdownButton extends StatefulWidget {
  const NewDropdownButton(
      {super.key,
      required this.list,
      required this.onChanged,
      required this.label});
  final List<String> list;
  final Function(String?) onChanged;
  final String label;

  @override
  State<NewDropdownButton> createState() => _NewDropdownButtonState();
}

class _NewDropdownButtonState extends State<NewDropdownButton> {
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();
  String _getMonthName(String month) {
    switch (month) {
      case '1':
        return 'Jan';
      case '2':
        return 'Feb';
      case '3':
        return 'Mar';
      case '4':
        return 'Apr';
      case '5':
        return 'May';
      case '6':
        return 'Jun';
      case '7':
        return 'Jul';
      case '8':
        return 'Aug';
      case '9':
        return 'Sep';
      case '10':
        return 'Oct';
      case '11':
        return 'Nov';
      case '12':
        return 'Dec';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate max width based on longest text
    double maxTextWidth = widget.list.fold(0.0, (maxWidth, item) {
      final textSpan = TextSpan(
        text: widget.label == "Month" ? _getMonthName(item) : item,
        style: TextStyle(
          fontSize: 15.fSize,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      return max(maxWidth, textPainter.width);
    });

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          widget.label == "Month"
              ? _getMonthName(widget.list.first)
              : widget.list.first,
          style: TextStyle(
            color: const Color(0XFF4313E9),
            fontFamily: 'Open Sans',
            fontSize: 14.fSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        items: widget.list
            .map(
              (String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  widget.label == "Month" ? _getMonthName(item) : item,
                  style: TextStyle(
                    color: const Color(0XFF4313E9),
                    fontFamily: 'Open Sans',
                    fontSize: 14.fSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
        value: selectedValue,
        onChanged: (String? value) {
          setState(() {
            selectedValue = value;
          });
          widget.onChanged(value);
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0XFFFFFFFF),
            border: Border.all(color: const Color(0XFF999999)),
            borderRadius: BorderRadius.circular(5),
          ),
          width: maxTextWidth + 40, // Add padding for icon and margins
          height: (3.5).height,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: maxTextWidth + 40,
        ),
        iconStyleData: IconStyleData(
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          iconSize: 2.height,
          iconEnabledColor: const Color(0XFF4313E9),
          iconDisabledColor: const Color(0XFF4313E9),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 3.height,
        ),
      ),
    );
  }
}
