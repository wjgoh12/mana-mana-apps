// import 'package:flutter/material.dart';
// import 'package:mana_mana_app/widgets/newsletter_appbar.dart';
// import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
// import 'package:mana_mana_app/widgets/newsletter_stack.dart';

// class AllNewsletter extends StatelessWidget {
//   const AllNewsletter({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: newsletterAppBar(context, () {}),
//       body: ListView(children: [
//         Column(
//           children: [
//             GestureDetector(
//               child: const Column(children: [
//                 newsletterStack(
//                     image: 'assets/images/newsletter_image.png',
//                     text1: 'Anis Shazwani',
//                     text2: 'woohoo')
//               ]),
//             ),
//           ],
//         )
//       ]),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: const BottomNavBar(
//         currentIndex: 2,
//       ),
//     );
//   }
// }
