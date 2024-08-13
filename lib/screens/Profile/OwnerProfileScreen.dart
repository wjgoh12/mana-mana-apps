import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_owner_state.dart';
import 'package:mana_mana_app/provider/global_user_state.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  _OwnerProfileScreenState createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  bool _showMyInfo = true;

  @override
  Widget build(BuildContext context) {
    List<User> users = GlobalUserState.instance.getUsers(); 
    List<OwnerPropertyList> OwnerProperty = GlobalOwnerState.instance.getOwnerData(); 
    return Scaffold(
      appBar: AppBar(
              title: Text(
                'Owner\'s Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Color(0xFF2900B7), Color(0xFF120051)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 100.0)),                ),
              ),        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                    setState(() {
                      _showMyInfo = true;
                    });
                  },
                  child: Text(
                    'My Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _showMyInfo ? Color(0XFF4313E9) : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showMyInfo = false;
                    });
                  },
                  child: Text(
                    'Banking Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _showMyInfo ? Colors.grey : Color(0XFF4313E9),
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
                  color: _showMyInfo ? Color(0XFF4313E9) : Colors.grey,
                ),
              ),
            ),
            Flexible(
              child: FractionallySizedBox(
                // widthFactor: 0.5,
                child: Container(
                  height: 2,
                  color: _showMyInfo ? Colors.grey : Color(0XFF4313E9),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        if (_showMyInfo)
          // Info Card
          Card(
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
              padding: const EdgeInsets.only(left: 16.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '',
                        // users.first.ownerFullName ?? '',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // SizedBox(height: 8),
                  buildInfoRow(Icons.assignment_ind_outlined, 'Name'),
                  buildInfoInRow(users.first.ownerFullName.toString().isEmpty ? 'No Information' : users.first.ownerFullName.toString()),
                  buildInfoRow(Icons.phone, 'Contact No.'),
                  buildInfoInRow(users.first.ownerContact.toString().isEmpty ? 'No Information' : users.first.ownerContact.toString()),
                  buildInfoRow(Icons.email, 'Email'),
                  buildInfoInRow(users.first.ownerEmail.toString().isEmpty ? 'No Information' : users.first.ownerEmail.toString()),
                  buildInfoRow(Icons.location_on_outlined, 'Address'),
                  buildInfoInRow(users.first.ownerAddress.toString().isEmpty ? 'No Information' : users.first.ownerAddress.toString()),
                ],
              ),
            ),
                    ],
            ),
          )
        else
          // Banking Info Card (placeholder)
          Card(
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
              padding: const EdgeInsets.only(left: 16.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '',
                        // users.first.ownerFullName ?? '',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // OwnerProperty.first.bank.toString()
                  buildInfoRow(Icons.account_balance, 'Banking Details'),
                  buildInfoInRow(OwnerProperty.first.bank.toString().isEmpty ? 'No Information' : OwnerProperty.first.bank.toString()),                  
                  SizedBox(height: 8),
                  buildInfoInRow(OwnerProperty.first.accountnumber.toString().isEmpty ? 'No Information' : OwnerProperty.first.accountnumber.toString()),
                  SizedBox(height: 8),
                  // buildInfoRow(Icons.account_balance_wallet, 'Membership'),
                  // buildInfoInRow(OwnerProperty.first.accountnumber.toString()),
                  // SizedBox(height: 16),
                ],
              ),
            ),
                    ]
            )
          ),

        SizedBox(height: 16),

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
              SizedBox(height: 32),

              // Payout Overtime
              // Text(
              //   'Payout Overtime',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
      ],
    ),
  ),
)

    );
  }

  Widget buildInfoRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0XFF555555),  size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info,
              style: TextStyle(fontSize: 12, color: Color(0XFF555555)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoInRow(String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0).add(EdgeInsets.only(left: 5)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              info,
              style: TextStyle(fontSize: 15, color: Color(0XFF4313E9),fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}