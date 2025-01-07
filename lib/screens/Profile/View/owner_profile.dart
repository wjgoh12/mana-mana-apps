import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';


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
                  'Owner\'s Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF2900B7), Color(0xFF120051)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0)),
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
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
                                    fontSize: 20,
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
                                    fontSize: 20,
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
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: 8),
                                    buildInfoRow(
                                        Icons.assignment_ind_outlined, 'Name'),
                                    buildInfoInRow(model.users.first.ownerFullName
                                                .toString()
                                                .isEmpty ||
                                            model.users.first.ownerFullName == null
                                        ? 'No Information'
                                        : model.users.first.ownerFullName.toString()),
                                    buildInfoRow(Icons.phone, 'Contact No.'),
                                    buildInfoInRow(model.users.first.ownerContact
                                                .toString()
                                                .isEmpty ||
                                            model.users.first.ownerContact == null
                                        ? 'No Information'
                                        : model.users.first.ownerContact.toString()),
                                    buildInfoRow(Icons.email, 'Email'),
                                    buildInfoInRow(model.users.first.ownerEmail
                                                .toString()
                                                .isEmpty ||
                                            model.users.first.ownerEmail == null
                                        ? 'No Information'
                                        : model.users.first.ownerEmail.toString()),
                                    buildInfoRow(
                                        Icons.location_on_outlined, 'Address'),
                                    buildInfoInRow(model.users.first.ownerAddress
                                                .toString()
                                                .isEmpty ||
                                            model.users.first.ownerAddress == null
                                        ? 'No Information'
                                        : model.users.first.ownerAddress.toString()),
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
                                          // users.first.ownerFullName ?? '',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // OwnerProperty.first.bank.toString()
                                    buildInfoRow(Icons.account_balance,
                                        'Banking Details'),
                                    buildInfoInRow(model.ownerUnits.first.bank
                                                .toString()
                                                .isEmpty ||
                                            model.ownerUnits.first.bank == null
                                        ? 'No Information'
                                        : model.ownerUnits.first.bank.toString()),
                                    const SizedBox(height: 8),
                                    buildInfoInRow(model.ownerUnits
                                                .first.accountnumber
                                                .toString()
                                                .isEmpty ||
                                            model.ownerUnits.first.accountnumber ==
                                                null
                                        ? 'No Information'
                                        : model.ownerUnits.first.accountnumber
                                            .toString()),
                                    const SizedBox(height: 8),
                                    // buildInfoRow(Icons.account_balance_wallet, 'Membership'),
                                    // buildInfoInRow(OwnerProperty.first.accountnumber.toString()),
                                    // SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ])),

                      const SizedBox(height: 16),

                      // All Agreements
                      // Text(
                      //   'All Agreement(s)',
                      //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      // ),
                      // SizedBox(height: 8),
                      // Card(
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(8.0),
                      //   ),
                      //   elevation: 2,
                      //   child: ListTile(
                      //     title: Text('SAMPLE - SCARLETZ -Type_A-11-03 Agreement',style: TextStyle(color: Color(0xFF0044CC),fontSize: 15,fontWeight: FontWeight.w600)),
                      //     trailing: Text(
                      //       'PDF',
                      //       style: TextStyle(color: Color(0xFF0044CC),fontSize: 15,fontWeight: FontWeight.w600),
                      //     ),
                      //     onTap: () {
                      //       // Handle PDF tap
                      //     },
                      //   ),
                      // ),
                      const SizedBox(height: 32),

                      // Payout Overtime
                      // Text(
                      //   'Payout Overtime',
                      //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      // ),
                    ],
                  ),
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

