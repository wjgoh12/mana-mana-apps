import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/booking_history.dart';
import 'package:mana_mana_app/model/booking_room.dart';
import 'package:mana_mana_app/model/calendar_blocked_date.dart';
import 'package:mana_mana_app/model/property_state.dart';
import 'package:mana_mana_app/model/redemption_balance_points.dart';
import 'package:mana_mana_app/model/roomtype.dart';
import 'package:mana_mana_app/model/unit_available_points.dart';
import 'package:mana_mana_app/provider/api_service.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';

class RedemptionRepository {
  final ApiService _apiService = ApiService();

  Future<List<UnitAvailablePoint>> getUnitAvailablePoints({
    required String email,
  }) async {
    debugPrint('1');
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
    final bookings = listData
        .asMap()
        .entries
        .map((entry) => BookingHistory.fromJson(entry.value))
        .toList();

    // ✅ Sort by creation date descending (newest first)
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return bookings;
  }

  // Cache to avoid redundant API calls
  Map<String, List<PropertyState>>? _stateLocationsCache;
  DateTime? _cacheTime;

  // Cache expiry: 5 minutes
  bool get _isCacheValid {
    if (_cacheTime == null || _stateLocationsCache == null) return false;
    return DateTime.now().difference(_cacheTime!) < const Duration(minutes: 5);
  }

  Future<List<String>> getAvailableStates() async {
    try {
      // ✅ Use cached data if available
      if (_isCacheValid && _stateLocationsCache != null) {
        final cachedCount = _stateLocationsCache!.keys.length;
        // debugPrint("✅ Using cached states: $cachedCount");

        // If cache is empty, force a refresh
        if (cachedCount == 0) {
          debugPrint("⚠️ Cached states is 0, forcing fresh fetch...");
          _cacheTime = null; // Invalidate cache
          _stateLocationsCache = null;
        } else {
          return _stateLocationsCache!.keys.toList();
        }
      }

      debugPrint("🔄 Fetching all states and locations in one go...");

      // ✅ Fetch all locations for all states and cache them
      await _fetchAndCacheAllLocations();

      final resultCount = _stateLocationsCache?.keys.length ?? 0;
      debugPrint("✅ Fetch complete. Total states with locations: $resultCount");

      return _stateLocationsCache?.keys.toList() ?? [];
    } catch (e) {
      debugPrint("❌ Error fetching available states: $e");
      return [];
    }
  }

  Future<void> _fetchAndCacheAllLocations() async {
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

    _stateLocationsCache = {};

    // Fetch all states in parallel
    final futures = allStates.map((state) => _fetchLocationsForState(state));
    await Future.wait(futures);

    _cacheTime = DateTime.now();
    debugPrint(
        "✅ Cached ${_stateLocationsCache!.keys.length} states with locations");
  }

  Future<void> _fetchLocationsForState(String state) async {
    try {
      final url =
          '${ApiEndpoint.getAllState}?state=${Uri.encodeQueryComponent(state)}';
      debugPrint('🔎 Fetching locations for state: $state -> $url');
      final res = await _apiService.get(
        url,
      );

      if (res == null) {
        // debugPrint('🔍 Response for $state: (null) - API returned null');
        return;
      }

      // debugPrint('🔍 Response for $state: ${res.runtimeType}');

      // Log first 500 chars of response for debugging
      final resStr = res.toString();
      if (resStr.length > 500) {
        debugPrint('   Data preview: ${resStr.substring(0, 500)}...');
      } else {
        debugPrint('   Data: $resStr');
      }

      final List<dynamic> data;
      if (res is Map && res['data'] is List) {
        data = res['data'] as List;
        debugPrint('   Extracted ${data.length} items from Map.data');
      } else if (res is List) {
        data = res;
        debugPrint('   Response is List with ${data.length} items');
      } else {
        debugPrint('   ⚠️ Unexpected response type, cannot extract data');
        return;
      }

      final locations = data
          .where((item) =>
              item is Map &&
              item['stateName']?.toString().toLowerCase() ==
                  state.toLowerCase())
          .map((item) => PropertyState.fromJson(item))
          .toList();
      // Only cache states that have locations
      debugPrint('➡️ Found ${locations.length} locations for $state');
      if (locations.isNotEmpty) {
        _stateLocationsCache![state] = locations;
      } else {
        debugPrint('ℹ️ No locations for state $state, skipping cache entry.');
      }
    } catch (e) {
      // debugPrint("⚠️ Error fetching locations for $state: $e");
    }
  }

  Future<List<PropertyState>> getAllLocationsByState(String state) async {
    try {
      if (_isCacheValid && _stateLocationsCache != null) {
        final cached = _stateLocationsCache![state];
        if (cached != null) {
          // debugPrint("✅ Using cached locations for $state: ${cached.length}");
          return cached;
        }
      }

      await _fetchLocationsForState(state);
      return _stateLocationsCache?[state] ?? [];
    } catch (e) {
      debugPrint("❌ Error in getAllLocationsByState for $state: $e");
      rethrow;
    }
  }

  void clearLocationCache() {
    _stateLocationsCache = null;
    _cacheTime = null;
    debugPrint("🗑️ Location cache cleared");
  }

  Future<List<CalendarBlockedDate>> getCalendarBlockedDates() async {
    final res = await _apiService.get(ApiEndpoint.getCalendarBlockDate);

    if (res == null) return [];

    List<CalendarBlockedDate> allDates = [];

    if (res is List) {
      allDates = res.map((e) => CalendarBlockedDate.fromJson(e)).toList();
    } else if (res is Map && res['data'] is List) {
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

    if (res == null) {
      debugPrint("⚠️ API returned null");
      return [];
    }

    if (res is Map) {
      if (res['data'] is List) {
        return (res['data'] as List)
            .map((json) => RedemptionBalancePoints.fromJson(
                Map<String, dynamic>.from(json)))
            .toList();
      }

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
    required List<PropertyState> propertyStates,
    required DateTime? checkIn,
    required DateTime? checkOut,
    required int quantity,
    required double points,
    required String guestName,
    String remark = '',
  }) async {
    final allLocations = GlobalDataManager().getAllLocationsFromAllStates();

    // 1. Resolve Source Property (the hotel the user owns a unit in)
    final sourceProperty = allLocations.firstWhere(
      (loc) =>
          loc.locationName.toUpperCase() == point.location.toUpperCase() ||
          (point.location.length >= 3 &&
              loc.locationName
                  .toUpperCase()
                  .startsWith(point.location.toUpperCase())),
      orElse: () =>
          PropertyState(pic: '', stateName: '', locationName: point.location),
    );

    // 2. For rooms with no specific location, use source property's state
    //    Otherwise, resolve the destination property
    // Resolve the stay property (the hotel you are visiting)
    final destinationProperty = allLocations.firstWhere(
      (loc) =>
          loc.locationName.toUpperCase() ==
          bookingRoom.bookingLocationName.toUpperCase(),
      orElse: () => PropertyState(
          pic: '',
          stateName: bookingRoom.roomType.state ?? '',
          locationName: bookingRoom.bookingLocationName),
    );

    // If the room object has its own state/location, use it.
    // Otherwise, use the hotel you selected (destinationProperty).
    String effectiveStateName = (bookingRoom.roomType.state != null &&
            bookingRoom.roomType.state!.isNotEmpty)
        ? bookingRoom.roomType.state!
        : destinationProperty.stateName;

    String effectiveBookingLocation =
        (bookingRoom.roomType.bookingLocationName != null &&
                bookingRoom.roomType.bookingLocationName!.isNotEmpty)
            ? bookingRoom.roomType.bookingLocationName!
            : destinationProperty.locationName;

    debugPrint(
        "🏨 Final Stay Info: $effectiveBookingLocation ($effectiveStateName)");

    debugPrint("🚀 Booking Submission:");
    debugPrint(
        "   📍 Points from: ${sourceProperty.locationName} - Unit: ${point.unitNo}");
    debugPrint(
        "   🏨 Booking at: $effectiveBookingLocation ($effectiveStateName)");
    debugPrint("   🛏️  Room: ${bookingRoom.roomType.roomTypeName}");

    debugPrint("🚀 Booking Submission Details:");
    debugPrint("   📍 Points Source (locationName): ${point.location}");
    debugPrint(
        "   🏨 Stay Location (bookingLocationName): ${bookingRoom.bookingLocationName}");
    debugPrint(
        "   🛏️  Room (typeName): ${_sanitizeRoomTypeName(bookingRoom.roomType.roomTypeDesc)}");

    final body = {
      "stateName": effectiveStateName,
      "locationName":
          point.location, // Use short code (e.g. 22M, MOSS) as requested
      "unitNo": point.unitNo,
      "bookingLocationName": effectiveBookingLocation,
      "typeName": _sanitizeRoomTypeName(
          bookingRoom.roomType.roomTypeDesc), // Send clean Description
      "arrivalDate":
          checkIn != null ? DateFormat('yyyy-MM-dd').format(checkIn) : "",
      "departureDate":
          checkOut != null ? DateFormat('yyyy-MM-dd').format(checkOut) : "",
      "rooms": quantity.toString(),
      "totalRate": points.toInt().toString(),
      "guestName": guestName.trim(),
      "remark": remark.trim(),
    };

    final res = await _apiService.post(
      ApiEndpoint.saveBookingDetailsAndRoomType,
      data: body,
    );

    if (res == null) return null;
    if (res is Map<String, dynamic>) return res;

    throw Exception("❌ Unexpected API response format for Booking: $res");
  }

  String _sanitizeRoomTypeName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;

    final firstToken = s.split(RegExp(r'\s+'))[0];

    if (RegExp(r'^\d').hasMatch(firstToken)) {
      return s.substring(firstToken.length).trim();
    }

    final isAllCaps = RegExp(r'^[A-Z]+$').hasMatch(firstToken);
    if (isAllCaps && firstToken.length >= 2 && firstToken.length <= 5) {
      return s.substring(firstToken.length).trim();
    }

    return s;
  }
}
