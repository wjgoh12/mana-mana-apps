// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mana_mana_app/screens/legacy/Dashboard_old/ViewModel/dashboardVM.dart';
// import 'package:mana_mana_app/core/utils/responsive.dart';
// import 'package:mana_mana_app/core/utils/size_utils.dart';

// class BuildRevenueContainers extends StatelessWidget {
//   const BuildRevenueContainers({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // Expanded(
//         //   child: _RevenueContainer(
//         //     title: 'Overall Balance To Owner',
//         //     icon: Icons.account_balance_wallet_outlined,
//         //     overallRevenue: true,
//         //   ),
//         // ),
//         // SizedBox(width: 10),
//         Expanded(
//           child: _RevenueContainer(
//             title:
//                 '${DateTime.now().month != 1 ? DateTime.now().year : DateTime.now().year - 1} Accumulated Profit​',
//             icon: Icons.home_outlined,
//             overallRevenue: false,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _RevenueContainer extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final bool overallRevenue;

//   const _RevenueContainer({
//     Key? key,
//     required this.title,
//     required this.icon,
//     required this.overallRevenue,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final DashboardVM model = DashboardVM();
//     model.monthlyBlcOwner = [];
//     model.monthlyProfitOwner = [];
//     return SizedBox(
//       width: 40.width,
//       height: 11.height,
//       child: Stack(
//         children: [
//           GestureDetector(
//             onTap: () => model.updateOverallRevenueAmount(),
//             child: Container(
//               padding: !Responsive.isMobile(context)
//                   ? EdgeInsets.only(
//                       left: 1.height, top: 1.height, right: 1.height)
//                   : EdgeInsets.all(1.height),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFFFFF),
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xffC3B9FF).withOpacity(0.25),
//                     offset: const Offset(0, 4),
//                     blurRadius: 4,
//                   )
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: (0.5).height,
//                   ),
//                   _buildTitleRow(),
//                   SizedBox(height: (1.5).height),
//                   _buildContentRow(),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             left: 0,
//             top: 0,
//             bottom: 0,
//             child: Image.asset(
//               'assets/images/patterns_unit_revenue.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTitleRow() {
//     return Row(
//       children: [
//         SizedBox(width: 3.width),
//         Text(
//           title,
//           style: TextStyle(
//             fontFamily: 'Open Sans',
//             fontWeight: FontWeight.w700,
//             // fontSize: AppDimens.fontSizeSmall,
//             fontSize: AppDimens.fontSizeBig,
//             color: const Color(0xFF4313E9),
//           ),
//         ),
//         const Spacer(),
//         // Container(
//         //   width: 3.width,
//         //   height: 3.width,
//         //   alignment: Alignment.center,
//         //   child: Icon(
//         //     Icons.arrow_outward_rounded,
//         //     color: const Color(0xff3E51FF),
//         //     size: 3.width,
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Widget _buildContentRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         SizedBox(width: 3.width),
//         Container(
//           width: 8.width,
//           height: 8.width,
//           decoration: const BoxDecoration(
//             color: Color(0XFFF9F8FF),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             icon,
//             color: const Color(0XFF2900B7),
//             size: 4.width,
//           ),
//         ),
//         SizedBox(width: 3.width),
//         // const Spacer(),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             _buildAmountText(),
//             // _buildPercentageText(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildAmountText() {
//     return ListenableBuilder(
//       listenable: DashboardVM(),
//       builder: (context, _) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'RM',
//               style: TextStyle(
//                 fontFamily: 'Open Sans',
//                 fontWeight: FontWeight.w700,
//                 fontSize: AppDimens.fontSizeBig,
//                 color: const Color(0XFF2900B7),
//               ),
//             ),
//             SizedBox(width: 1.width),
//             FutureBuilder<dynamic>(
//               future: overallRevenue
//                   ? DashboardVM().overallBalance
//                   : DashboardVM().overallProfit,
//               builder: (context, snapshot) {
//                 if (DashboardVM().isLoading) {
//                   // if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const SizedBox(
//                     width: 25,
//                     height: 25,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                     ),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else {
//                   final value = snapshot.data ?? 0.00;
//                   return Text(
//                     NumberFormat('#,##0.00').format(value),
//                     // (value is double ? value : 0.00).toStringAsFixed(2),
//                     style: TextStyle(
//                       fontFamily: 'Open Sans',
//                       fontWeight: FontWeight.w700,
//                       fontSize: AppDimens.fontSizeBig,
//                       color: const Color(0XFF2900B7),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildPercentageText() {
//     return Text.rich(
//       TextSpan(
//         text: '-',
//         style: TextStyle(
//           fontFamily: 'Open Sans',
//           fontWeight: FontWeight.w400,
//           fontSize: AppDimens.fontSizeSmall,
//           color: const Color(0XFF2900B7),
//         ),
//         children: <InlineSpan>[
//           WidgetSpan(
//             child: Icon(
//               Icons.arrow_drop_up,
//               color: const Color(0XFF42C18B),
//               size: 2.height,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
