import 'dart:convert';
import 'package:mana_mana_app/model/bookingHistory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingSubmissionService {
  static const String _submissionTimesKey = 'booking_submission_times';

  // Save submission time for a booking
  static Future<void> saveSubmissionTime(BookingHistory booking) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing submission times
    final String? storedData = prefs.getString(_submissionTimesKey);
    Map<String, String> submissionTimes = {};

    if (storedData != null) {
      submissionTimes = Map<String, String>.from(jsonDecode(storedData));
    }

    // Add or update submission time for this booking
    submissionTimes[booking.storageKey] = DateTime.now().toIso8601String();

    // Save back to SharedPreferences
    await prefs.setString(_submissionTimesKey, jsonEncode(submissionTimes));
  }

  // Get submission time for a booking
  static Future<DateTime?> getSubmissionTime(BookingHistory booking) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_submissionTimesKey);

    if (storedData != null) {
      final submissionTimes = Map<String, String>.from(jsonDecode(storedData));
      final submissionTimeStr = submissionTimes[booking.storageKey];

      if (submissionTimeStr != null) {
        return DateTime.parse(submissionTimeStr);
      }
    }

    return null;
  }

  // Clear all stored submission times
  static Future<void> clearAllSubmissionTimes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_submissionTimesKey);
  }
}
