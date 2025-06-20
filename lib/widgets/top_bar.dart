import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/new_bar_chart.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    return Row(
     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
  onPressed: () => '',
  icon: Container(
    width: 10.width,
    height: 10.height, 
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(
        image: AssetImage('assets/images/mana2logo.png'),
        fit: BoxFit.scaleDown,
      ),
    ),
  ),
),

        ShaderMask(
          shaderCallback: (bounds)=>
          const LinearGradient(
          colors: 
        [Color(0xFFB82B7D),Color.fromRGBO(62, 81, 255, 1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          'Owner\'s Portal',
          style: TextStyle(
            fontSize: 25.fSize,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w800,
            color: const Color(0xFFB82B7D),
            shadows: const [
              Shadow(
                  color: Color(0XFFC3B9FF),
                  blurRadius: 0.5,
                  offset: Offset(0.25, 0.5))
            ],
          ),
        ),
        ),
        
        const Expanded(child: SizedBox()),
        IconButton(
          onPressed: () => print('Notification button pressed'),
          icon: Image.asset(
            'assets/images/Notification.png',
            width: 6.width,
            //opacity: const AlwaysStoppedAnimation(0),
            height: 6.height,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}