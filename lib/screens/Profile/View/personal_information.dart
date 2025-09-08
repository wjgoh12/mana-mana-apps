import 'package:flutter/material.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:provider/provider.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({Key? key}) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  final OwnerProfileVM model = OwnerProfileVM();

  @override
  void initState() {
    super.initState();
    // Initialize data once - it will use cached data if already loaded
    model.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height
    double responsiveFont(double value) =>
        (value / 812.0) * screenHeight; // font scaling

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
                'Personal Information',
                style: TextStyle(
                  fontFamily: 'outfit',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFont(20),
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
                      _buildRow(icon: 'personal_info_name.png', label: 'Name'),
                      SizedBox(width: responsiveWidth(8)),
                      _buildData(data: profileModel.getOwnerName()),
                    ],
                  ),
                  Row(
                    children: [
                      _buildRow(
                          icon: 'personal_info_contact.png',
                          label: 'Contact No.'),
                      SizedBox(width: responsiveWidth(8)),
                      _buildData(data: profileModel.getOwnerContact()),
                    ],
                  ),
                  Row(
                    children: [
                      _buildRow(icon: 'personal_info_email.png', label: 'Email'),
                      SizedBox(width: responsiveWidth(8)),
                      _buildData(data: profileModel.getOwnerEmail()),
                    ],
                  ),
                  Row(
                    children: [
                      _buildRow(
                          icon: 'personal_info_address.png', label: 'Address'),
                      SizedBox(width: responsiveWidth(8)),
                      _buildData(data: profileModel.getOwnerAddress()),
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

  Widget _buildRow({required String icon, required String label}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height
    double responsiveFont(double value) =>
        (value / 812.0) * screenHeight; // font scaling

    return SizedBox(
      width: responsiveWidth(140),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/$icon'),
            SizedBox(width: responsiveWidth(10)),
            Text(
              label,
              style:
                  TextStyle(fontFamily: 'outfit', fontSize: responsiveFont(13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildData({required String data}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height
    double responsiveFont(double value) =>
        (value / 812.0) * screenHeight; // font scaling

    return SizedBox(
      width: responsiveWidth(190),
      child: Text(
        data,
        maxLines: 6,
        style: TextStyle(
            fontFamily: 'outfit',
            fontSize: responsiveFont(14),
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
