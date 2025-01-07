// import 'package:flutter/material.dart';
// import 'package:mana_mana_app/screens/Dashboard_old/View/property_list_dashboard.dart';
// import 'package:mana_mana_app/screens/Dashboard_old/View/revenue_dashboard.dart';
// import 'package:mana_mana_app/screens/Dashboard_old/View/statistic_dashboard.dart';
// import 'package:mana_mana_app/screens/Dashboard_old/ViewModel/dashboardVM.dart';
// import 'package:mana_mana_app/screens/Setting/settingPage.dart';
// import 'package:mana_mana_app/widgets/responsive.dart';
// import 'package:mana_mana_app/widgets/size_utils.dart';

// class NewDashboardPage extends StatefulWidget {
//   const NewDashboardPage({Key? key}) : super(key: key);

//   @override
//   NewDashboardPageState createState() => NewDashboardPageState();
// }

// class NewDashboardPageState extends State<NewDashboardPage> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeData();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // if (state == AppLifecycleState.resumed) {
//     //   // Fetch data again when the app is resumed
//     //   _initializeData();
//     // }
//     _initializeData();
//   }

//   void _initializeData() {
//     DashboardVM().fetchUsers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     DashboardVM().userNameAccount = '';

//     return Scaffold(
//       body: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           _buildBackgroundContainer(),
//           AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: _buildTopBar(context),
//             automaticallyImplyLeading: false, // This will remove the back button
//             toolbarHeight: !Responsive.isMobile(context) ? 160 : 50,
//           ),
//           Positioned(
//             top: 14.height,
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: NotificationListener<ScrollNotification>(
//               onNotification: (scrollNotification) {
//                 if (scrollNotification is ScrollUpdateNotification) {
//                   // You can add additional logic here if needed
//                 }
//                 return true;
//               },
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 100.width,
//                         padding: EdgeInsets.all(7.width),
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Color(0XFFFFFFFF), Color(0XFFDFD8FF)],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                         ),
//                         child: Column(
//                           children: [
//                             _buildUserInfo(),
//                             const BuildRevenueContainers(),
//                             SizedBox(height: 2.height),
//                             _buildSectionTitle('Statistics'),
//                             SizedBox(height: 2.height),
//                             const StatisticTable(),
//                             SizedBox(height: 2.height),
//                             _buildSectionTitle('Properties'),
//                             SizedBox(height: 2.height),
//                             const BuildPropertyList(),
//                             SizedBox(height: 2.height),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildBackgroundContainer() {
//     return Container(
//       alignment: Alignment.topCenter,
//       width: 100.width,
//       height: 100.height,
//       color: const Color(0XFF4313E9),
//       padding: EdgeInsets.only(top: 2.height),
//       child: Image.asset(
//         'assets/images/mana2_patterns.png',
//         width: 110.width,
//         height: 20.height,
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   Widget _buildTopBar(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         IconButton(
//           onPressed: () => '',
//           icon: Image.asset(
//             'assets/images/mana2logo.png',
//             width: 10.width,
//             height: 5.height,
//             fit: BoxFit.fill,
//           ),
//         ),
//         Text(
//           'Main Dashboard',
//           style: TextStyle(
//             fontSize: 20.fSize,
//             color: const Color(0xFFC3B9FF),
//             fontFamily: 'Open Sans',
//             fontWeight: FontWeight.w800,
//             shadows: const [
//               Shadow(
//                   color: Color(0XFFC3B9FF),
//                   blurRadius: 0.5,
//                   offset: Offset(0.25, 0.5))
//             ],
//           ),
//         ),
//         IconButton(
//           onPressed: () => print('Notification button pressed'),
//           icon: Image.asset(
//             'assets/images/notifications.png',
//             width: 6.width,
//             opacity: const AlwaysStoppedAnimation(0),
//             height: 3.height,
//             fit: BoxFit.contain,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildUserInfo() {
//     return ListenableBuilder(
//       listenable: DashboardVM(),
//       builder: (context, _) {
//         return Padding(
//           padding: EdgeInsets.only(left: 2.width, bottom: 4.height),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Image.asset(
//                     'assets/images/dashboard_gem.png',
//                     width: 8.width,
//                     height: 6.height,
//                     fit: BoxFit.contain,
//                   ),
//                   SizedBox(width: 5.width),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         DashboardVM().userNameAccount,
//                         style: TextStyle(
//                           fontFamily: 'Open Sans',
//                           fontSize: 20.fSize,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0XFF4313E9),
//                         ),
//                       ),
//                       Text(
//                         'Property Owner',
//                         style: TextStyle(
//                           fontFamily: 'Open Sans',
//                           fontSize: 15.fSize,
//                           fontWeight: FontWeight.w300,
//                           fontStyle: FontStyle.italic,
//                           color: const Color(0XFF555555),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Spacer(),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(builder: (_) => const SettingPage()));
//                     },
//                     child: Padding(
//                       padding: EdgeInsets.only(top: 2.height, right: 2.width),
//                       child: Image.asset(
//                         'assets/images/arrow_button.png',
//                         width: 7.width,
//                         height: 5.height,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 2.height),
//               Container(
//                 height: 1,
//                 color: Colors.grey[300],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         title,
//         style: TextStyle(
//           fontFamily: 'Open Sans',
//           fontSize: 20.fSize,
//           fontWeight: FontWeight.w800,
//           color: const Color(0XFF4313E9),
//         ),
//       ),
//     );
//   }
// }
