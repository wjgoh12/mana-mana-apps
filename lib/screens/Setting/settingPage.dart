import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';
import 'package:mana_mana_app/screens/Profile/OwnerProfileScreen.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<User> users = GlobalUserState.instance.getUsers();
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [Color(0xFF2900B7), Color(0xFF120051)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 100.0)),
            ),
          ),
        centerTitle: true,
        leading: Padding(
      padding: EdgeInsets.only(left: 7.width),
      child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
            'assets/images/return.png',
          )),
    ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30 , left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                Image.asset(
                  'assets/images/dashboard_gem.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 20),
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
                      style: TextStyle(color: Color(0xFF555555), fontWeight: FontWeight.w300),                    ),
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
            // Text(
            //   'My Earnings',
            //   style: TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       color: Color(0XFF4313E9)),
            // ),
            // SizedBox(height: 8),
            // Card(
            //   child: ListTile(
            //     leading: Icon(Icons.insert_chart),
            //     title: Text('Statements',
            //         style: TextStyle(color: Color(0XFF4313E9))),
            //     trailing: Icon(Icons.arrow_forward),
            //     onTap: () {
            //       // Handle Statements tap
            //     },
            //   ),
            // ),
            // Card(
            //   child: ListTile(
            //     leading: Icon(Icons.show_chart),
            //     title: Text('Occupancy Figures',
            //         style: TextStyle(color: Color(0XFF4313E9))),
            //     trailing: Icon(Icons.arrow_forward),
            //     onTap: () {
            //       // Handle Occupancy Figures tap
            //     },
            //   ),
            // ),
            // Card(
            //   child: ListTile(
            //     leading: Icon(Icons.calculate),
            //     title: Text('Estimate ROI Returns',
            //         style: TextStyle(color: Color(0XFF4313E9))),
            //     trailing: Icon(Icons.arrow_forward),
            //     onTap: () {
            //       // Handle Estimate ROI Returns tap
            //     },
            //   ),
            // ),
            // SizedBox(height: 32),

            // My Profile Section
            Text(
              'My Profile',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4313E9)),            ),
            SizedBox(height: 8),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: Image.asset('assets/images/profileIcon.png'),
                title: Text('Personal and Financial Details',
                    style: TextStyle(color: Color(0XFF4313E9),fontWeight: FontWeight.w700)),
                              trailing: CircularArrowButton(),                     
                              
                    onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const OwnerProfileScreen()));
                },
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Contact Us',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4313E9)),            ),
            SizedBox(height: 8),
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 35,
                      height: 35,
                      child: Image.asset('assets/images/emailIcon.png', fit: BoxFit.contain),
                    ),
                    title: Text('Email',
                        style: TextStyle(color: Color(0XFF4313E9), fontWeight: FontWeight.w700)),
                    trailing: CircularArrowButton(),
                    onTap: () {
                      final Uri _emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'hi@manamanasuites.com',
                      );
                      launchUrl(_emailLaunchUri);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 35,
                      height: 35,
                      child: Image.asset('assets/images/dialerIcon.png', fit: BoxFit.contain),
                    ),
                    title: Text('Telephone',
                        style: TextStyle(color: Color(0XFF4313E9), fontWeight: FontWeight.w700)),
                    trailing: CircularArrowButton(),
                    onTap: () {
                      launchUrl(Uri.parse('tel:+60125508263'));
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 35,
                      height: 35,
                      child: Image.asset('assets/images/whatsappIcon.png', fit: BoxFit.contain),
                    ),
                    title: Text('WhatsApp',
                        style: TextStyle(color: Color(0XFF4313E9), fontWeight: FontWeight.w700)),
                    trailing: CircularArrowButton(),
                    onTap: () {
                      launchUrl(Uri.parse('https://wa.me/60125508263'));
                    },
                  ),
                ],
              ),
            ),
            // Card(
            //   child: ListTile(
            //     leading: Icon(Icons.help),
            //     title: Text('Helpdesk',
            //         style: TextStyle(color: Color(0XFF4313E9))),
            //     trailing: Icon(Icons.arrow_forward),
            //     onTap: () {
            //       // Handle Helpdesk tap
            //     },
            //   ),
            // ),
            // Card(
            //   child: ListTile(
            //     leading: Icon(Icons.lock),
            //     title: Text('Reset Password',
            //         style: TextStyle(color: Color(0XFF4313E9))),
            //     trailing: Icon(Icons.arrow_forward),
            //     onTap: () {
            //       // Handle Reset Password tap
            //     },
            //   ),
            // ),
            Spacer(),
            Center(
              child: TextButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Logout'),
                        content: Text('Are you sure you want to log out?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Logout'),
                            onPressed: () async {
                              await AuthService().logout(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(color: Color(0XFF4313E9), fontSize: 20),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse('https://www.manamanasuites.com/terms-conditions'));
                      },
                      child: const Text(
                        'Terms & Conditions',
                        style: TextStyle(color: Color(0XFF4313E9), fontSize: 16, decoration: TextDecoration.underline),
                      ),
                    ),
                    Text(
                      ' | ',
                      style: TextStyle(color: Color(0XFF4313E9), fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse('https://www.manamanasuites.com/privacy-policy'));
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(color: Color(0XFF4313E9), fontSize: 16, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularArrowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.arrow_forward, color: Color(0XFF4313E9)),
      ),
    );
  }
}
