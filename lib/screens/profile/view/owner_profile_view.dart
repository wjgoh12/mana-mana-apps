import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/profile/view_model/owner_profile_view_model.dart';
import 'package:mana_mana_app/widgets/bottom_nav_bar.dart';

class OwnerProfile extends StatelessWidget {
  const OwnerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final OwnerProfileVM model = OwnerProfileVM();
    model.fetchData();
    return ListenableBuilder(
        listenable: model,
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFFB82B7D), Color(0xFF3E51FF)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0)),
                ),
              ),
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                model.updateShowMyInfo(true);
                              },
                              child: Text(
                                'My Info',
                                style: TextStyle(
                                  fontSize: AppDimens.fontSizeBig,
                                  fontWeight: FontWeight.w400,
                                  color: model.showMyInfo
                                      ? const Color(0XFF4313E9)
                                      : const Color(0xFFBBBCBE),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                model.updateShowMyInfo(false);
                              },
                              child: Text(
                                'Banking Info',
                                style: TextStyle(
                                  fontSize: AppDimens.fontSizeBig,
                                  fontWeight: FontWeight.w400,
                                  color: model.showMyInfo
                                      ? const Color(0xFFBBBCBE)
                                      : const Color(0XFF4313E9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            // widthFactor: 0.5,
                            child: Container(
                              height: 2,
                              color: model.showMyInfo
                                  ? const Color(0XFF4313E9)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        Flexible(
                          child: FractionallySizedBox(
                            // widthFactor: 0.5,
                            child: Container(
                              height: 2,
                              color: model.showMyInfo
                                  ? Colors.grey
                                  : const Color(0XFF4313E9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (model.showMyInfo)
                      // Info Card
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 2,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 10,
                              child: Image.asset(
                                'assets/images/patterns_unit_revenue.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '',
                                        // users.first.ownerFullName ?? '',
                                        style: TextStyle(
                                            fontSize: AppDimens.fontSizeSmall,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(height: 8),
                                  buildInfoRow(
                                      Icons.assignment_ind_outlined, 'Name'),
                                  buildInfoInRow(model.getOwnerName()),
                                  buildInfoRow(Icons.phone, 'Contact No.'),
                                  buildInfoInRow(model.getOwnerContact()),
                                  buildInfoRow(Icons.email, 'Email'),
                                  buildInfoInRow(model.getOwnerEmail()),
                                  buildInfoRow(
                                      Icons.location_on_outlined, 'Address'),
                                  buildInfoInRow(model.getOwnerAddress()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Banking Info Card (placeholder)
                      Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 2,
                          child: Stack(children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 10,
                              child: Image.asset(
                                'assets/images/patterns_unit_revenue.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '',
                                        style: TextStyle(
                                            fontSize: AppDimens.fontSizeSmall,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  buildInfoRow(
                                      Icons.account_balance, 'Banking Details'),
                                  buildInfoInRow(model.getBankInfo()),
                                  const SizedBox(height: 8),
                                  buildInfoInRow(model.getAccountNumber()),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ])),

                    const SizedBox(height: 16),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 3),
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
