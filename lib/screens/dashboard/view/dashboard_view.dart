import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/screens/dashboard/view/profit_box.dart';
import 'package:mana_mana_app/screens/dashboard/view_model/dashboard_view_model.dart';
import 'package:mana_mana_app/widgets/overview_card.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';
import 'package:mana_mana_app/widgets/top_bar.dart';
import 'package:provider/provider.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewDashboardV3 extends StatelessWidget {
  const NewDashboardV3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: GlobalDataManager()),
        ChangeNotifierProvider(
          create: (_) {
            final model = NewDashboardVM_v3();

            model.fetchData();
            return model;
          },
        ),
      ],
      child: Consumer<NewDashboardVM_v3>(
        builder: (context, model, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            model.checkAndShowNewFeaturesDialog(context);
            model.checkAndShowPopoutDialog(context);
          });

          final ValueNotifier<bool> isRefreshing = ValueNotifier(false);
          final isMobile = MediaQuery.of(context).size.width < 600;
          final screenWidth = MediaQuery.of(context).size.width;

          final horizontalPadding = screenWidth * 0.05;

          ResponsiveSize.init(context);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        pinned: true,
                        floating: false,
                        expandedHeight: _getExpandedHeight(context),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        systemOverlayStyle: const SystemUiOverlayStyle(
                          statusBarColor: Colors.transparent,
                          statusBarIconBrightness: Brightness.dark,
                          statusBarBrightness: Brightness.light,
                        ),
                        title: innerBoxIsScrolled
                            ? Text(
                                'Dashboard',
                                style: TextStyle(
                                  fontSize: AppDimens.fontSizeBig,
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              )
                            : null,
                        centerTitle: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildHeaderContent(
                              context, model, isRefreshing, innerBoxIsScrolled),
                          collapseMode: CollapseMode.pin,
                        ),
                      ),
                    ],
                    body: RefreshIndicator(
                      onRefresh: () async {
                        isRefreshing.value = true;
                        await model.refreshData();
                        isRefreshing.value = false;
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              alignment: Alignment.center,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hey, ${model.userNameAccount} 👋',
                                        style: GoogleFonts.outfit(
                                          fontSize: AppDimens.fontSizeBig,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF383838),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.height),
                                  Row(
                                    children: [
                                      Text(
                                        'Simple, Timeless \nAssets Management',
                                        style: GoogleFonts.outfit(
                                          fontSize: AppDimens.fontSizeLarge,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryGrey,
                                        ),
                                      ).animate(
                                        onPlay: (controller) {
                                          if (isRefreshing.value) {
                                            controller.repeat();
                                          } else {
                                            controller.stop();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: screenWidth,
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding, vertical: 14),
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Overview'),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  OverviewCard(model: model),
                                ],
                              ),
                            ),
                            const ProfitBox(),
                            SizedBox(height: isMobile ? 16.height : 24.height),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (model.isLoading)
                    Positioned.fill(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: model.isLoading ? 1.0 : 0.0,
                        child: Container(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: RepaintBoundary(
                              child: _SmartLoadingDialog(),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                    child: const BottomNavBar(currentIndex: 0),
                  ),
                ),
              ),
              extendBody: true,
            ),
          );
        },
      ),
    );
  }

  double _getExpandedHeight(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const topBarHeight = 60.0;

    return statusBarHeight + topBarHeight;
  }

  Widget _buildHeaderContent(BuildContext context, dynamic model,
      ValueNotifier<bool> isRefreshing, bool innerBoxIsScrolled) {
    return Container(
      width: 100.width,
      color: Colors.white,
      child: !innerBoxIsScrolled ? topBar(context, () {}) : SizedBox.shrink(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppFonts.outfit,
          fontSize: AppDimens.fontSizeBig,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _SmartLoadingDialog extends StatelessWidget {
  const _SmartLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E51FF)),
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: AppDimens.fontSizeBig,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.outfit,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
