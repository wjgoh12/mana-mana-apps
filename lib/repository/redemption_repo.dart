import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as _apiService;
import 'package:mana_mana_app/model/bookingHistory.dart';
import 'package:mana_mana_app/model/unitAvailablePoints.dart';
import 'package:mana_mana_app/provider/api_service.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/model/propertystate.dart';

class RedemptionRepository {
  final ApiService _apiService = ApiService();

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
    return res ?? [];
  }

  Future<List<UnitAvailablePoint>> getUnitAvailablePoints() async {
    final res = await _apiService.post(ApiEndpoint.getUnitAvailablePoint);

    debugPrint("🔍 Raw API Response: $res");

    if (res == null) {
      debugPrint("⚠️ API returned null");
      return [];
    }

    if (res is Map) {
      debugPrint("📦 Response is a Map with keys: ${res.keys}");
      if (res['data'] is List) {
        debugPrint(
            "✅ Found 'data' list with length: ${(res['data'] as List).length}");
        return (res['data'] as List)
            .map((json) => UnitAvailablePoint.fromJson(json))
            .toList();
      } else {
        debugPrint(
            "❌ 'data' field is not a List. It is: ${res['data']?.runtimeType}");
      }
    }

    if (res is List) {
      debugPrint("✅ Response is a List with length: ${res.length}");
      return res.map((json) => UnitAvailablePoint.fromJson(json)).toList();
    }

    throw Exception("❌ Unexpected API response format: $res");
  }

  Future<List<BookingHistory>> getBookingHistory(
      {required String email}) async {
    // Check if you need to send email in the request body
    final data = {'email': email};

    final res =
        await _apiService.postJson(ApiEndpoint.getBookingHistory, data: data);

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

  Future<List<Propertystate>> getAllLocationsByState(String state) async {
    try {
      final res =
          await _apiService.get("${ApiEndpoint.getAllState}?state=$state");

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

  Future<List<String>> getAllStates() async {
    try {
      debugPrint("🔍 Fetching all available states from API");

      final response = await _apiService.postJson(
        "/mobile/enqs/redemption/getAllStates", // <-- adjust this path
      );

      if (response == null || response["data"] == null) {
        throw Exception("Invalid response for states");
      }

      // Assume API returns something like: { "data": [ { "state": "Johor" }, ... ] }
      final states =
          (response["data"] as List).map((e) => e["state"].toString()).toList();

      debugPrint("✅ Available states: $states");
      return states;
    } catch (e) {
      debugPrint("❌ Error fetching states: $e");
      return [];
    }
  }
}
