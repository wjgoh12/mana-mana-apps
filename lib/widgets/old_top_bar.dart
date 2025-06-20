import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => '',
          icon: Image.asset(
            'assets/images/mana2logo.png',
            width: 10.width,
            height: 5.height,
            fit: BoxFit.fill,
          ),
        ),
        Text(
          'Main Dashboard',
          style: TextStyle(
            fontSize: 20.fSize,
            color: const Color(0xFFC3B9FF),
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(
                  color: Color(0XFFC3B9FF),
                  blurRadius: 0.5,
                  offset: Offset(0.25, 0.5))
            ],
          ),
        ),
        IconButton(
          onPressed: () => print('Notification button pressed'),
          icon: Image.asset(
            'assets/images/notifications.png',
            width: 6.width,
            opacity: AlwaysStoppedAnimation(0),
            height: 3.height,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
