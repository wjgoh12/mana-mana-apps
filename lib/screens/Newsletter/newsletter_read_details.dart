
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Newsletter/newsletter.dart';
import 'package:mana_mana_app/screens/Newsletter/ViewModel/newsletter_VM.dart';
import 'package:mana_mana_app/widgets/size_utils.dart';
class NewsletterReadDetails extends StatelessWidget {

  const NewsletterReadDetails({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    final model = NewsletterVM();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsletter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Newsletter Title',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 380, 
                
                  ),
                  child: const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                    
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
          ],
          ),

      )
    );

  }

  


  
}
