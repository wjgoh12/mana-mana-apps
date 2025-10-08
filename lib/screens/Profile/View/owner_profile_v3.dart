import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/gradient_text.dart';
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
    model.fetchData();
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
    final OwnerProfileVM model = OwnerProfileVM();
    model.fetchData();

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
                      child: GradientText1(
                          text: 'Profile',
                          style: TextStyle(
                            fontFamily: 'outfit',
                            fontSize: responsiveFont(20),
                            fontWeight: FontWeight.w800,
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                          )),
                    ),
                  ],
                ),
              ),
              body: Padding(
                padding: EdgeInsets.only(bottom: responsiveHeight(100)),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.only(
                        left: responsiveWidth(15), top: responsiveHeight(15)),
                    child: Column(children: [
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
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
                                          fontFamily: 'outfit',
                                          fontSize: responsiveFont(20),
                                          fontWeight: FontWeight.bold,
                                          foreground: Paint()
                                            ..shader = const LinearGradient(
                                              colors: [
                                                Color(0xFFB82B7D),
                                                Color(0xFF3E51FF)
                                              ],
                                              begin: Alignment.bottomLeft,
                                              end: Alignment.topRight,
                                            ).createShader(const Rect.fromLTWH(
                                                0.0, 0.0, 300.0, 100.0)),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : const Text('Loading...'),
                                Text(
                                  'Property Owner',
                                  style: TextStyle(
                                      fontFamily: 'outfit',
                                      fontSize: ResponsiveSize.text(14),
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.fSize),

                      Row(
                        children: [
                          _buildRow(context, label: 'Name'),
                          SizedBox(width: responsiveWidth(8)),
                          model.users.isNotEmpty
                              ? _buildData(context,
                                  data: model.users.first.ownerFullName ?? '')
                              : const Text('Loading...'),
                        ],
                      ),
                      Row(
                        children: [
                          _buildRow(context, label: 'Identification'),
                          SizedBox(width: responsiveWidth(8)),
                          model.users.isNotEmpty
                              ? _buildData(context, data: '000000-00-0000')
                              : const Text('Loading...'),
                        ],
                      ),
                      Row(
                        children: [
                          _buildRow(context, label: 'Email'),
                          SizedBox(width: responsiveWidth(8)),
                          model.users.isNotEmpty
                              ? _buildData(context,
                                  data: model.users.first.ownerEmail ?? '')
                              : const Text('Loading...'),
                        ],
                      ),
                      Row(
                        children: [
                          _buildRow(context, label: 'Contact No.'),
                          SizedBox(width: responsiveWidth(8)),
                          model.users.isNotEmpty
                              ? _buildData(context,
                                  data: model.users.first.ownerContact ?? '')
                              : const Text('Loading...'),
                        ],
                      ),
                      Row(
                        children: [
                          _buildRow(context, label: 'Address'),
                          SizedBox(width: responsiveWidth(8)),
                          model.users.isNotEmpty
                              ? _buildData(context,
                                  data: model.users.first.ownerAddress ?? '')
                              : const Text('Loading...'),
                        ],
                      ),

                      SizedBox(height: 25.fSize),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Contact Us',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'outfit',
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

                      SizedBox(height: 65.fSize),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: _isLoggingOut ? null : _handleLogout,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  const Color(0xFFF2F2F2)),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                                    style: TextStyle(fontFamily: 'outfit'),
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
                          TextButton(
                            onPressed: () {
                              launchUrl(Uri.parse(
                                  'https://www.manamanasuites.com/terms-conditions'));

                              ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                overlayColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                shadowColor:
                                    WidgetStateProperty.all(Colors.transparent),
                              );
                            },
                            child: Text(
                              'Terms and Conditions',
                              style: TextStyle(
                                fontFamily: 'outfit',
                                fontSize: 14.fSize,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF3E51FF),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              launchUrl(Uri.parse(
                                  'https://www.manamanasuites.com/privacy-policy'));
                              ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                overlayColor:
                                    WidgetStateProperty.all(Colors.transparent),
                              );
                            },
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontFamily: 'outfit',
                                fontSize: 14.fSize,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF3E51FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
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

Widget _buildRow(BuildContext context, {required String label}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  double responsiveWidth(double value) =>
      (value / 375.0) * screenWidth; // base width

  double responsiveFont(double value) =>
      (value / 812.0) * screenHeight; // font scaling

  return SizedBox(
    width: responsiveWidth(140),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Image.asset('assets/images/$icon'),
          SizedBox(width: responsiveWidth(10)),
          Text(
            label,
            style:
                TextStyle(fontFamily: 'outfit', fontSize: responsiveFont(13)),
          ),
        ],
      ),
    ),
  );
}

Widget _buildData(BuildContext context, {required String data}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  double responsiveWidth(double value) =>
      (value / 375.0) * screenWidth; // base width
// base height
  double responsiveFont(double value) =>
      (value / 812.0) * screenHeight; // font scaling

  return SizedBox(
    width: responsiveWidth(190),
    child: Text(
      data,
      maxLines: 6,
      style: TextStyle(
          fontFamily: 'outfit',
          fontSize: responsiveFont(14),
          fontWeight: FontWeight.bold),
    ),
  );
}
