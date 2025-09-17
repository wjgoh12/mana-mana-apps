import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as _apiService;
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/bookingHistory.dart';
import 'package:mana_mana_app/model/bookingRoom.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
import 'package:mana_mana_app/model/redemptionBalancePoints.dart';
import 'package:mana_mana_app/model/roomType.dart';
import 'package:mana_mana_app/model/unitAvailablePoints.dart';
import 'package:mana_mana_app/provider/api_service.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/model/propertystate.dart';

class RedemptionRepository {
  final ApiService _apiService = ApiService();

  String _getLocationName(String code) {
    switch (code.toUpperCase()) {
      case "EXPR":
        return "EXPRESSIONZ";
      case "CEYL":
        return "CEYLONZ";
      case "SCAR":
        return "SCARLETZ";
      case "MILL":
        return "MILLERZ";
      case "MOSS":
        return "MOSSAZ";
      case "PAXT":
        return "PAXTONZ";
      default:
        return code; // Return original code if no match found
    }
  }

  Future<List<UnitAvailablePoint>> getUnitAvailablePoints({
    required String email,
  }) async {
    final res = await _apiService.post(
      ApiEndpoint.getUnitAvailablePoint,
      data: {"email": email},
    );

    // debugPrint("🔍 Raw API Response: $res");

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
      // debugPrint("✅ Response is a List with length: ${res.length}");
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

    // debugPrint("🔍 Raw booking history response: $res");

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

    // debugPrint("✅ Available states: $availableStates");
    return availableStates;
  }

  Future<List<Propertystate>> getAllLocationsByState(String state) async {
    try {
      final res = await _apiService.get(
        '${ApiEndpoint.getAllState}?state=$state',
      );

      // debugPrint("🔍 Raw API Response for locations: $res");

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

  Future<List<CalendarBlockedDate>> getCalendarBlockedDates() async {
    final res = await _apiService.get(ApiEndpoint.getCalendarBlockDate);
    // debugPrint("Blocked dates raw API response: $res");

    if (res == null) return [];

    List<CalendarBlockedDate> allDates = [];

    // If API returns a List directly
    if (res is List) {
      allDates = res.map((e) => CalendarBlockedDate.fromJson(e)).toList();
    }
    // If API returns a Map with 'data' field
    else if (res is Map && res['data'] is List) {
      allDates = (res['data'] as List)
          .map((e) => CalendarBlockedDate.fromJson(e))
          .toList();
    }

    return allDates;
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

    // debugPrint("🔍 Raw API Response: $res");

    if (res == null) {
      debugPrint("⚠️ API returned null");
      return [];
    }

    if (res is Map) {
      // debugPrint("📦 Response is a Map with keys: ${res.keys}");

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

  Future<List<RoomType>> getRoomTypes({
    required String state,
    required String bookingLocationName,
    int? rooms,
    DateTime? arrivalDate,
    DateTime? departureDate,
  }) async {
    final body = {
      "state": state,
      "bookingLocationName": bookingLocationName,
      if (rooms != null) "rooms": rooms,
      if (arrivalDate != null)
        "arrivalDate": DateFormat('yyyy-MM-dd').format(arrivalDate),
      if (departureDate != null)
        "departureDate": DateFormat('yyyy-MM-dd').format(departureDate),
    };

    debugPrint("📤 Request body for getRoomTypes: $body");

    final res = await _apiService.post(
      ApiEndpoint.getRoomType,
      data: body,
    );

    // debugPrint("🔍 Raw API Response for Room Types: $res");

    if (res == null) return [];

    if (res is List) {
      return res
          .map((json) => RoomType.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    if (res is Map && res['data'] is List) {
      return (res['data'] as List)
          .map((json) => RoomType.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    throw Exception("❌ Unexpected API response format for Room Types: $res");
  }

  Future<Map<String, dynamic>?> submitBooking({
    required BookingRoom bookingRoom,
    required UnitAvailablePoint point,
    required List<Propertystate> propertyStates,
    required DateTime? checkIn,
    required DateTime? checkOut,
    required int quantity,
    required int points,
    required String guestName,
  }) async {
    // debugPrint("🔎 point.location raw: '${point.location}'");
    // debugPrint(
    //     "🔎 resolved full location: '${_getLocationName(point.location)}'");
    // debugPrint("🔎 propertyStates length: ${propertyStates.length}");
    for (var ps in propertyStates) {
      // debugPrint(
      //     "🔎 propertyState: location='${ps.locationName}', state='${ps.stateName}', pic='${ps.pic}'");
    }

    // Match location → state (owner property’s state)
    final matchingState = propertyStates.firstWhere(
      (state) =>
          state.locationName.toUpperCase() ==
          _getLocationName(point.location).toUpperCase(),
      orElse: () => Propertystate(pic: '', stateName: '', locationName: ''),
    );

    final body = {
      "stateName": matchingState.stateName,
      "locationName": _getLocationName(
          point.location), // ✅ use full location name like "SCARLETZ"
      "unitNo": point.unitNo,
      "bookingLocationName": bookingRoom.bookingLocationName,
      "typeName": bookingRoom.roomType.roomTypeName,
      "arrivalDate":
          checkIn != null ? DateFormat('yyyy-MM-dd').format(checkIn) : "",
      "departureDate":
          checkOut != null ? DateFormat('yyyy-MM-dd').format(checkOut) : "",
      "rooms": quantity.toString(), // ✅ cast to string
      "totalRate": points.toString(), // ✅ cast to string
      "guestName": guestName.trim(),
    };

    debugPrint("📤 Request body for booking: $body");

    final res = await _apiService.post(
      ApiEndpoint.saveBookingDetailsAndRoomType,
      data: body,
    );

    // debugPrint("🔍 Raw API Response for Booking: $res");

    if (res == null) return null;
    if (res is Map<String, dynamic>) return res;

    throw Exception("❌ Unexpected API response format for Booking: $res");
  }
}
