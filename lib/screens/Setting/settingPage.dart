import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';
import 'package:mana_mana_app/screens/Dashboard/View/dashboard.dart';
import 'package:mana_mana_app/screens/Profile/OwnerProfileScreen.dart';
import 'package:mana_mana_app/splashscreen.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<User> users = GlobalUserState.instance.getUsers();
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                      'assets/images/dashboard_gem.png'), // Replace with your profile image
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      users.first.ownerFullName ?? '',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF4313E9)),
                    ),
                    Text(
                      'Property Owner',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                // Column(
                //   children: [
                //     Text('View Details', style: TextStyle(color: Colors.blue)),
                //     IconButton(
                //       icon: Icon(Icons.arrow_forward),
                //       onPressed: () {
                //         // Handle view details action
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
            SizedBox(height: 32),

            // My Earnings Section
            Text(
              'My Earnings',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF4313E9)),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.insert_chart),
                title: Text('Statements',
                    style: TextStyle(color: Color(0XFF4313E9))),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle Statements tap
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.show_chart),
                title: Text('Occupancy Figures',
                    style: TextStyle(color: Color(0XFF4313E9))),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle Occupancy Figures tap
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.calculate),
                title: Text('Estimate ROI Returns',
                    style: TextStyle(color: Color(0XFF4313E9))),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle Estimate ROI Returns tap
                },
              ),
            ),
            SizedBox(height: 32),

            // My Profile Section
            Text(
              'My Profile',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF4313E9)),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Personal and Financial Details',
                    style: TextStyle(color: Color(0XFF4313E9))),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const OwnerProfileScreen()));
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.help),
                title: Text('Helpdesk',
                    style: TextStyle(color: Color(0XFF4313E9))),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle Helpdesk tap
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.lock),
                title: Text('Reset Password',
                    style: TextStyle(color: Color(0XFF4313E9))),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Handle Reset Password tap
                },
              ),
            ),
            Spacer(),
            Center(
              child: TextButton(
                onPressed: () async {
                  await AuthService().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => Splashscreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
