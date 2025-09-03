import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({Key? key}) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  final OwnerProfileVM model = OwnerProfileVM();
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = model.fetchData();
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

    return FutureBuilder<void>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState != ConnectionState.done;
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
                    model.users.isNotEmpty
                        ? _buildData(
                            data: model.users.first.ownerFullName ?? '')
                        : const Text('Loading...'),
                  ],
                ),
                Row(
                  children: [
                    _buildRow(
                        icon: 'personal_info_contact.png',
                        label: 'Contact No.'),
                    SizedBox(width: responsiveWidth(8)),
                    model.users.isNotEmpty
                        ? _buildData(data: model.users.first.ownerContact ?? '')
                        : const Text('Loading...'),
                  ],
                ),
                Row(
                  children: [
                    _buildRow(icon: 'personal_info_email.png', label: 'Email'),
                    SizedBox(width: responsiveWidth(8)),
                    model.users.isNotEmpty
                        ? _buildData(data: model.users.first.email ?? '')
                        : const Text('Loading...'),
                  ],
                ),
                Row(
                  children: [
                    _buildRow(
                        icon: 'personal_info_address.png', label: 'Address'),
                    SizedBox(width: responsiveWidth(8)),
                    model.users.isNotEmpty
                        ? _buildData(data: model.users.first.ownerAddress ?? '')
                        : const Text('Loading...'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
