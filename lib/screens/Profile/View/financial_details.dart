import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/responsive.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:provider/provider.dart';

class FinancialDetails extends StatefulWidget {
  const FinancialDetails({super.key});

  @override
  State<FinancialDetails> createState() => _FinancialDetailsState();
}

class _FinancialDetailsState extends State<FinancialDetails> {
  final OwnerProfileVM model = OwnerProfileVM();

  @override
  void initState() {
    super.initState();
    // Initialize data once - it will use cached data if already loaded
    model.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);

    return MultiProvider(
      providers: [
        // Provide the global data manager
        ChangeNotifierProvider.value(value: GlobalDataManager()),
        // Provide the profile view model
        ChangeNotifierProvider.value(value: model),
      ],
      child: Consumer<OwnerProfileVM>(
        builder: (context, profileModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Image.asset('assets/images/personal_info_back.png'),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Financial Details',
                style: TextStyle(
                  fontFamily: 'outfit',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveSize.text(20),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: Colors.grey.shade300,
                  height: 1.0,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoRow(
                        icon: 'financial_details_bank.png',
                        label: 'Bank',
                      ),
                      _buildData(value: profileModel.getBankInfo()),
                    ],
                  ),
                  Row(
                    children: [
                      _buildInfoRow(
                        icon: 'financial_details_acc_no.png',
                        label: 'Account No.',
                      ),
                      _buildData(value: profileModel.getAccountNumber()),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String label,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height
    double responsiveFont(double value) =>
        (value / 812.0) * screenHeight; // font scaling

    return SizedBox(
      width: responsiveWidth(160),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Image.asset('assets/images/$icon'),
            SizedBox(width: responsiveWidth(10)),
            Text('$label ',
                style: TextStyle(
                    fontFamily: 'outfit',
                    fontSize: responsiveFont(16),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

Widget _buildData({required String value}) {
  return Container(
    width: 180,
    child: Text(
      value ?? 'Not available',
      maxLines: 2,
      style: TextStyle(
          fontFamily: 'outfit',
          fontSize: ResponsiveSize.text(15),
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    ),
  );
}
