
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';
import 'package:mana_mana_app/screens/Newsletter/ViewModel/newsletter_VM.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
class NewsletterReadDetails extends StatelessWidget {

  const NewsletterReadDetails({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    final model = NewsletterVM();
    final containerWidth = 40.fSize;
        final containerHeight = 50.fSize;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 285.fSize,
        automaticallyImplyLeading: false,
       flexibleSpace: 
       Container(
        decoration:BoxDecoration(
          image:DecorationImage(
            image: AssetImage('assets/images/newsletter_image.png'),
            fit: BoxFit.cover,),),
         child: SafeArea(child: 
         Padding(
          padding: EdgeInsets.only(top: 20.fSize),
           child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Stack(
                children:[ 
                  Text(
                  'Newsletter',
                  style: TextStyle(
                    fontSize: 20.fSize,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                    ..style=PaintingStyle.stroke
                    ..strokeWidth=2
                    ..color=Colors.black,
                ),
                ),
                Text(
                  'Newsletter',
                  style: TextStyle(
                    fontSize: 20.fSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ]
              ),
              const SizedBox(width:20),
            ],
          ),
               ),
         
         ),
               ),
       ),
      ),
      
      body: Container(
        padding: const EdgeInsets.all(8.0),
       
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [
              SizedBox(height: 20.fSize),
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Text(
                    'Scarletz Suites: Your Chic Urban Stay in the Heart of Kuala Lumpur',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                    maxLines: 6,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height:25.fSize),
          
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: const BoxDecoration(
                      color: Color(0XFF3E51FF),
                    ),
                    child: Column(
                      children: [
                        Text(DateTime.now().day.toString(),
                        style:TextStyle(
                          color: Colors.white,
                          fontSize: 23.fSize
                        )
                        ),
                       Text(
                          [
                            'January', 'February', 'March', 'April', 'May', 'June',
                            'July', 'August', 'September', 'October', 'November', 'December'
                          ][DateTime.now().month - 1],
                        style:TextStyle(
                          color: Colors.white,
                          fontSize: 11.fSize,
                          ),
                        )
                      ]
                           ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                        Image.asset('assets/images/newsletter_icon.png'),
                        SizedBox(width:2),
                        const Text('Anis Shazwani'),
                        ]
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset('assets/images/Clock.png'),
                          SizedBox(width:2),
                          const Text(
                            '2 min read',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                ),
              ),
          
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 380, 
                  
                    ),
                    child: const Text(
                      'Looking for a stylish and convenient stay right next to KLCC? ✨ Whether you\' re in town for a quick business trip, long-term project, or simply working remotely — Scarletz Suites by Mana Mana offers a modern, flexible living experience right in the city center. \n\nWhy Stay at Scarletz Suites, Mana Mana?',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                      
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
            ],
            ),
        ),

      )
    );

  }

  


  
}
