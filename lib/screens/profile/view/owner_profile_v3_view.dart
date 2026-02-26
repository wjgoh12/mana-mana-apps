import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/dashboard/view/dashboard_view.dart';
import 'package:mana_mana_app/screens/profile/view_model/owner_profile_view_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/config/oauth2_provider.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

// ignore: camel_case_types
class OwnerProfile_v3 extends StatefulWidget {
  const OwnerProfile_v3({super.key});

  @override
  State<OwnerProfile_v3> createState() => _OwnerProfile_v3State();
}

// ignore: camel_case_types
class _OwnerProfile_v3State extends State<OwnerProfile_v3> {
  final OwnerProfileVM model = OwnerProfileVM();
  bool _isLoggingOut = false;
  bool _isReverting = false;

  @override
  void initState() {
    super.initState();
    model.fetchData().then((_) => model.checkRole());
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.fSize),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIcon(String image) {
    const grey = AppColors.primaryGrey;
    return CircleAvatar(
      radius: ResponsiveSize.scaleWidth(20),
      backgroundColor: grey,
      child: Image.asset(
        image,
        width: ResponsiveSize.scaleWidth(25),
        color: AppColors.white,
        height: ResponsiveSize.scaleHeight(25),
      ),
    );
  }

  String _formatIdentificationNumber(String idNumber) {
    final cleanId = idNumber.replaceAll(RegExp(r'[-\s]'), '');

    if (cleanId.length == 12 && RegExp(r'^\d{12}$').hasMatch(cleanId)) {
      return '${cleanId.substring(0, 6)}-${cleanId.substring(6, 8)}-${cleanId.substring(8, 12)}';
    }

    return idNumber;
  }

  Future<void> _handleRevert() async {
    if (_isReverting) return;

    setState(() {
      _isReverting = true;
    });

    try {
      final currentUserEmail =
          model.users.isNotEmpty ? model.users.first.email ?? '' : '';

      if (currentUserEmail.isEmpty) {
        debugPrint("⚠️ No current user email found for revert operation");
        return;
      }

      await model.cancelUser(currentUserEmail);

      if (kIsWeb) return; // Web performs hard reset, stop here

      GlobalDataManager().isSwitchUser = false;

      await model.refreshData();

      debugPrint("✅ Successfully reverted to original user");
    } catch (e) {
      debugPrint("❌ Revert failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isReverting = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // ✅ Clear impersonation state on logout
      await OAuth2Provider.instance.clearImpersonationState();

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

  Future<void> _showSwitchUserDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        String? validationMessage;
        final emailController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Switch User',
                      style: TextStyle(
                          fontFamily: AppFonts.outfit,
                          fontSize: AppDimens.fontSizeBig,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.fSize),
                    TextField(
                      controller: emailController,
                      onChanged: (value) {
                        if (validationMessage != null) {
                          setDialogState(() {
                            validationMessage = null;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter User Email',
                        labelStyle: TextStyle(
                          fontFamily: AppFonts.outfit,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (validationMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            validationMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel',
                              style: TextStyle(fontFamily: AppFonts.outfit)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.white),
                          ),
                          onPressed: () async {
                            final email = emailController.text.trim();
                            if (email.isEmpty) {
                              setDialogState(() {
                                validationMessage = 'Please insert the email';
                              });
                              return;
                            }

                            // ✅ Validate user first
                            final validateRes =
                                await model.validateSwitchUser(email);

                            bool isValidUser = false;
                            final body = validateRes['body']?.toString() ?? '';
                            isValidUser = validateRes['success'] == true &&
                                body.contains('Now valid viewing as:');

                            if (!isValidUser) {
                              setDialogState(() {
                                validationMessage = 'User Invalid';
                              });
                              return;
                            }

                            // ✅ Show confirmation dialog
                            final doSwitch = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text('Confirm Switch',
                                    style:
                                        TextStyle(fontFamily: AppFonts.outfit)),
                                content: Text(
                                    'Are you sure you want to switch to "$email"?',
                                    style: const TextStyle(
                                        fontFamily: AppFonts.outfit)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('No',
                                        style: TextStyle(
                                            fontFamily: AppFonts.outfit)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Yes',
                                        style: TextStyle(
                                            fontFamily: AppFonts.outfit)),
                                  ),
                                ],
                              ),
                            );

                            if (doSwitch != true) {
                              return;
                            }

                            // ✅ Close the switch user dialog before proceeding
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }

                            if (!mounted) return;

                            // ✅ Show full-screen loading overlay on the page
                            showDialog(
                              context: this.context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                  child: CircularProgressIndicator()),
                            );

                            // ✅ Perform the switch
                            final error =
                                await model.switchUserAndReload(email);

                            // ✅ PWA: switchUserAndReload navigates to Splashscreen, stop here
                            if (kIsWeb && error == null) return;

                            // ✅ Close loading overlay
                            if (mounted) {
                              Navigator.of(this.context).pop();
                            }

                            if (error != null) {
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Switch failed: $error')));
                              }
                              return;
                            }

                            if (!mounted) return;

                            // ✅ Mobile: Navigate to dashboard with fresh data
                            Navigator.of(this.context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const NewDashboardV3()),
                                (route) => false);
                          },
                          child: const Text('Confirm',
                              style: TextStyle(fontFamily: AppFonts.outfit)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContactOption({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    const yellow = Color(0xFFFFCF00);
    return InkWell(
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: ResponsiveSize.scaleWidth(20),
              backgroundColor: yellow,
              child: Image.asset(
                iconPath,
                width: ResponsiveSize.scaleWidth(20),
                height: ResponsiveSize.scaleHeight(20),
                color: iconColor,
              ),
            ),
            SizedBox(width: 20.fSize),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.outfit,
                fontSize: AppDimens.fontSizeBig,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const grey = AppColors.primaryGrey;

    double responsiveWidth(double value) => (value / 375.0) * screenWidth;
    double responsiveHeight(double value) => (value / 812.0) * screenHeight;

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
                    radius: 20.fSize,
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
                          color: grey,
                          fontFamily: AppFonts.outfit,
                          fontSize: AppDimens.fontSizeBig,
                          fontWeight: FontWeight.w700,
                        ),
                      )),
                  const Spacer(),
                  if (GlobalDataManager().isSwitchUser) ...[
                    TextButton(
                      onPressed: _isReverting ? null : _handleRevert,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: grey, width: 2),
                          ),
                        ),
                      ),
                      child: _isReverting
                          ? SizedBox(
                              width: ResponsiveSize.scaleWidth(16),
                              height: ResponsiveSize.scaleHeight(16),
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveSize.scaleWidth(8)),
                              child: const Text(
                                'Revert',
                                style: TextStyle(
                                  fontFamily: AppFonts.outfit,
                                  color: grey,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: ResponsiveSize.scaleWidth(8)),
                  ],
                  TextButton(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: grey, width: 2),
                        ),
                      ),
                    ),
                    child: _isLoggingOut
                        ? SizedBox(
                            width: ResponsiveSize.scaleWidth(16),
                            height: ResponsiveSize.scaleHeight(16),
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveSize.scaleWidth(10)),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: AppFonts.outfit,
                                color: grey,
                              ),
                            ),
                          ),
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
                      _buildSectionCard(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              fontFamily: AppFonts.outfit,
                                              fontSize: AppDimens.fontSizeBig,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        model.users.isNotEmpty
                                            ? Text(
                                                model.users.first
                                                        .ownerFullName ??
                                                    '',
                                                style: TextStyle(
                                                    fontFamily: AppFonts.outfit,
                                                    fontSize:
                                                        AppDimens.fontSizeBig,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(
                                                        0xFF606060)),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : const Text('Loading...'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20.fSize),
                            Row(
                              children: [
                                SizedBox(width: ResponsiveSize.scaleWidth(9)),
                                _buildIcon('assets/images/ic_icon.png'),
                                SizedBox(width: ResponsiveSize.scaleWidth(10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Identification',
                                      style: TextStyle(
                                          fontFamily: AppFonts.outfit,
                                          fontSize: AppDimens.fontSizeSmall,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(width: responsiveWidth(8)),
                                    model.users.isNotEmpty
                                        ? Text(
                                            _formatIdentificationNumber(
                                                model.users.first.ownerRefNo ??
                                                    ''),
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontFamily: AppFonts.outfit,
                                                fontSize:
                                                    AppDimens.fontSizeSmall,
                                                fontWeight: FontWeight.w400),
                                          )
                                        : Text(
                                            '000000-00-0000',
                                            maxLines: 6,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontFamily: AppFonts.outfit,
                                                fontSize:
                                                    AppDimens.fontSizeSmall,
                                                fontWeight: FontWeight.w400),
                                          ),
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
                                _buildIcon(
                                    'assets/images/profile_personal_email.png'),
                                SizedBox(width: ResponsiveSize.scaleWidth(10)),
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
                                                fontFamily: AppFonts.outfit,
                                                fontSize:
                                                    AppDimens.fontSizeSmall,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    ResponsiveSize.scaleHeight(
                                                        4)),
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
                                                        fontFamily:
                                                            AppFonts.outfit,
                                                        fontSize:
                                                            ResponsiveSize.text(
                                                                12),
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                : const Text('Loading...'),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          width: ResponsiveSize.scaleWidth(15)),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            _buildIcon(
                                                'assets/images/profile_phone.png'),
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
                                                    fontFamily: AppFonts.outfit,
                                                    fontSize:
                                                        AppDimens.fontSizeSmall,
                                                    fontWeight: FontWeight.w400,
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
                                                    : const Text('Loading...'),
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
                                _buildIcon('assets/images/profile_address.png'),
                                SizedBox(width: ResponsiveSize.scaleWidth(10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Address',
                                          style: TextStyle(
                                            fontFamily: AppFonts.outfit,
                                            fontSize: AppDimens.fontSizeSmall,
                                            fontWeight: FontWeight.w400,
                                          )),
                                      SizedBox(
                                          height:
                                              ResponsiveSize.scaleHeight(4)),
                                      model.users.isNotEmpty
                                          ? Text(
                                              model.users.first.ownerAddress ??
                                                  '',
                                              maxLines: 6,
                                              overflow: TextOverflow.visible,
                                              softWrap: true,
                                              style: TextStyle(
                                                  fontFamily: AppFonts.outfit,
                                                  fontSize:
                                                      AppDimens.fontSizeSmall,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          : const Text('Loading...'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25.fSize),
                            SizedBox(height: ResponsiveSize.scaleHeight(20)),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveSize.scaleHeight(20)),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(
                                      ResponsiveSize.scaleWidth(9.0)),
                                  child: Text('Financial Details',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: AppFonts.outfit,
                                        fontSize: AppDimens.fontSizeBig,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveSize.scaleWidth(9.0),
                                  vertical: 15.fSize),
                              child: buildFinancialDetails(
                                  model, _buildSectionCard),
                            ),
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
                                // ignore: deprecated_member_use
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
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
                                        fontFamily: AppFonts.outfit,
                                        fontSize: AppDimens.fontSizeBig,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.fSize),
                            _buildContactOption(
                              iconPath: 'assets/images/profile_email.png',
                              label: 'Email',
                              onTap: () async {
                                try {
                                  bool launched = false;

                                  if (kIsWeb) {
                                    // ✅ For PWA: Force open Gmail Website in New Tab
                                    final Uri gmailUri = Uri.parse(
                                      'https://mail.google.com/mail/?view=cm&fs=1&to=admin@manamana.my',
                                    );
                                    launched = await launchUrl(
                                      gmailUri,
                                      mode: LaunchMode.externalApplication,
                                      webOnlyWindowName: '_blank',
                                    );
                                  }

                                  // ✅ Fallback / Mobile: Use system default (mailto)
                                  if (!launched) {
                                    final Uri emailLaunchUri = Uri(
                                      scheme: 'mailto',
                                      path: 'admin@manamana.my',
                                    );
                                    launched = await launchUrl(
                                      emailLaunchUri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }

                                  if (!launched && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Email: admin@manamana.my'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  debugPrint('Email error: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Email: admin@manamana.my'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 12.fSize),
                            _buildContactOption(
                              iconPath: 'assets/images/profile_telephone.png',
                              label: 'Telephone',
                              iconColor: grey,
                              onTap: () {
                                launchUrl(Uri.parse('tel:+60192628155'));
                              },
                            ),
                            SizedBox(height: 12.fSize),
                            _buildContactOption(
                              iconPath: 'assets/images/profile_whatsapp.png',
                              label: 'Whatsapp',
                              iconColor: grey,
                              onTap: () {
                                launchUrl(
                                    Uri.parse('https://wa.me/60192628155'));
                              },
                            ),
                            SizedBox(height: ResponsiveSize.scaleHeight(15)),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.fSize),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (model.canSwitchUser) ...[
                            TextButton(
                              onPressed: () {
                                _showSwitchUserDialog();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.white),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: grey, width: 2),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Switch User',
                                style: TextStyle(
                                  fontFamily: AppFonts.outfit,
                                  color: grey,
                                ),
                              ),
                            ),
                            SizedBox(width: ResponsiveSize.scaleWidth(12)),
                          ],
                        ],
                      ),
                      SizedBox(height: 35.fSize),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: ResponsiveSize.scaleWidth(140),
                            height: ResponsiveSize.scaleHeight(35),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFF3E51FF)),
                              color: grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
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
                                  fontFamily: AppFonts.outfit,
                                  fontSize: AppDimens.fontSizeSmall,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
                              color: grey,
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
                                  fontFamily: AppFonts.outfit,
                                  fontSize: AppDimens.fontSizeSmall,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
              color: Colors.transparent,
              child: AbsorbPointer(
                // ignore: deprecated_member_use
                ignoringSemantics: false,
                absorbing: model.isLoading,
                child: Opacity(
                  opacity: model.isLoading ? 0.3 : 1.0,
                  child: const BottomNavBar(currentIndex: 2),
                ),
              ),
            ),
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
            style: const TextStyle(
                fontSize: AppDimens.fontSizeSmall, color: Color(0XFF555555)),
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
                fontSize: AppDimens.fontSizeBig,
                color: Color(0XFF4313E9),
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

Widget buildFinancialDetails(OwnerProfileVM model, buildSectionCard) {
  final Map<String, List<dynamic>> grouped = {};
  for (final unit in model.ownerUnits) {
    final key = (unit.location ?? 'Unknown').toString().trim();
    grouped.putIfAbsent(key, () => []).add(unit);
  }

  if (grouped.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No financial details available',
            style: TextStyle(
              fontFamily: AppFonts.outfit,
              fontSize: AppDimens.fontSizeSmall,
              color: Colors.grey.shade700,
            )),
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final entry in grouped.entries) ...[
        Text(
          entry.key,
          style: TextStyle(
            fontFamily: AppFonts.outfit,
            fontSize: AppDimens.fontSizeBig,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.fSize),
        Column(
          children: entry.value.map((unit) {
            final bank = (unit?.bank as String?) ?? model.getBankInfo();
            final account =
                (unit?.accountnumber as String?) ?? model.getAccountNumber();
            final unitNo = (unit?.unitno as String?) ?? '-';

            return Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: buildSectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Unit No.',
                            style: TextStyle(
                              fontFamily: AppFonts.outfit,
                              fontSize: AppDimens.fontSizeSmall,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            ' $unitNo',
                            style: TextStyle(
                              fontFamily: AppFonts.outfit,
                              fontSize: AppDimens.fontSizeSmall,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveSize.scaleHeight(10)),
                      Row(
                        children: [
                          SizedBox(width: ResponsiveSize.scaleWidth(9)),
                          CircleAvatar(
                            radius: ResponsiveSize.scaleWidth(20),
                            backgroundColor: AppColors.primaryGrey,
                            child: Image.asset('assets/images/profile_card.png',
                                color: AppColors.primaryYellow),
                          ),
                          SizedBox(width: ResponsiveSize.scaleWidth(15)),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bank',
                                    style: TextStyle(
                                      fontFamily: AppFonts.outfit,
                                      fontSize: AppDimens.fontSizeSmall,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade800,
                                    )),
                                SizedBox(height: 4.fSize),
                                Text(
                                  bank,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontFamily: AppFonts.outfit,
                                    fontSize: AppDimens.fontSizeSmall,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: ResponsiveSize.scaleWidth(10)),
                          CircleAvatar(
                            radius: ResponsiveSize.scaleWidth(20),
                            backgroundColor: AppColors.primaryGrey,
                            child: Image.asset(
                              'assets/images/profile_card.png',
                              color: AppColors.primaryYellow,
                            ),
                          ),
                          SizedBox(width: ResponsiveSize.scaleWidth(15)),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Account No.',
                                    style: TextStyle(
                                      fontFamily: AppFonts.outfit,
                                      fontSize: AppDimens.fontSizeSmall,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade800,
                                    )),
                                SizedBox(height: 4.fSize),
                                Text(
                                  account,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontFamily: AppFonts.outfit,
                                    fontSize: AppDimens.fontSizeSmall,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ],
  );
}
