// import 'package:flutter/material.dart';
// import 'package:mana_mana_app/provider/global_data_manager.dart';
// import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';
// import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
// import 'package:mana_mana_app/widgets/property_app_bar.dart';
// import 'package:mana_mana_app/widgets/property_stack.dart';
// import 'package:provider/provider.dart';

// class AllPropertyScreen extends StatelessWidget {
//   const AllPropertyScreen({super.key});

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
//       ],
//       child: Consumer<NewDashboardVM_v3>(
//         builder: (context, model, child) {
//           return Scaffold(
//             backgroundColor: AppColors.white,
//             appBar: propertyAppBar(
//               context,
//               () => Navigator.of(context).pop(),
//             ),
//             body: model.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Column(
//                     children: [
//                       const Padding(
//                         padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
//                         child: Row(
//                           children: [],
//                         ),
//                       ),
//                       Expanded(
//                         child: ListView(
//                           shrinkWrap: true,
//                           padding: const EdgeInsets.symmetric(vertical: 5),
//                           children: [
//                             _buildPropertyStack(
//                               locationByMonth: model.locationByMonth,
//                               context: context,
//                               model: model,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//             bottomNavigationBar: const BottomNavBar(currentIndex: 1),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildPropertyStack({
//     required List<Map<String, dynamic>> locationByMonth,
//     required BuildContext context,
//     required NewDashboardVM_v3 model,
//   }) {
//     final isMobile = MediaQuery.of(context).size.width < 600;
//     final horizontalPadding = isMobile ? 16.0 : 40.0;

//     final Map<String, Map<String, dynamic>> latestByLocation = {};
//     final List<Map<String, dynamic>> source = locationByMonth;

//     for (var property in source) {
//       final location = property['location'] as String;
//       if (!latestByLocation.containsKey(location)) {
//         latestByLocation[location] = property;
//       } else {
//         final existing = latestByLocation[location]!;
//         final isNewer = (property['year'] > existing['year']) ||
//             (property['year'] == existing['year'] &&
//                 property['month'] > existing['month']);
//         if (isNewer) {
//           latestByLocation[location] = property;
//         }
//       }
//     }

//     final latestProperties = latestByLocation.values.toList()
//       ..sort((a, b) {
//         final yearDiff = (b['year'] as int).compareTo(a['year'] as int);
//         if (yearDiff != 0) return yearDiff;
//         return (b['month'] as int).compareTo(a['month'] as int);
//       });

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//       itemCount: latestProperties.length,
//       itemBuilder: (context, index) {
//         final property = latestProperties[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 20.0),
//           child: Center(
//             child: PropertyStack(
//               locationByMonth: [property],
//               model: model,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
