import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class StatementCard extends StatelessWidget {
  final String month;
  final String statementDate;
  final String statementAmount;
  final VoidCallback onTap;

  const StatementCard({
    Key? key,
    required this.month,
    required this.statementDate,
    required this.statementAmount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveSize.scaleWidth(16),
        vertical: ResponsiveSize.scaleHeight(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          // onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(ResponsiveSize.scaleWidth(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$month Statement',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: ResponsiveSize.text(14),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      statementAmount,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: ResponsiveSize.text(13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveSize.scaleHeight(8)),

                // Statement details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Statement Date:',
                        //   style: TextStyle(
                        //     fontFamily: 'Outfit',
                        //     fontSize: ResponsiveSize.text(11),
                        //     color: Colors.grey[600],
                        //   ),
                        // ),
                        SizedBox(height: ResponsiveSize.scaleHeight(2)),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFC9FFF3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              statementDate,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: ResponsiveSize.text(12),
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF04AA87),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: ResponsiveSize.scaleHeight(32),
                      decoration: BoxDecoration(
                        color: Color(0xFF12C9A2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextButton(
                        onPressed: onTap,
                        child: Row(
                          children: [
                            Text(
                              'Statement',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: ResponsiveSize.text(12),
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: ResponsiveSize.scaleWidth(4)),
                            Image.asset(
                              'assets/images/statement_download.png',
                              width: ResponsiveSize.scaleWidth(16),
                              height: ResponsiveSize.scaleHeight(16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
