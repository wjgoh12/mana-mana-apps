import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/property_detail/view_model/property_detail_view_model.dart';
import 'package:mana_mana_app/screens/all_properties/widgets/statement_card.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class EnhancedStatementContainer extends StatefulWidget {
  final PropertyDetailVM model;

  const EnhancedStatementContainer({Key? key, required this.model})
      : super(key: key);

  @override
  State<EnhancedStatementContainer> createState() =>
      _EnhancedStatementContainerState();
}

class _EnhancedStatementContainerState
    extends State<EnhancedStatementContainer> {
  String? _lastYearValue;
  String? _lastMonthValue;
  String? _lastPropertyValue;
  String? _lastUnitValue;
  String? _lastTypeValue;

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

  String formatDate(int day, int month, int year) {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  String formatAmount(double amount) {
    return 'RM ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  // Check if statement is available for download
  bool _isStatementAvailable(dynamic item) {
    final currentDate = DateTime.now();
    final statementDate = DateTime(item.iyear ?? 0, item.imonth ?? 0);

    // Statement should be available if it's at least 1 month old
    // and the total amount is greater than 0
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
      listenable: widget.model,
      builder: (context, child) {
        final currentYear = widget.model.selectedYearValue.toString();
        final currentMonth = widget.model.selectedMonthValue.toString();
        final currentProperty = widget.model.selectedProperty;
        final currentUnit = widget.model.selectedUnitNo;
        final currentType = widget.model.selectedType;

        // Track changes
        if (_lastYearValue != currentYear ||
            _lastMonthValue != currentMonth ||
            _lastPropertyValue != currentProperty ||
            _lastUnitValue != currentUnit ||
            _lastTypeValue != currentType) {
          print('🔄 Selection changed - StatementContainer updating');
          print('Year: $_lastYearValue -> $currentYear');
          print('Month: $_lastMonthValue -> $currentMonth');
          print('Property: $_lastPropertyValue -> $currentProperty');
          print('Unit: $_lastUnitValue -> $currentUnit');
          print('Type: $_lastTypeValue -> $currentType');

          _lastYearValue = currentYear;
          _lastMonthValue = currentMonth;
          _lastPropertyValue = currentProperty;
          _lastUnitValue = currentUnit;
          _lastTypeValue = currentType;
        }

        // Check if we have valid selections
        if (widget.model.selectedProperty == null ||
            widget.model.selectedUnitNo == null ||
            widget.model.selectedType == null) {
          return const SizedBox.shrink();
        }

        if (widget.model.isDateLoading) {
          return Container(
            height: 200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Get filtered items
        final allItems = widget.model.unitByMonth;

        final seen = <String>{};
        final filteredItems = allItems.where((item) {
          final isSameProperty = item.slocation == currentProperty;
          final isSameUnitType = item.stype == currentType;
          final isSameUnit = item.sunitno == currentUnit;
          final isSameYear =
              item.iyear != null && item.iyear.toString() == currentYear;

          // Filter by month if selected
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

          // Remove duplicates
          final key =
              '${item.slocation}-${item.stype}-${item.sunitno}-${item.imonth}-${item.iyear}';
          if (seen.contains(key)) {
            return false;
          } else {
            seen.add(key);
            return true;
          }
        }).toList();

        // Debug logging
        if (_lastYearValue != currentYear || _lastMonthValue != currentMonth) {
          print('📊 Filtering results:');
          print('Total items: ${allItems.length}');
          print('Filtered items: ${filteredItems.length}');
          print(
              'Filter criteria: Property=$currentProperty, Type=$currentType, Unit=$currentUnit, Year=$currentYear, Month=$currentMonth');

          // ignore: unused_local_variable
          for (var item in filteredItems) {}
        }

        if (filteredItems.isEmpty) {
          return Container(
            margin:
                EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(16)),
            height: 200,
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
                      fontFamily: 'Outfit',
                      fontSize: ResponsiveSize.text(16),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Sort by month (descending)
        filteredItems.sort((a, b) {
          final monthA = a.imonth ?? 0;
          final monthB = b.imonth ?? 0;
          return monthB.compareTo(monthA);
        });

        return Container(
          key: ValueKey(
              '${currentProperty}_${currentType}_${currentUnit}_${currentYear}_${currentMonth}'),
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
              final monthName = monthNumberToName(item.imonth ?? 0);
              final statementDate =
                  formatDate(20, item.imonth ?? 1, item.iyear ?? 2024);
              final statementAmount = formatAmount(item.total ?? 0.0);
              final isAvailable = _isStatementAvailable(item);

              return Opacity(
                opacity: isAvailable ? 1.0 : 0.6,
                child: StatementCard(
                  month: monthName,
                  statementDate: statementDate,
                  statementAmount: statementAmount,
                  onTap: () {
                    print(
                        '🎯 Tapped statement: Month=${item.imonth}, Year=${item.iyear}, Total=${item.total}');

                    if (!isAvailable) {
                      _showStatementNotAvailableDialog(context, monthName);
                      return;
                    }

                    // Download the specific PDF statement
                    widget.model.downloadSpecificPdfStatement(context, item);
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
