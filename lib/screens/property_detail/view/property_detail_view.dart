import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/property_detail/widgets/typeunit_selection.dart';
import 'package:mana_mana_app/screens/property_detail/widgets/typeunit_selection_dropdown.dart';
import 'package:mana_mana_app/screens/property_detail/widgets/unit_revenue.dart';
import 'package:mana_mana_app/screens/property_detail/view_model/property_detail_view_model.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
import 'package:mana_mana_app/widgets/property_app_bar.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

// ignore: must_be_immutable
class PropertyDetail extends StatelessWidget {
  List<Map<String, dynamic>> locationByMonth;
  PropertyDetail({required this.locationByMonth, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PropertyDetailVM model = PropertyDetailVM();
    model.fetchData(locationByMonth);
    return ListenableBuilder(
        listenable: model,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: const Color(0XFFFFFFFF),
            appBar: propertyAppBar(
              context,
              () => Navigator.of(context).pop(),
            ),
            body: model.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 4.0,
                      value: null,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      model.refreshData();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 7.width),
                        child: SizedBox(
                          child: Column(
                            children: [
                              SizedBox(height: 2.height),
                              SizedBox(height: 2.height),
                              TypeUnitSelection(model: model),
                              SizedBox(height: 2.height),
                              UnitRevenue(model: model),
                              _buildTitleSection('Monthly Statement'),
                              SizedBox(height: 1.height),
                              MonthlyStatementContainer(model: model),
                              SizedBox(height: 1.height),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        });
  }
}

Widget _buildTitleSection(String title) {
  return Row(
    children: [
      Text(
        title,
        style: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 20.fSize,
          fontWeight: FontWeight.w800,
          color: const Color(0XFF4313E9),
        ),
      ),
      const Spacer(),

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
        child: SizedBox(
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
                                    ? const CircularProgressIndicator() // Display a loading spinner
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
            ],
          ),
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
            color: const Color(0XFF120051).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
            spreadRadius: -1.0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(6.width, 3.height, 5.width, 2.height),
        child: SizedBox(
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
