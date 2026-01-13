import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
// import 'package:flutter/material.dart';
// import 'package:mana_mana_app/provider/global_data_manager.dart';
// import 'package:mana_mana_app/screens/all_properties/widgets/occupancy_rate_box.dart';
// import 'package:mana_mana_app/screens/all_properties/widgets/recent_activity.dart';
// import 'package:mana_mana_app/screens/all_properties/widgets/property_dropdown.dart';
// import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';
// import 'package:mana_mana_app/screens/property_detail/view_model/property_detail_view_model.dart';
// import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
// import 'package:mana_mana_app/widgets/overview_card.dart';
// import 'package:mana_mana_app/widgets/property_app_bar.dart';
// import 'package:mana_mana_app/widgets/responsive_size.dart';
// import 'package:mana_mana_app/core/utils/size_utils.dart';
// import 'package:provider/provider.dart';

// class PropertySummaryScreen extends StatefulWidget {
//   const PropertySummaryScreen({super.key});

//   @override
//   State<PropertySummaryScreen> createState() => _PropertySummaryScreenState();
// }

// class _PropertySummaryScreenState extends State<PropertySummaryScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider.value(value: GlobalDataManager()),
//         ChangeNotifierProvider(
//           create: (_) {
//             final model = NewDashboardVM_v3();

//             model.fetchData();
//             return model;
//           },
//         ),
//         ChangeNotifierProvider(
//           create: (_) => PropertyDetailVM(),
//         ),
//       ],
//       child: Consumer2<NewDashboardVM_v3, PropertyDetailVM>(
//         builder: (context, dashboardModel, propertyModel, child) {
//           if (dashboardModel.locationByMonth.isNotEmpty &&
//               !propertyModel.isLoading) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               propertyModel.fetchData(dashboardModel.locationByMonth);
//             });
//           }

//           return LayoutBuilder(
//             builder: (context, constraints) {
//               final screenWidth = constraints.maxWidth;
//               final screenHeight = constraints.maxHeight;

//               const double baseWidth = 390;
//               const double baseHeight = 844;
//               final double scaleW = screenWidth / baseWidth;
//               final double scaleH = screenHeight / baseHeight;

//               return Scaffold(
//                 backgroundColor: const Color(0XFFFFFFFF),
//                 appBar: propertyAppBar(
//                   context,
//                   () => Navigator.of(context).pop(),
//                 ),
//                 body: dashboardModel.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : Column(
//                         children: [
//                           const Padding(
//                             padding:
//                                 EdgeInsets.only(left: 15, top: 10, bottom: 10),
//                             child: Row(
//                               children: [],
//                             ),
//                           ),
//                           Expanded(
//                             child: ListView(
//                               shrinkWrap: true,
//                               padding: const EdgeInsets.symmetric(vertical: 5),
//                               children: [
//                                 Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 15 * scaleW,
//                                       vertical: 10 * scaleH),
//                                   child: OverviewCard(model: dashboardModel),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 15 * scaleW,
//                                       vertical: 10 * scaleH),
//                                   child:
//                                       OccupancyRateBox(model: dashboardModel),
//                                 ),
//                                 if (propertyModel.unitByMonth.isNotEmpty)
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 15 * scaleW,
//                                         vertical: 10 * scaleH),
//                                     child: RecentActivity(model: propertyModel),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                 bottomNavigationBar: const BottomNavBar(currentIndex: 1),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // Extract content to optimize rebuilds (optional)
// // ignore: unused_element
// class _PropertySummaryContent extends StatelessWidget {
//   const _PropertySummaryContent();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<NewDashboardVM_v3, PropertyDetailVM>(
//       builder: (context, model, model2, child) {
//         print('locationByMonth length: ${model.locationByMonth.length}');
//         return SingleChildScrollView(
//           padding: const EdgeInsets.only(left: 15, top: 5, right: 15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Row(
//                 children: [
//                   Expanded(
//                     flex: 0,
//                     child: PropertyTitleDropdown(currentPage: 'Property List'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                 child: OverviewCard(model: model),
//               ),
//               SizedBox(height: 10.fSize),
//               OccupancyRateBox(),
//               Container(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text('Recent Activity',
//                     style: TextStyle(
//                         fontFamily: AppFonts.outfit,
//                         fontSize: AppDimens.fontSizeBig,
//               ),
//               RecentActivity(
//                 model: model2,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
