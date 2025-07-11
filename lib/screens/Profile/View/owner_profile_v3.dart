import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Login/View/loginpage.dart';
import 'package:mana_mana_app/screens/Profile/View/financial_details.dart';
import 'package:mana_mana_app/screens/Profile/View/personal_information.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerProfile_v3 extends StatelessWidget {
  const OwnerProfile_v3({super.key});

  @override
  Widget build(BuildContext context) {
    
    final OwnerProfileVM model = OwnerProfileVM();
    model.fetchData();
    return ListenableBuilder(
        listenable: model,
        builder: (context, child) {
          return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Row(
                  children:[ 
                    CircleAvatar(
                    radius: 23.fSize, 
                    backgroundImage: const AssetImage(
                      'assets/images/mana2logo.png',),
                    backgroundColor: Colors.white,
                    ),
                    SizedBox(width: 10.fSize),
                   Text(
                    'Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ).createShader(
                            const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0)),
                    ),
                  ),
                  ]
                ),
                centerTitle: false,
                
              ),
              body: Container(
                decoration: BoxDecoration(
                  color: Colors.white
                ),
                child: SingleChildScrollView(
                  child:Padding(
                    padding: const EdgeInsets.only(left:10,top:15),
                  child:Column(
                    children: [
                      DecoratedBox(
                        decoration:BoxDecoration(
                          color:Colors.white,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30, // circle radius
                              backgroundColor: const Color(0xFFF5F5FF),
                              child: Image.asset(
                                'assets/images/Group.png',
                                width: 42.fSize,
                                height: 42.fSize,
                              ),
                            ),
                            SizedBox(width: 10.fSize),
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                        
                                model.users.isNotEmpty
                                ? Text(
                                  model.users.first.ownerFullName ?? '',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0)),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                ):const Text('Loading...'),
                        
                                const Text('Property Owner',
                                  style: TextStyle(
                                    fontSize: 14
                                  ),
                                ),
                            ],
                            ),
                        
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'My Profile',
                              textAlign: TextAlign.left,
                              style:TextStyle(
                                fontSize: 18.fSize,
                                fontWeight: FontWeight.bold,
                                
                              )),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.fSize),
                
                      InkWell(
                        highlightColor: Colors.transparent,
                        //this widget responds to touch actions
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => PersonalInformation()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFF9F8FF),
                                child: Image.asset(
                                  'assets/images/profile_person_outline.png',
                                  width: 42.fSize,
                                  height: 42.fSize,
                                ),
                              ),
                              SizedBox(width: 20.fSize),
                              Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        //this widget responds to touch actions
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FinancialDetails()),
                          );
                        },
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFFFF2E0),
                                child: Image.asset(
                                  'assets/images/profile_financial_details.png',
                                  width: 42.fSize,
                                  height: 42.fSize,
                                ),
                              ),
                              SizedBox(width: 20.fSize),
                              Text(
                                'Financial Details',
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 25.fSize),
                      Row(
                
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Contact Us',
                              textAlign: TextAlign.left,
                              style:TextStyle(
                                fontSize: 18.fSize,
                                fontWeight: FontWeight.bold,
                                
                              )),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.fSize),
                
                      InkWell(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        //this widget responds to touch actions
                         onTap: () {
                        //   Navigator.of(context).push(
                        //     MaterialPageRoute(builder: (_) => OwnerProfile_v3()),
                        //   );
                        final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: 'admin@manamanasuites.com',
                              );
                              launchUrl(emailLaunchUri);
                
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFE9F6FF),
                                child: Image.asset(
                                  'assets/images/profile_email.png',
                                  width: 42.fSize,
                                  height: 42.fSize,
                                ),
                              ),
                              SizedBox(width: 20.fSize),
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.fSize),
                
                      InkWell(
                        highlightColor: Colors.transparent,
                        onTap: () {
                         launchUrl(Uri.parse('tel:+60327795035'));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFFBF6FE),
                                child: Image.asset(
                                  'assets/images/profile_telephone.png',
                                  width: 42.fSize,
                                  height: 42.fSize,
                                ),
                              ),
                              SizedBox(width: 20.fSize),
                              Text(
                                'Telephone',
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.fSize),
                
                      InkWell(
                        highlightColor: Colors.transparent,
                        onTap: () {
                          launchUrl(Uri.parse('https://wa.me/60125626784'));
                        
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFE9FFEB),
                                child: Image.asset(
                                  'assets/images/profile_whatsapp.png',
                                  width: 42.fSize,
                                  height: 42.fSize,
                                ),
                              ),
                              SizedBox(width: 20.fSize),
                              Text(
                                'Whatsapp',
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                
                      SizedBox(height: 65.fSize),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton
                          (
                            onPressed: (){
                              //logout
                              final authService = AuthService();
                              authService.logout(context);
                            },
                            style: ButtonStyle(
                              
                              backgroundColor: WidgetStateProperty.all(const Color(0xFFF2F2F2)),
                              shape:WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                )
                              )
                
                            ), 
                            child: const Text('Logout')
                             ),
                
                        ],
                      ),
                
                     SizedBox(height: 35.fSize),
                
                     //terms and conditions and privacy policy
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          
                          
                          onPressed: (){
                          launchUrl(Uri.parse(
                                    'https://www.manamanasuites.com/terms-conditions'));
                        
                         ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        foregroundColor: WidgetStateProperty.all(Colors.transparent),
                        shadowColor: WidgetStateProperty.all(Colors.transparent),
                        );
                
                        }, 
                        child: Text('Terms and Conditions',
                        style: TextStyle(
                          fontSize: 14.fSize,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF3E51FF),
                        ),
                        ),
                        ),
                
                        TextButton(onPressed: (){
                         launchUrl(Uri.parse(
                                    'https://www.manamanasuites.com/privacy-policy'));
                         style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        );
                
                        }, 
                        child: Text('Privacy Policy',
                        style: TextStyle(
                          fontSize: 14.fSize,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF3E51FF),
                        ),
                        ),
                        ),
                      ],
                     ),
                
                
                      
                
                
                    ]
                  ),
                  )
                
                    ),
              ),
                  
              
              bottomNavigationBar: const BottomNavBar(currentIndex: 3,),
              );
        });
  }
}

Widget buildInfoRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Icon(icon, color: const Color(0XFF555555), size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(fontSize: 12, color: Color(0XFF555555)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoInRow(String info) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              info,
              style: const TextStyle(
                  fontSize: 15,
                  color: Color(0XFF4313E9),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

