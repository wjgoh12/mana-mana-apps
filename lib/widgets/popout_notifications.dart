import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/popout_notification.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class PopoutNotifications extends StatelessWidget {
  final List<PopoutNotification> notifications;

  const PopoutNotifications({
    Key? key,
    required this.notifications,
  }) : super(key: key);

  Widget _buildNotificationCard(PopoutNotification notification) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveSize.scaleWidth(16),
        vertical: ResponsiveSize.scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (notification.img != null && notification.img!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.memory(
                base64Decode(notification.img!),
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error rendering image: $error');
                  return const SizedBox.shrink();
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.all(ResponsiveSize.scaleWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.title != null &&
                    notification.title!.isNotEmpty) ...[
                  Text(
                    notification.title!,
                  ),
                  SizedBox(height: ResponsiveSize.scaleHeight(8)),
                ],
                if (notification.description != null &&
                    notification.description!.isNotEmpty)
                  Text(
                    notification.description!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: notifications.map(_buildNotificationCard).toList(),
      ),
    );
  }
}
