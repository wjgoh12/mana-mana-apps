// import 'package:mana_mana_app/core/constants/app_dimens.dart';
// import 'package:flutter/material.dart';
// import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
// import 'package:mana_mana_app/screens/profile/view/owner_profile_view.dart';
// import 'package:mana_mana_app/screens/settings/view_model/setting_page_view_model.dart';
// import 'package:mana_mana_app/core/utils/size_utils.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SettingPage extends StatelessWidget {
//   const SettingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final SettingPageVM model = SettingPageVM();
//     model.fetchData();
//     return ListenableBuilder(
//         listenable: model,
//         builder: (context, child) {
//           return Scaffold(
//             appBar: AppBar(
//               leadingWidth: 15.width,
//               centerTitle: true,
//               leading: Padding(
//                 padding: EdgeInsets.only(left: 7.width),
//                 child: InkWell(
//                     onTap: () => Navigator.pop(context),
//                     child: Image.asset(
//                       'assets/images/return.png',
//                     )),
//               ),
//               title: Text(
//                 'Settings',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   foreground: Paint()
//                     ..shader = const LinearGradient(
//                       colors: [Color(0xFF2900B7), Color(0xFF120051)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0)),
//                 ),
//               ),
//               // centerTitle: true,
//               //     leading: Padding(
//               //   padding: EdgeInsets.only(left: 7.width),
//               //   child: InkWell(
//               //       onTap: () => Navigator.pop(context),
//               //       child: Image.asset(
//               //         'assets/images/return.png',
//               //       )),
//               // ),
//             ),
//             body: Padding(
//               padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Profile Section
//                   Row(
//                     children: [
//                       Image.asset(
//                         'assets/images/dashboard_gem.png',
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                       ),
//                       const SizedBox(width: 20),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             model.users.isNotEmpty
//                                 ? model.users.first.ownerFullName ?? '-'
//                                 : '-',
//                             style: const TextStyle(
//                                 fontSize: AppDimens.fontSizeBig,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0XFF4313E9)),
//                           ),
//                           const Text(
//                             'Property Owner',
//                             style: TextStyle(
//                                 color: Color(0xFF555555),
//                                 fontWeight: FontWeight.w300),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       // Column(
//                       //   children: [
//                       //     Text('View Details', style: TextStyle(color: Colors.blue)),
//                       //     IconButton(
//                       //       icon: Icon(Icons.arrow_forward),
//                       //       onPressed: () {
//                       //         // Handle view details action
//                       //       },
//                       //     ),
//                       //   ],
//                       // ),
//                     ],
//                   ),
//                   const SizedBox(height: 32),

//                   // My Earnings Section
//                   // Text(
//                   //   'My Earnings',
//                   //   style: TextStyle(
//                   //       fontSize: AppDimens.fontSizeBig,
//                   //       fontWeight: FontWeight.bold,
//                   //       color: Color(0XFF4313E9)),
//                   // ),
//                   // SizedBox(height: 8),
//                   // Card(
//                   //   child: ListTile(
//                   //     leading: Icon(Icons.insert_chart),
//                   //     title: Text('Statements',
//                   //         style: TextStyle(color: Color(0XFF4313E9))),
//                   //     trailing: Icon(Icons.arrow_forward),
//                   //     onTap: () {
//                   //       // Handle Statements tap
//                   //     },
//                   //   ),
//                   // ),
//                   // Card(
//                   //   child: ListTile(
//                   //     leading: Icon(Icons.show_chart),
//                   //     title: Text('Occupancy Figures',
//                   //         style: TextStyle(color: Color(0XFF4313E9))),
//                   //     trailing: Icon(Icons.arrow_forward),
//                   //     onTap: () {
//                   //       // Handle Occupancy Figures tap
//                   //     },
//                   //   ),
//                   // ),
//                   // Card(
//                   //   child: ListTile(
//                   //     leading: Icon(Icons.calculate),
//                   //     title: Text('Estimate ROI Returns',
//                   //         style: TextStyle(color: Color(0XFF4313E9))),
//                   //     trailing: Icon(Icons.arrow_forward),
//                   //     onTap: () {
//                   //       // Handle Estimate ROI Returns tap
//                   //     },
//                   //   ),
//                   // ),
//                   // SizedBox(height: 32),

//                   // My Profile Section
//                   const Text(
//                     'My Profile',
//                     style: TextStyle(
//                         fontSize: AppDimens.fontSizeBig,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF4313E9)),
//                   ),
//                   const SizedBox(height: 8),
//                   Card(
//                     color: Colors.white,
//                     child: ListTile(
//                       leading: Image.asset('assets/images/profileIcon.png'),
//                       title: const Text('Personal and Financial Details',
//                           style: TextStyle(
//                               color: Color(0XFF4313E9),
//                               fontWeight: FontWeight.w700)),
//                       trailing: const CircularArrowButton(),
//                       onTap: () {
//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (_) => const OwnerProfile()));
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   const Text(
//                     'Contact Us',
//                     style: TextStyle(
//                         fontSize: AppDimens.fontSizeBig,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF4313E9)),
//                   ),
//                   const SizedBox(height: 8),
//                   Card(
//                     color: Colors.white,
//                     child: Column(
//                       children: [
//                         ListTile(
//                           leading: SizedBox(
//                             width: 35,
//                             height: 35,
//                             child: Image.asset('assets/images/emailIcon.png',
//                                 fit: BoxFit.contain),
//                           ),
//                           title: const Text('Email',
//                               style: TextStyle(
//                                   color: Color(0XFF4313E9),
//                                   fontWeight: FontWeight.w700)),
//                           trailing: const CircularArrowButton(),
//                           onTap: () {
//                             final Uri emailLaunchUri = Uri(
//                               scheme: 'mailto',
//                               path: 'admin@manamanasuites.com',
//                             );
//                             launchUrl(emailLaunchUri);
//                           },
//                         ),
//                         ListTile(
//                           leading: SizedBox(
//                             width: 35,
//                             height: 35,
//                             child: Image.asset('assets/images/dialerIcon.png',
//                                 fit: BoxFit.contain),
//                           ),
//                           title: const Text('Telephone',
//                               style: TextStyle(
//                                   color: Color(0XFF4313E9),
//                                   fontWeight: FontWeight.w700)),
//                           trailing: const CircularArrowButton(),
//                           onTap: () {
//                             launchUrl(Uri.parse('tel:+60327795035'));
//                           },
//                         ),
//                         ListTile(
//                           leading: SizedBox(
//                             width: 35,
//                             height: 35,
//                             child: Image.asset('assets/images/whatsappIcon.png',
//                                 fit: BoxFit.contain),
//                           ),
//                           title: const Text('WhatsApp',
//                               style: TextStyle(
//                                   color: Color(0XFF4313E9),
//                                   fontWeight: FontWeight.w700)),
//                           trailing: const CircularArrowButton(),
//                           onTap: () {
//                             launchUrl(Uri.parse('https://wa.me/60125626784'));
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Card(
//                   //   child: ListTile(
//                   //     leading: Icon(Icons.help),
//                   //     title: Text('Helpdesk',
//                   //         style: TextStyle(color: Color(0XFF4313E9))),
//                   //     trailing: Icon(Icons.arrow_forward),
//                   //     onTap: () {
//                   //       // Handle Helpdesk tap
//                   //     },
//                   //   ),
//                   // ),
//                   // Card(
//                   //   child: ListTile(
//                   //     leading: Icon(Icons.lock),
//                   //     title: Text('Reset Password',
//                   //         style: TextStyle(color: Color(0XFF4313E9))),
//                   //     trailing: Icon(Icons.arrow_forward),
//                   //     onTap: () {
//                   //       // Handle Reset Password tap
//                   //     },
//                   //   ),
//                   // ),
//                   const Spacer(),
//                   Center(
//                     child: TextButton(
//                       onPressed: () async {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: const Text('Confirm Logout'),
//                               content: const Text(
//                                   'Are you sure you want to log out?'),
//                               actions: <Widget>[
//                                 TextButton(
//                                   child: const Text('Cancel'),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                                 TextButton(
//                                   child: const Text('Logout'),
//                                   onPressed: () async {
//                                     await AuthService().logout(context);
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       child: const Text(
//                         'Log Out',
//                         style:
//                             TextStyle(color: Color(0XFF4313E9), fontSize: AppDimens.fontSizeBig),
//                       ),
//                     ),
//                   ),
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           TextButton(
//                             onPressed: () {
//                               launchUrl(Uri.parse(
//                                   'https://www.manamanasuites.com/terms-conditions'));
//                             },
//                             child: const Text(
//                               'Terms & Conditions',
//                               style: TextStyle(
//                                   color: Color(0XFF4313E9),
//                                   fontSize: AppDimens.fontSizeBig,
//                                   decoration: TextDecoration.underline),
//                             ),
//                           ),
//                           const Text(
//                             ' | ',
//                             style: TextStyle(
//                                 color: Color(0XFF4313E9), fontSize: AppDimens.fontSizeBig),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               launchUrl(Uri.parse(
//                                   'https://www.manamanasuites.com/privacy-policy'));
//                             },
//                             child: const Text(
//                               'Privacy Policy',
//                               style: TextStyle(
//                                   color: Color(0XFF4313E9),
//                                   fontSize: AppDimens.fontSizeBig,
//                                   decoration: TextDecoration.underline),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
// }

// class CircularArrowButton extends StatelessWidget {
//   const CircularArrowButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.25),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: const CircleAvatar(
//         backgroundColor: Colors.white,
//         child: Icon(Icons.arrow_forward, color: Color(0XFF4313E9)),
//       ),
//     );
//   }
// }
