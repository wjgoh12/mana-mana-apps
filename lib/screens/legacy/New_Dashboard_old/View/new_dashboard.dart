import 'package:mana_mana_app/core/constants/app_dimens.dart';
// import 'package:flutter/material.dart';
// import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/View/property_list.dart';
// import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/View/revenue_dashboard.dart';
// import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/View/statistic_table.dart';
// import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/View/user_info.dart';
// import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/ViewModel/new_dashboardVM.dart';
// import 'package:mana_mana_app/widgets/old_top_bar.dart';
// import 'package:mana_mana_app/core/utils/responsive.dart';
// import 'package:mana_mana_app/core/utils/size_utils.dart';

// class NewDashboard extends StatelessWidget {
//   const NewDashboard({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final NewDashboardVM model = NewDashboardVM();
//     model.fetchData();
//     return ListenableBuilder(
//         listenable: model,
//         builder: (context, child) {
//           return Scaffold(
//             body: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 _buildBackgroundContainer(),
//                 AppBar(
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   title: const TopBar(),
//                   automaticallyImplyLeading: false,
//                   toolbarHeight: !Responsive.isMobile(context) ? 160 : 50,
//                 ),
//                 Positioned(
//                   top: 14.height,
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: NotificationListener<ScrollNotification>(
//                     onNotification: (scrollNotification) {
//                       if (scrollNotification is ScrollUpdateNotification) {}
//                       return true;
//                     },
//                     child: ClipRRect(
//                       borderRadius:
//                           const BorderRadius.vertical(top: Radius.circular(20)),
//                       child: RefreshIndicator(
//                         onRefresh: () async {
//                           await model.refreshData();
//                         },
//                         child: SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               Container(
//                                 width: 100.width,
//                                 padding: EdgeInsets.all(7.width),
//                                 decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Color(0XFFFFFFFF),
//                                       Color(0XFFDFD8FF)
//                                     ],
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                   ),
//                                   borderRadius: BorderRadius.vertical(
//                                       top: Radius.circular(20)),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     UserInfo(model: model),
//                                     RevenueDashboard(model: model),
//                                     SizedBox(height: 2.height),
//                                     _buildSectionTitle('Statistics'),
//                                     SizedBox(height: 2.height),
//                                     StatisticTable(model: model),
//                                     SizedBox(height: 2.height),
//                                     _buildSectionTitle('Properties'),
//                                     SizedBox(height: 2.height),
//                                     PropertyList(model: model),
//                                     SizedBox(height: 2.height),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           );
//         });
//   }
// }

// Widget _buildBackgroundContainer() {
//   return Container(
//     alignment: Alignment.topCenter,
//     width: 100.width,
//     height: 100.height,
//     color: const Color(0XFF4313E9),
//     padding: EdgeInsets.only(top: 2.height),
//     child: Image.asset(
//       'assets/images/mana2_patterns.png',
//       width: 110.width,
//       height: 20.height,
//       fit: BoxFit.cover,
//     ),
//   );
// }

// Widget _buildSectionTitle(String title) {
//   return Align(
//     alignment: Alignment.centerLeft,
//     child: Text(
//       title,
//       style: TextStyle(
//         fontFamily: 'Open Sans',
//         fontSize: AppDimens.fontSizeBig,
//         fontWeight: FontWeight.w800,
//         color: const Color(0XFF4313E9),
//       ),
//     ),
//   );
// }
