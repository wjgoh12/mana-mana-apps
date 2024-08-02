import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/All_Property/View/all_property.dart';
import 'package:mana_mana_app/screens/Dashboard/View/highlights_dashboard.dart';
import 'package:mana_mana_app/screens/Dashboard/View/property_list_dashboard.dart';
import 'package:mana_mana_app/screens/Dashboard/View/revenue_dashboard.dart';
import 'package:mana_mana_app/screens/Dashboard/View/statistic_dashboard.dart';
import 'package:mana_mana_app/screens/personal_millerz_square.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class NewDashboardPage extends StatelessWidget {
  const NewDashboardPage({Key? key}) : super(key: key);

  void navigateToPersonalMillerzSquare(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PersonalMillerzSquare1Screen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBackgroundContainer(),
          Column(
            children: [
              SizedBox(height: 5.height),
              _buildTopBar(context),
            ],
          ),
          Positioned(
            top: 14.height,
            left: 0,
            right: 0,
            bottom: 0,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  // You can add additional logic here if needed
                }
                return true;
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildUserInfo(),
                      SizedBox(height: 2.height),
                      Container(
                        width: 100.width,
                        padding: EdgeInsets.all(7.width),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0XFFFFFFFF), Color(0XFFDFD8FF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            const BuildRevenueContainers(),
                            SizedBox(height: 2.height),
                            _buildSectionTitle('Statistics'),
                            SizedBox(height: 2.height),
                            const StatisticTable(),
                            SizedBox(height: 2.height),
                            _buildSectionTitle('Property(s)'),
                            SizedBox(height: 2.height),
                            const BuildPropertyList(),
                            SizedBox(height: 2.height),
                            _buildSectionTitle('Highlights'),
                            SizedBox(height: 2.height),
                            const BuildHighlights(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBackgroundContainer() {
    return Container(
      alignment: Alignment.topCenter,
      width: 100.width,
      height: 100.height,
      color: const Color(0XFF4313E9),
      padding: EdgeInsets.only(top: 2.height),
      child: Image.asset(
        'assets/images/mana2_patterns.png',
        width: 110.width,
        height: 20.height,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => navigateToPersonalMillerzSquare(context),
          icon: Image.asset(
            'assets/images/dashboard_menu.png',
            width: 6.width,
            height: 3.height,
            fit: BoxFit.contain,
          ),
        ),
        Text(
          'Main Dashboard',
          style: TextStyle(
            fontSize: 20.fSize,
            color: const Color(0xFFC3B9FF),
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(
                  color: Color(0XFFC3B9FF),
                  blurRadius: 0.5,
                  offset: Offset(0.25, 0.5))
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MillerzSquare1Screen())),
          icon: Image.asset(
            'assets/images/notifications.png',
            width: 6.width,
            height: 3.height,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: EdgeInsets.only(left: 10.width),
      child: Row(
        children: [
          Image.asset(
            'assets/images/dashboard_gem.png',
            width: 8.width,
            height: 6.height,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 5.width),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good day!',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 15.fSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Azeem Mohd Fahmi',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 20.fSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 20.fSize,
          fontWeight: FontWeight.w800,
          color: const Color(0XFF4313E9),
        ),
      ),
    );
  }
}
