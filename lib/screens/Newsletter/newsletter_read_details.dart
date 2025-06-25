
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';

class NewsletterReadDetails extends StatelessWidget {
  const NewsletterReadDetails({Key? key}) : super(key: key);


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
    ),
        );

}
}