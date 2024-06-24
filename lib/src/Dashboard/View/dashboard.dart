import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  var height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body : Container(
        color: Colors.indigo,
        height: height,
        width: width,
      child : Column(
        children: [
          Container(
            decoration: const BoxDecoration(),
            height: height * 0.15,
            width: width,
            child: Column(
              children: [
                Padding(padding: const EdgeInsets.only(top: 55, left: 15, right: 15),
                child : 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRect(
                      child: Image.asset("assets/images/mana2logo.png",
                      height : 60,
                      width : 60,
                      ),
                    ),
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                    InkWell(
                      onTap: (){},
                      child: const Icon(
                        Icons.sort,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            height: height * 0.85 ,
            width: width,
          )
      ],
      ),
      ),
    );
  }
}