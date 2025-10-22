import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerProfile_v3 extends StatefulWidget {
  const OwnerProfile_v3({super.key});

  @override
  State<OwnerProfile_v3> createState() => _OwnerProfile_v3State();
}

class _OwnerProfile_v3State extends State<OwnerProfile_v3> {
  final OwnerProfileVM model = OwnerProfileVM();
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    model.fetchData().then((_) => model.checkRole());
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return; // prevent duplicate presses

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authService = AuthService();
      await authService.logout(context);
    } catch (e) {
      debugPrint("Logout failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double value) =>
        (value / 375.0) * screenWidth; // base width
    double responsiveHeight(double value) =>
        (value / 812.0) * screenHeight; // base height
    double responsiveFont(double value) =>
        (value / 812.0) * screenHeight; // font scaling

    return ListenableBuilder(
        listenable: model,
        builder: (context, child) {
          return Scaffold(
              backgroundColor: Colors.white,
              extendBody: true,
              appBar: AppBar(
                backgroundColor: Colors.white,
                leadingWidth: 13.width,
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20.fSize, // or tweak size as needed
                      backgroundImage: const AssetImage(
                        'assets/images/mana2logo1.png',
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: const Color(0xFF000241),
                            fontFamily: 'outfit',
                            fontSize: ResponsiveSize.text(20),
                            fontWeight: FontWeight.w700,
                          ),
                        )
                        // GradientText1(
                        //     text: 'Profile',
                        //     style: TextStyle(
                        //       fontFamily: 'outfit',
                        //       fontSize: responsiveFont(20),
                        //       fontWeight: FontWeight.w800,
                        //     ),
                        //     gradient: const LinearGradient(
                        //       begin: Alignment.centerLeft,
                        //       end: Alignment.centerRight,
                        //       colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                        //     )),
                        ),
                  ],
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(bottom: responsiveHeight(100)),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.all(responsiveHeight(10)),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.fSize),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ]),
                          child: Column(
                            children: [
                              SizedBox(height: ResponsiveSize.scaleHeight(20)),
                              Row(
                                children: [
                                  SizedBox(width: 15.fSize),
                                  Image.asset(
                                    'assets/images/profile_icon.png',
                                    width: ResponsiveSize.scaleWidth(50),
                                    height: ResponsiveSize.scaleHeight(50),
                                  ),
                                  SizedBox(width: 10.fSize),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Property Owner',
                                            style: TextStyle(
                                                fontFamily: 'outfit',
                                                fontSize:
                                                    ResponsiveSize.text(14),
                                                fontWeight: FontWeight.w300),
                                          ),
                                          model.users.isNotEmpty
                                              ? Text(
                                                  model.users.first
                                                          .ownerFullName ??
                                                      '',
                                                  style: TextStyle(
                                                    fontFamily: 'outfit',
                                                    fontSize:
                                                        responsiveFont(20),
                                                    fontWeight: FontWeight.bold,
                                                    foreground: Paint()
                                                      ..shader =
                                                          const LinearGradient(
                                                        colors: [
                                                          Color(0xFF000241),
                                                          Color(0xFF0A009C),
                                                        ],
                                                        begin: Alignment
                                                            .bottomLeft,
                                                        end: Alignment.topRight,
                                                      ).createShader(const Rect
                                                              .fromLTWH(
                                                              0.0,
                                                              0.0,
                                                              300.0,
                                                              100.0)),
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : const Text('Loading...'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.fSize),
                              // Row(
                              //   children: [
                              //     _buildRow(context, label: 'Name'),
                              //     SizedBox(width: responsiveWidth(8)),
                              //     model.users.isNotEmpty
                              //         ? _buildData(context,
                              //             data:
                              //                 model.users.first.ownerFullName ??
                              //                     '')
                              //         : const Text('Loading...'),
                              //   ],
                              // ),
                              Row(
                                children: [
                                  SizedBox(width: ResponsiveSize.scaleWidth(9)),
                                  CircleAvatar(
                                    radius: ResponsiveSize.scaleWidth(20),
                                    backgroundColor: const Color(0xFF010367),
                                    child: Image.asset(
                                      'assets/images/ic_icon.png',
                                      width: ResponsiveSize.scaleWidth(25),
                                      color: const Color(0xFFFFFFFFFF),
                                      height: ResponsiveSize.scaleHeight(25),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveSize.scaleWidth(10)),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Identification',
                                        style: TextStyle(
                                            fontFamily: 'outfit',
                                            fontSize: ResponsiveSize.text(11),
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(width: responsiveWidth(8)),
                    model.users.isNotEmpty
                      ? Text(
                        '000000-00-0000',
                        maxLines: 6,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        style: TextStyle(
                          fontFamily: 'outfit',
                          fontSize: ResponsiveSize.text(12),
                          fontWeight: FontWeight.w400),
                      )
                      : const Text('Loading...'),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveSize.scaleHeight(15)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: ResponsiveSize.scaleWidth(9)),
                                  CircleAvatar(
                                    radius: ResponsiveSize.scaleWidth(20),
                                    backgroundColor: const Color(0xFF010367),
                                    child: Image.asset(
                                      'assets/images/profile_personal_email.png',
                                      width: ResponsiveSize.scaleWidth(25),
                                      color: Color(0xFFFFFFFFFF),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveSize.scaleWidth(10)),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Email',
                                                style: TextStyle(
                                                  fontFamily: 'outfit',
                                                  fontSize:
                                                      ResponsiveSize.text(11),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: ResponsiveSize
                                                      .scaleHeight(4)),
                                              model.users.isNotEmpty
                                                  ? Text(
                                                      model.users.first
                                                              .ownerEmail ??
                                                          '',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      softWrap: true,
                                                      style: TextStyle(
                                                          fontFamily: 'outfit',
                                                          fontSize:
                                                              ResponsiveSize
                                                                  .text(12),
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    )
                                                  : const Text('Loading...'),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                ResponsiveSize.scaleWidth(15)),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius:
                                                    ResponsiveSize.scaleWidth(
                                                        20),
                                                backgroundColor:
                                                    const Color(0xFF010367),
                                                child: Image.asset(
                                                  'assets/images/profile_phone.png',
                                                  color:
                                                      const Color(0xFFFFFFFFFF),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                      ResponsiveSize.scaleWidth(
                                                          10)),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Contact No.',
                                                    style: TextStyle(
                                                      fontFamily: 'outfit',
                                                      fontSize:
                                                          ResponsiveSize.text(
                                                              11),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: ResponsiveSize
                                                          .scaleHeight(4)),
                                                  model.users.isNotEmpty
                                                      ? Text(
                                                          model.users.first
                                                                  .ownerContact ??
                                                              '',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'outfit',
                                                              fontSize:
                                                                  ResponsiveSize
                                                                      .text(12),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        )
                                                      : const Text(
                                                          'Loading...'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveSize.scaleHeight(15)),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: ResponsiveSize.scaleWidth(9)),
                                  CircleAvatar(
                                    child: Image.asset(
                                      'assets/images/profile_address.png',
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                    radius: ResponsiveSize.scaleWidth(20),
                                    backgroundColor: const Color(0xFF010367),
                                  ),
                                  SizedBox(
                                      width: ResponsiveSize.scaleWidth(10)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Address',
                                            style: TextStyle(
                                              fontFamily: 'outfit',
                                              fontSize: ResponsiveSize.text(11),
                                              fontWeight: FontWeight.w400,
                                            )),
                                        SizedBox(
                                            height:
                                                ResponsiveSize.scaleHeight(4)),
                                        model.users.isNotEmpty
                                            ? Text(
                                                model.users.first
                                                        .ownerAddress ??
                                                    '',
                                                maxLines: 6,
                                                overflow: TextOverflow.visible,
                                                softWrap: true,
                                                style: TextStyle(
                                                    fontFamily: 'outfit',
                                                    fontSize:
                                                        ResponsiveSize.text(12),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              )
                                            : const Text('Loading...'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 25.fSize),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                        ResponsiveSize.scaleWidth(9.0)),
                                    child: Text('Financial Details',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'outfit',
                                          fontSize: ResponsiveSize.text(15),
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.fSize),
                              Row(
                                children: [
                                  SizedBox(width: ResponsiveSize.scaleWidth(9)),
                                  CircleAvatar(
                                    radius: ResponsiveSize.scaleWidth(20),
                                    backgroundColor: const Color(0xFF010367),
                                    child: Image.asset(
                                        'assets/images/profile_card.png',
                                        color: const Color(0xFFFFFFFF)),
                                  ),
                                  SizedBox(
                                      width: ResponsiveSize.scaleWidth(15)),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Bank',
                                            style: TextStyle(
                                              fontFamily: 'outfit',
                                              fontSize: ResponsiveSize.text(11),
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey.shade800,
                                            )),
                                        SizedBox(height: 4.fSize),
                                        Text(
                                          model.getBankInfo(),
                                          maxLines: 6,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontFamily: 'outfit',
                                            fontSize: ResponsiveSize.text(12),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveSize.scaleWidth(10)),
                                  CircleAvatar(
                                    radius: ResponsiveSize.scaleWidth(20),
                                    backgroundColor: const Color(0xFF010367),
                                    child: Image.asset(
                                      'assets/images/profile_card.png',
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  SizedBox(
                                      width: ResponsiveSize.scaleWidth(15)),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Account No.',
                                            style: TextStyle(
                                              fontFamily: 'outfit',
                                              fontSize: ResponsiveSize.text(11),
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey.shade800,
                                            )),
                                        SizedBox(height: 4.fSize),
                                        Text(
                                          model.getAccountNumber(),
                                          maxLines: 6,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontFamily: 'outfit',
                                            fontSize: ResponsiveSize.text(12),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveSize.scaleHeight(20)),
                            ],
                          ),
                        ),

                        SizedBox(height: 25.fSize),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.fSize),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ]),
                          child: Column(
                            children: [
                              SizedBox(height: ResponsiveSize.scaleHeight(10)),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Contact Us',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'outfit',
                                          fontSize: ResponsiveSize.text(15),
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            const Color(0xFFE9F6FF),
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
                                          fontFamily: 'outfit',
                                          fontSize: 16.fSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 20, color: Colors.grey),
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            const Color(0xFFFBF6FE),
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
                                          fontFamily: 'outfit',
                                          fontSize: 16.fSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 20, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.fSize),
                              InkWell(
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  launchUrl(
                                      Uri.parse('https://wa.me/60125626784'));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            const Color(0xFFE9FFEB),
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
                                          fontFamily: 'outfit',
                                          fontSize: 16.fSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 20, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveSize.scaleHeight(15)),
                            ],
                          ),
                        ),

                        SizedBox(height: 12.fSize),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // If the user can switch, show Switch User button
                            if (model.canSwitchUser) ...[
                              TextButton(
                                onPressed: () {
                                  // TODO: implement actual switch user action
                                  debugPrint('Switch User pressed');
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Color(0xFF000241), width: 2),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Switch User',
                                  style: TextStyle(
                                    fontFamily: 'outfit',
                                    color: Color(0xFF000241),
                                  ),
                                ),
                              ),
                              SizedBox(width: ResponsiveSize.scaleWidth(12)),
                            ],

                            // Logout button
                            TextButton(
                              onPressed: _isLoggingOut ? null : _handleLogout,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: Color(0xFF000241), width: 2),
                                  ),
                                ),
                              ),
                              child: _isLoggingOut
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontFamily: 'outfit',
                                        color: Color(0xFF000241),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        SizedBox(height: 35.fSize),

                        //terms and conditions and privacy policy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: ResponsiveSize.scaleWidth(130),
                              height: ResponsiveSize.scaleHeight(35),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFF3E51FF)),
                                color:
                                    const Color(0xFF3E51FF).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Container(
                                child: TextButton(
                                  onPressed: () {
                                    launchUrl(Uri.parse(
                                        'https://www.manamanasuites.com/terms-conditions'));

                                    ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      foregroundColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      shadowColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                    );
                                  },
                                  child: Text(
                                    'Terms and Conditions',
                                    style: TextStyle(
                                      fontFamily: 'outfit',
                                      fontSize: ResponsiveSize.text(10),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3E51FF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: ResponsiveSize.scaleWidth(15)),
                            Container(
                              width: ResponsiveSize.scaleWidth(130),
                              height: ResponsiveSize.scaleHeight(35),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFF3E51FF)),
                                color:
                                    const Color(0xFF3E51FF).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  launchUrl(Uri.parse(
                                      'https://www.manamanasuites.com/privacy-policy'));
                                  ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  );
                                },
                                child: Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontFamily: 'outfit',
                                    fontSize: ResponsiveSize.text(11),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3E51FF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0),
                ),
                child: const BottomNavBar(
                  currentIndex: 2,
                ),
              ));
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

// Note: helper widgets removed because they're unused in this view.
