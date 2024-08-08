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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
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
            SizedBox(width: 16),
            TextButton(
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
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 2,
                color: _showMyInfo ? Color(0XFF4313E9) : Colors.grey,
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: _showMyInfo ? Colors.grey : Color(0XFF4313E9),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        users.first.ownerFullName ?? '',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  buildInfoRow(Icons.phone, users.first.ownerContact ?? ''),
                  buildInfoRow(Icons.email, users.first.ownerEmail ?? ''),
                  buildInfoRow(Icons.location_on, users.first.ownerAddress ?? ''),
                ],
              ),
            ),
          )
        else
          // Banking Info Card (placeholder)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Banking Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  buildInfoRow(Icons.account_balance, OwnerProperty.first.bank.toString()),
                  buildInfoRow(Icons.account_balance_wallet, OwnerProperty.first.accountnumber.toString()),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

        SizedBox(height: 16),
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
          Icon(icon, color: Colors.grey),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              info,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}