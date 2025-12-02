import 'package:flutter/material.dart';

class NoticeDialog extends StatelessWidget {
  const NoticeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Notice',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),
              // Content
              const SingleChildScrollView(
                child: Text(
                  'Starting 1 December 2025, Mana Mana Suites Sdn. Bhd. will be transferring and novating all its rights, interests, obligations, and liabilities to Mana Mana Holdings Sdn. Bhd. (Company No: 202401029298 (1575146-T)), a wholly owned subsidiary of the public-listed EXSIM Hospitality Berhad (Company No: 198301000236 (95469-W)). \n\nAll existing terms and conditions in your Management Agreement will remain unchanged. \n\nYour trust means a lot to us. We have taken every step to ensure that your interests continue to be well protected throughout this transition. This corporate restructuring is part of our commitment to bringing even greater value and benefits to our stakeholders and guests. Exciting things are on the way—stay tuned!',
                  maxLines: null,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Outfit',
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF606060),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
