// import 'package:flutter/material.dart';

// class Navigator extends StatefulWidget {
//   const Navigator({Key? key}) : super(key: key);

//   @override
//   State<Navigator> createState() => _CustomNavigatorState();
// }

// class _NavigatorState extends State<Navigator> {
//   int selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavButton(
//             index: 0,
//             icon: Icons.home,
//             label: 'Home',
//             onTap: () => _navigateToPage('/home'),
//           ),
//           _buildNavButton(
//             index: 1,
//             icon: Icons.business,
//             label: 'Properties',
//             onTap: () => _navigateToPage('/properties'),
//           ),
//           _buildNavButton(
//             index: 2,
//             icon: Icons.newspaper,
//             label: 'Newsletter',
//             onTap: () => _navigateToPage('/newsletter'),
//           ),
//           _buildNavButton(
//             index: 3,
//             icon: Icons.person,
//             label: 'Profile',
//             onTap: () => _navigateToPage('/profile'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavButton({
//     required int index,
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     bool isSelected = selectedIndex == index;
    
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedIndex = index;
//         });
//         onTap();
//       },
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             color: isSelected ? const Color(0xFF4313E9) : Colors.grey,
//             size: 24,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? const Color(0xFF4313E9) : Colors.grey,
//               fontSize: 12,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToPage(String route) {
//     switch (route) {
//       case '/home':
//         Navigator.pushNamed(context, '/home');
//         // Or: Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
//         break;
//       case '/properties':
//         Navigator.pushNamed(context, '/properties');
//         // Or: Navigator.push(context, MaterialPageRoute(builder: (context) => PropertiesPage()));
//         break;
//       case '/newsletter':
//         Navigator.pushNamed(context, '/newsletter');
//         // Or: Navigator.push(context, MaterialPageRoute(builder: (context) => NewsletterPage()));
//         break;
//       case '/profile':
//         Navigator.pushNamed(context, '/profile');
//         // Or: Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
//         break;
//     }
//   }
// }
