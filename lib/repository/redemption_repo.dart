import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as _apiService;
import 'package:mana_mana_app/model/bookingHistory.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
import 'package:mana_mana_app/model/redemptionBalancePoints.dart';
import 'package:mana_mana_app/model/unitAvailablePoints.dart';
import 'package:mana_mana_app/provider/api_service.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/model/propertystate.dart';

class RedemptionRepository {
  final ApiService _apiService = ApiService();

  Future<List<UnitAvailablePoint>> getUnitAvailablePoints({
    required String email,
  }) async {
    final res = await _apiService.post(
      ApiEndpoint.getUnitAvailablePoint,
      data: {"email": email},
    );

    debugPrint("🔍 Raw API Response: $res");

    if (res == null) {
      debugPrint("⚠️ API returned null");
      return [];
    }

    if (res is Map) {
      debugPrint("📦 Response is a Map with keys: ${res.keys}");
      if (res['data'] is List) {
        debugPrint(
          "✅ Found 'data' list with length: ${(res['data'] as List).length}",
        );
        return (res['data'] as List)
            .map((json) => UnitAvailablePoint.fromJson(json))
            .toList();
      } else {
        debugPrint(
          "❌ 'data' field is not a List. It is: ${res['data']?.runtimeType}",
        );
      }
    }

    if (res is List) {
      debugPrint("✅ Response is a List with length: ${res.length}");
      return res.map((json) => UnitAvailablePoint.fromJson(json)).toList();
    }

    throw Exception("❌ Unexpected API response format: $res");
  }

  Future<List<BookingHistory>> getBookingHistory({
    required String email,
  }) async {
    // Check if you need to send email in the request body
    final data = {'email': email};

    final res = await _apiService.postJson(
      ApiEndpoint.getBookingHistory,
      data: data,
    );

    debugPrint("🔍 Raw booking history response: $res");

    if (res == null) return [];

    // Handle error responses
    if (res is Map && res.containsKey('error')) {
      throw Exception("API Error: ${res['error']}");
    }

    List<dynamic> listData;

    // If response is a Map with 'data' key
    if (res is Map && res.containsKey('data') && res['data'] is List) {
      listData = res['data'] as List;
    }
    // If response is already a List
    else if (res is List) {
      listData = res;
    } else {
      throw Exception("Unexpected API response format: $res");
    }

    // Convert each item into BookingHistory
    return listData
        .asMap()
        .entries
        .map((entry) => BookingHistory.fromJson(entry.value))
        .toList();
  }

  Future<List<String>> getAvailableStates() async {
    const allStates = [
      "Johor",
      "Kedah",
      "Kelantan",
      "Melaka",
      "Negeri Sembilan",
      "Pahang",
      "Penang",
      "Perak",
      "Perlis",
      "Sabah",
      "Sarawak",
      "Selangor",
      "Terengganu",
      "Kuala Lumpur",
      "Putrajaya",
      "Labuan",
    ];

    List<String> availableStates = [];

    for (final state in allStates) {
      try {
        final res = await _apiService.get(
          '${ApiEndpoint.getAllState}?state=${Uri.encodeQueryComponent(state)}',
        );

        if (res != null) {
          // If API returns locations list and it's not empty, keep this state
          final data = (res is Map && res['data'] is List) ? res['data'] : res;
          if (data is List && data.isNotEmpty) {
            availableStates.add(state);
          }
        }
      } catch (e) {
        debugPrint("⚠️ Error checking state $state: $e");
      }
    }

    debugPrint("✅ Available states: $availableStates");
    return availableStates;
  }

  Future<List<Propertystate>> getAllLocationsByState(String state) async {
    try {
      final res = await _apiService.get(
        '${ApiEndpoint.getAllState}?state=$state',
      );

      debugPrint("🔍 Raw API Response for locations: $res");

      if (res == null) return [];

      if (res is List) {
        return res.map((item) => Propertystate.fromJson(item)).toList();
      }

      throw Exception("Unexpected response: $res");
    } catch (e) {
      debugPrint("❌ Error in getAllLocationsByState: $e");
      rethrow;
    }
  }

  /// Get blocked dates
  Future<List<dynamic>> getCalendarBlockedDates({
    required String location,
    required String startDate,
    required String endDate,
  }) async {
    final data = {
      "location": location,
      "startDate": startDate,
      "endDate": endDate,
    };

    final res =
        await _apiService.post(ApiEndpoint.getCalendarBlockDate, data: data);

    if (res == null) return [];

    // Assuming API returns { "success": true, "data": [...] }
    final List<dynamic> dataList = res['data'] ?? [];

    return dataList;
  }

  List<CalendarBlockedDate> filterBlockedDatesForState(
      List<CalendarBlockedDate> allDates, String propertyState) {
    return allDates
        .where((date) =>
            date.state == "All" ||
            date.state.toLowerCase() == propertyState.toLowerCase())
        .toList();
  }

  Future<List<RedemptionBalancePoints>> getRedemptionBalancePoints({
    required String location,
    required String unitNo,
  }) async {
    final res = await _apiService.post(
      ApiEndpoint.getRedemptionAndBalancePoints,
      data: {"locationName": location, "unitNo": unitNo},
    );

    debugPrint("🔍 Raw API Response: $res");

    if (res == null) {
      debugPrint("⚠️ API returned null");
      return [];
    }

    if (res is Map) {
      debugPrint("📦 Response is a Map with keys: ${res.keys}");

      // ✅ Case 1: API wrapped in 'data' list
      if (res['data'] is List) {
        return (res['data'] as List)
            .map((json) => RedemptionBalancePoints.fromJson(
                Map<String, dynamic>.from(json)))
            .toList();
      }

      // ✅ Case 2: API returns a single object (your example)
      if (res.containsKey('redemptionPoints') &&
          res.containsKey('redemptionBalancePoints')) {
        return [
          RedemptionBalancePoints.fromJson(Map<String, dynamic>.from(res))
        ];
      }

      debugPrint("❌ Unhandled Map structure: $res");
    }

    if (res is List) {
      debugPrint("✅ Response is a List with length: ${res.length}");
      return res
          .map((json) =>
              RedemptionBalancePoints.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    throw Exception("❌ Unexpected API response format: $res");
  }
}
