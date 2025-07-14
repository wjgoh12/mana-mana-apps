import 'package:flutter/material.dart';
import 'package:mana_mana_app/widgets/new_bar_chart.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

Widget topBar(context, function) {

  return PreferredSize(
    preferredSize: Size(MediaQuery.of(context).size.width,60),
    child: ClipRRect(
      child: Container(
        decoration: BoxDecoration(
           border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
         ),
        child: AppBar(
          automaticallyImplyLeading: false,
           backgroundColor: Colors.white,
           foregroundColor: Colors.white,
           elevation: 0,  
           
          leadingWidth: 16.width,
          // leadingWidth: 3.width,
          //toolbarHeight: 50.0,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(
             radius: 18.fSize,
             
             backgroundColor: Colors.transparent, // or tweak size as needed
             child:const CircleAvatar(
              backgroundImage: AssetImage(
              'assets/images/mana2logo.png',
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
                  color: Colors.white,
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
            // toolbarOpacity: 1.0,
            // titleSpacing: 0,
        
        ),
      ),
    ),
  );

}
  