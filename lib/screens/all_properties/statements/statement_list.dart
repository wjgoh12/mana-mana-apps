import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/property_detail/view_model/property_detail_view_model.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'statement_card.dart';
import 'statement_utils.dart';

class StatementList extends StatelessWidget {
  final PropertyDetailVM model;

  const StatementList({Key? key, required this.model}) : super(key: key);

  bool _isStatementAvailable(dynamic item) {
    final currentDate = DateTime.now();
    final statementDate = DateTime(item.iyear ?? 0, item.imonth ?? 0);

    final isOldEnough =
        statementDate.isBefore(DateTime(currentDate.year, currentDate.month));
    final hasAmount = (item.total ?? 0.0) > 0;

    return isOldEnough && hasAmount;
  }

  void _showStatementNotAvailableDialog(
      BuildContext context, String monthName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Statement Not Available'),
          content: Text(
            'The $monthName statement is not yet available for download. '
            'Please check back later or contact support if you believe this is an error.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, child) {
        final currentYear = model.selectedYearValue.toString();
        final currentMonth = model.selectedMonthValue.toString();
        final currentProperty = model.selectedProperty;
        final currentUnit = model.selectedUnitNo;
        final currentType = model.selectedType;

        if (currentProperty == null ||
            currentUnit == null ||
            currentType == null) {
          return const SizedBox.shrink();
        }

        if (model.isDateLoading) {
          return SizedBox(
            height: ResponsiveSize.scaleHeight(200),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final allItems = model.unitByMonth;
        final seen = <String>{};
        final filteredItems = allItems.where((item) {
          final isSameProperty = item.slocation == currentProperty;
          final isSameUnitType = item.stype == currentType;
          final isSameUnit = item.sunitno == currentUnit;
          final isSameYear =
              item.iyear != null && item.iyear.toString() == currentYear;

          bool isSameMonth = true;
          if (currentMonth.isNotEmpty) {
            try {
              final selectedMonthInt = int.parse(currentMonth);
              isSameMonth = item.imonth == selectedMonthInt;
            } catch (e) {
              isSameMonth = true;
            }
          }

          if (!isSameProperty ||
              !isSameUnitType ||
              !isSameUnit ||
              !isSameYear ||
              !isSameMonth) {
            return false;
          }

          final key =
              '${item.slocation}-${item.stype}-${item.sunitno}-${item.imonth}-${item.iyear}';
          if (seen.contains(key)) {
            return false;
          } else {
            seen.add(key);
            return true;
          }
        }).toList();

        if (filteredItems.isEmpty) {
          return Container(
            margin:
                EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(16)),
            height: ResponsiveSize.scaleHeight(200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: ResponsiveSize.scaleHeight(16)),
                  Text(
                    'No statements found for this unit!',
                    style: TextStyle(
                      fontFamily: AppFonts.outfit,
                      fontSize: AppDimens.fontSizeBig,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        filteredItems.sort((a, b) {
          final monthA = a.imonth ?? 0;
          final monthB = b.imonth ?? 0;
          return monthB.compareTo(monthA);
        });

        return Container(
          margin: EdgeInsets.only(
            top: ResponsiveSize.scaleHeight(16),
            bottom: ResponsiveSize.scaleHeight(20),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final monthName =
                  StatementUtils.monthNumberToName(item.imonth ?? 0);
              final statementDate = StatementUtils.formatDate(
                  20, item.imonth ?? 1, item.iyear ?? 2024);
              final statementAmount =
                  StatementUtils.formatAmount(item.total ?? 0.0);
              final isAvailable = _isStatementAvailable(item);

              return Opacity(
                opacity: isAvailable ? 1.0 : 0.6,
                child: StatementCard(
                  month: monthName,
                  statementDate: statementDate,
                  statementAmount: statementAmount,
                  onTap: () {
                    if (!isAvailable) {
                      _showStatementNotAvailableDialog(context, monthName);
                      return;
                    }
                    model.downloadSpecificPdfStatement(context, item);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
