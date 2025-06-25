import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/new_bar_chart.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

PreferredSizeWidget topBar(context, function) {

  return AppBar(
    backgroundColor: Colors.white,
    leadingWidth: 3.width,
    toolbarHeight: 60.0,
    leading:IconButton(
      onPressed:() => print('Pressed'),
    
      icon:Container(
        alignment: Alignment.topLeft,
        width: 50.fSize,
        height: 50.fSize, 
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(
        image: AssetImage('assets/images/mana2logo.png'),
         fit: BoxFit.fill,
      ),
    ),
    ),
    ),

    title:ShaderMask(
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
            color: const Color(0xFFFFFFFF),
            //shadows: const [
              //Shadow(
              //    color: Color(0XFFC3B9FF),
              //    blurRadius: 0.5,
             //     offset: Offset(0.25, 0.5))
           // ],
          ),
        ),
        ),
        
        //notification button move to right, so use expanded
        centerTitle: false,
        actions:[
        IconButton(
          onPressed: () => print('Notification button pressed'),
          icon: Image.asset(
            'assets/images/Notification.png',
            width: 8.width,
            //opacity: const AlwaysStoppedAnimation(0),
            height: 8.height,
            fit: BoxFit.contain,
          ),
        ),
        ],
      toolbarOpacity: 1.0,
      titleSpacing: 0,

  );

}
  