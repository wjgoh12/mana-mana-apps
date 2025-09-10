import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Property_detail/ViewModel/property_detailVM.dart';
import 'package:mana_mana_app/screens/All_Property/Widget/statement_card.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class EnhancedStatementContainer extends StatefulWidget {
  final PropertyDetailVM model;
  
  const EnhancedStatementContainer({Key? key, required this.model}) : super(key: key);

  @override
  State<EnhancedStatementContainer> createState() => _EnhancedStatementContainerState();
}

class _EnhancedStatementContainerState extends State<EnhancedStatementContainer> {
  String? _lastPrintedValue;

  String monthNumberToName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, child) {
        if (_lastPrintedValue != widget.model.selectedYearValue) {
          _lastPrintedValue = widget.model.selectedYearValue;
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

        // Get filtered items for the selected unit and year
        final allItems = widget.model.unitByMonth;
        final seen = <String>{};
        final filteredItems = allItems.where((item) {
          // Filter by selected property, unit type, unit number, and year
          final isSameProperty = item.slocation == widget.model.selectedProperty;
          final isSameUnitType = item.stype == widget.model.selectedType;
          final isSameUnit = item.sunitno == widget.model.selectedUnitNo;
          final isSameYear = item.iyear != null &&
              item.iyear.toString() == widget.model.selectedYearValue.toString();

          if (!isSameProperty || !isSameUnitType || !isSameUnit || !isSameYear) return false;

          // Remove duplicates
          final key = '${item.slocation}-${item.stype}-${item.sunitno}-${item.imonth}-${item.iyear}';
          if (seen.contains(key)) {
            return false;
          } else {
            seen.add(key);
            return true;
          }
        }).toList();

        if (filteredItems.isEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: ResponsiveSize.scaleWidth(16)),
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

        // Sort by month (descending - most recent first)
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
              final monthName = monthNumberToName(item.imonth ?? 0);
              final statementDate = formatDate(20, item.imonth ?? 1, item.iyear ?? 2024);
              final statementAmount = formatAmount(item.total ?? 0.0);

              return StatementCard(
                month: monthName,
                statementDate: statementDate,
                statementAmount: statementAmount,
                onTap: () {
                  // Download the specific PDF statement
                  widget.model.downloadSpecificPdfStatement(context, item);
                },
              );
            },
          ),
        );
      },
    );
  }
}
