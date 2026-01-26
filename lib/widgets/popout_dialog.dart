import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/model/popout_notification.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class PopoutDialog extends StatelessWidget {
  final PopoutNotification notification;
  final VoidCallback? onDismiss;

  const PopoutDialog({
    Key? key,
    required this.notification,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                notification.title ?? 'Notification',
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notification.img != null &&
                        notification.img!.isNotEmpty)
                      _buildImage(notification.img!),
                    if (notification.description != null &&
                        notification.description!.isNotEmpty)

                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: HtmlWidget(
                          notification.description!,
                          onTapUrl: (url) async {
                            try {
                              return await launchUrl(Uri.parse(url));
                            } catch (e) {
                              debugPrint('Could not launch url: $e');
                              return false;
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E51FF),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imgData) {
    try {
      // Check if it's base64 encoded image data
      if (imgData.length > 100) {
        Uint8List bytes = base64Decode(imgData);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading image: $error');
              return const SizedBox.shrink();
            },
          ),
        );
      } else if (imgData.startsWith('http')) {
        // It's a URL
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imgData,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading network image: $error');
              return const SizedBox.shrink();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    }
    return const SizedBox.shrink();
  }


}
