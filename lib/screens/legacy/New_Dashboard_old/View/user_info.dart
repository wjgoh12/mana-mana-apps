import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/legacy/New_Dashboard_old/ViewModel/new_dashboardVM.dart';
import 'package:mana_mana_app/core/utils/size_utils.dart';

class UserInfo extends StatelessWidget {
  final NewDashboardVM model;
  const UserInfo({required this.model, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.width, bottom: 4.height),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/dashboard_gem.png',
                width: 8.width,
                height: 6.height,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 5.width),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.userNameAccount,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: AppDimens.fontSizeBig,
                      fontWeight: FontWeight.w600,
                      color: const Color(0XFF4313E9),
                    ),
                  ),
                  Text(
                    'Property Owner',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: AppDimens.fontSizeBig,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                      color: const Color(0XFF555555),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 2.height),
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
