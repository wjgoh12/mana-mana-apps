import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter_read_details.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';


class AllNewsletter extends StatelessWidget {
  const AllNewsletter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/NewsletterBackground.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 10.fSize,
            ),
            Row(
              children: [
                SizedBox(
                  width: 10.fSize,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Newsletter(),
                      ),
                    );
                  },
                ),
              ],
            ),
        
          ],
        ),
    ),
    );
                
  }
}