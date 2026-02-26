// ignore: file_names
import 'package:flutter/material.dart';
import 'package:mana_mana_app/config/AppAuth/keycloak_auth_service.dart';
import 'package:mana_mana_app/config/oauth2_provider.dart';
import 'package:mana_mana_app/model/owner_property_list.dart';
import 'package:mana_mana_app/model/booking_history.dart';
import 'package:mana_mana_app/model/booking_room.dart';
import 'package:mana_mana_app/model/calendar_blocked_date.dart';
import 'package:mana_mana_app/model/property_state.dart';
import 'package:mana_mana_app/model/roomtype.dart';
import 'package:mana_mana_app/model/unit_available_points.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:mana_mana_app/splashscreen.dart';

class OwnerProfileVM extends ChangeNotifier {
  final RedemptionRepository _ownerBookingRepository = RedemptionRepository();
  final UserRepository _userRepository = UserRepository();

  bool _isLoadingStates = false;
  bool _isLoadingLocations = false;
  String? _error;
  bool _showMyInfo = true;
  final GlobalDataManager _globalDataManager = GlobalDataManager();
  bool _isLoadingBookingHistory = false;
  bool _isLoadingAvailablePoints = false;
  bool _isLoadingBlockedDates = false;

  List<User> _users = [];
  // ignore: non_constant_identifier_names
  final UserPointBalance = [];
  List<String> _states = [];
  List<PropertyState> _locationsInState = [];
  String _selectedState = '';
  List<BookingHistory> _bookingHistory = [];
  List<UnitAvailablePoint> _unitAvailablePoints = [];
  List<CalendarBlockedDate> _blockedDates = [];
  List<RoomType> _roomTypes = [];
  bool _isLoadingRoomTypes = false;

  bool get isLoading =>
      _isLoadingStates ||
      _isLoadingLocations ||
      _isLoadingBookingHistory ||
      _isLoadingAvailablePoints;
  List<BookingHistory> get bookingHistory => _bookingHistory;
  List<UnitAvailablePoint> get unitAvailablePoints => _unitAvailablePoints;
  bool get showMyInfo => _showMyInfo;
  List<String> get states => _states;
  List<PropertyState> get locations => _locationsInState;
  String get selectedState => _selectedState;
  bool get isLoadingStates => _isLoadingStates;
  bool get isLoadingLocations => _isLoadingLocations;
  String? get error => _error;
  bool get isLoadingBookingHistory => _isLoadingBookingHistory;
  bool get isLoadingAvailablePoints => _isLoadingAvailablePoints;
  List<CalendarBlockedDate> get blockedDates => _blockedDates;
  bool get isLoadingBlockedDates => _isLoadingBlockedDates;
  List<RoomType> get roomTypes => _roomTypes;
  bool get isLoadingRoomTypes => _isLoadingRoomTypes;

  List<User> get users => _globalDataManager.users;
  List<OwnerPropertyList> get ownerUnits => _globalDataManager.ownerUnits;

  String getOwnerName() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerFullName?.toString() ?? 'No Information';
  }

  String getOwnerContact() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerContact?.toString() ?? 'No Information';
  }

  String getOwnerEmail() {
    if (users.isEmpty) return 'No Information';
    return users.first.email?.toString() ?? 'No Information';
  }

  String getOwnerAddress() {
    if (users.isEmpty) return 'No Information';
    return users.first.ownerAddress?.toString() ?? 'No Information';
  }

  String getBankInfo() {
    if (ownerUnits.isEmpty) return 'No Information';
    debugPrint('Bank Info: ${ownerUnits.first.bank}');

    return ownerUnits.first.bank?.toString() ?? 'No Information';
  }

  String getAccountNumber() {
    if (ownerUnits.isEmpty) return 'No Information';
    return ownerUnits.first.accountnumber?.toString() ?? 'No Information';
  }

  Future<void> fetchData() async {
    await _globalDataManager.initializeData();
    _users = await _userRepository.getUsers();

    await checkRole();

    notifyListeners();
  }

  Future<void> refreshData() async {
    await _globalDataManager.refreshData();
    notifyListeners();
  }

  void updateShowMyInfo(bool value) {
    _showMyInfo = value;
    notifyListeners();
  }

  Future<void> fetchBookingHistory() async {
    final email = users.isNotEmpty ? users.first.email ?? '' : '';

    if (email.isEmpty) {
      debugPrint("⚠️ No email found, cannot fetch booking history.");
      return;
    }

    try {
      _isLoadingBookingHistory = true;
      notifyListeners();
      final response = await _ownerBookingRepository.getBookingHistory(
        email: email,
      );

      _bookingHistory = response;
    } catch (e) {
      debugPrint('❌ Error fetching booking history: $e');
    } finally {
      _isLoadingBookingHistory = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserAvailablePoints() async {
    final email = users.isNotEmpty ? users.first.email ?? '' : '';

    if (email.isEmpty) {
      debugPrint("⚠️ No email found, cannot fetch available points.");
      return;
    }

    try {
      debugPrint('📍 Fetching available points...');
      _isLoadingAvailablePoints = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      final response = await _ownerBookingRepository.getUnitAvailablePoints(
        email: email,
      );
      debugPrint('ab');
      _unitAvailablePoints = response;
      debugPrint("✅ Available points length: ${_unitAvailablePoints.length}");
    } catch (e) {
      debugPrint('❌ Error fetching available points: $e');
    } finally {
      _isLoadingAvailablePoints = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

      _isLoadingBookingHistory = false;

      _isLoadingAvailablePoints = false;

      notifyListeners();
    }
  }

  Future<void> fetchLocationsByState(String state) async {
    if (state.isEmpty) return;

    _isLoadingLocations = true;
    _error = null;
    notifyListeners();

    try {
      final cached = _globalDataManager.getLocationsForState(state);
      if (cached.isNotEmpty) {
        _locationsInState = List<PropertyState>.from(cached);
      } else {
        final fetchedLocations =
            await _ownerBookingRepository.getAllLocationsByState(state);
        _locationsInState = fetchedLocations
            .where((loc) => loc.locationName.isNotEmpty)
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Error fetching locations by state: $e");
      _locationsInState = [];
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
    }
  }

  Future<void> loadStates() async {
    if (_isLoadingStates) return;
    _isLoadingStates = true;
    _error = null;
    notifyListeners();

    try {
      _states = await _ownerBookingRepository.getAvailableStates();

      if (_states.isNotEmpty) {
        await Future.wait(
          _states.map((state) => _preloadLocationsForState(state)),
        );
      }

      _selectedState = _states.isNotEmpty ? _states.first : '';
    } catch (e) {
      _error = e.toString();
      _states = [];
    } finally {
      _isLoadingStates = false;
      notifyListeners();
    }
  }

  Future<void> _preloadLocationsForState(String state) async {
    try {
      final locations = await _ownerBookingRepository.getAllLocationsByState(
        state,
      );
      _locationsInState =
          locations.where((loc) => loc.locationName.isNotEmpty).toList();
    } catch (e) {
      debugPrint("❌ Error preloading locations for state $state: $e");
    }
  }

  Future<void> fetchRedemptionBalancePoints({
    required String location,
    required String unitNo,
  }) async {
    if (location.isEmpty || unitNo.isEmpty) {
      debugPrint(
        "⚠️ Location or Unit No is empty, cannot fetch redemption balance points.",
      );
      return;
    }

    try {
      _isLoadingAvailablePoints = true;
      notifyListeners();

      final response = await _ownerBookingRepository.getRedemptionBalancePoints(
        location: location,
        unitNo: unitNo,
      );

      UserPointBalance.clear();
      UserPointBalance.addAll(response);

      debugPrint(
        "✅ Redemption balance points length: ${UserPointBalance.length}",
      );
    } catch (e) {
      debugPrint('❌ Error fetching redemption balance points: $e');
    } finally {
      _isLoadingAvailablePoints = false;
      notifyListeners();
    }
  }

  Future<void> fetchRedemptionBalancePointsBook({
    required String location,
    required String unitNo,
  }) async {
    debugPrint('📍 Starting to fetch redemption points...');

    try {
      if (_unitAvailablePoints.isEmpty) {
        debugPrint('⚠️ Fetching available points first...');
        await fetchUserAvailablePoints();
      }

      String effectiveLocation = location.isNotEmpty
          ? location
          : _unitAvailablePoints.firstOrNull?.location ?? '';
      String effectiveUnitNo = unitNo.isNotEmpty
          ? unitNo
          : _unitAvailablePoints.firstOrNull?.unitNo ?? '';

      debugPrint(
        '🏢 Using location: $effectiveLocation, unit: $effectiveUnitNo',
      );

      if (effectiveLocation.isEmpty || effectiveUnitNo.isEmpty) {
        debugPrint('❌ No valid location/unit available');
        return;
      }

      _isLoadingAvailablePoints = true;
      notifyListeners();

      final response = await _ownerBookingRepository.getRedemptionBalancePoints(
        location: effectiveLocation,
        unitNo: effectiveUnitNo,
      );

      UserPointBalance.clear();
      UserPointBalance.addAll(response);

      debugPrint(
        '✅ Points updated successfully: ${UserPointBalance.length} entries',
      );
    } catch (e) {
      debugPrint('❌ Error fetching redemption points: $e');
    } finally {
      _isLoadingAvailablePoints = false;
      notifyListeners();
    }
  }

  Future<void> fetchBlockedDates({
    required String location,
    required String state,
  }) async {
    _isLoadingBlockedDates = true;
    notifyListeners();

    try {
      final allDates = await _ownerBookingRepository.getCalendarBlockedDates();
      _blockedDates = _ownerBookingRepository.filterBlockedDatesForState(
        allDates,
        state,
      );
      debugPrint("✅ Blocked dates loaded: ${_blockedDates.length}");
    } catch (e) {
      debugPrint("❌ Failed to fetch blocked dates: $e");
      _blockedDates = [];
    } finally {
      _isLoadingBlockedDates = false;
      notifyListeners();
    }
  }

  Map<String, List<RoomType>> _roomTypeCache = {};

  bool _canSwitchUser = false;

  bool get canSwitchUser => _canSwitchUser;

  String _getRoomTypeCacheKey(
    String state,
    String location,
    int rooms,
    DateTime? arrival,
    DateTime? departure,
  ) {
    return '$state|$location|$rooms|${arrival?.toIso8601String()}|${departure?.toIso8601String()}';
  }

  Future<void> fetchRoomTypes({
    required String state,
    required String bookingLocationName,
    int? rooms,
    DateTime? arrivalDate,
    DateTime? departureDate,
  }) async {
    final defaultRooms = rooms ?? 1;
    final defaultArrival =
        arrivalDate ?? DateTime.now().add(const Duration(days: 7));
    final defaultDeparture =
        departureDate ?? DateTime.now().add(const Duration(days: 8));

    final cacheKey = _getRoomTypeCacheKey(
      state,
      bookingLocationName,
      defaultRooms.toInt(),
      arrivalDate,
      departureDate,
    );

    if (_roomTypeCache.containsKey(cacheKey)) {
      _roomTypes = _roomTypeCache[cacheKey]!;
      notifyListeners();
      return;
    }

    if (_roomTypes.isEmpty) {
      _isLoadingRoomTypes = true;
      notifyListeners();
    }

    try {
      final response = await _ownerBookingRepository.getRoomTypes(
        state: state,
        bookingLocationName: bookingLocationName,
        rooms: defaultRooms.toInt(),
        arrivalDate: defaultArrival,
        departureDate: defaultDeparture,
      );

      _roomTypes = response;
      _roomTypeCache[cacheKey] = response;
      debugPrint("✅ Room types loaded: ${_roomTypes.length}");
    } catch (e) {
      if (!_roomTypeCache.containsKey(cacheKey)) {
        _roomTypes = [];
      }
      debugPrint("❌ Error fetching room types: $e");
    } finally {
      _isLoadingRoomTypes = false;
      notifyListeners();
    }
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
    try {
      return await _ownerBookingRepository.submitBooking(
        bookingRoom: bookingRoom,
        point: point,
        propertyStates: propertyStates,
        checkIn: checkIn,
        checkOut: checkOut,
        quantity: quantity,
        points: points,
        guestName: guestName,
        remark: remark,
      );
    } catch (e, st) {
      debugPrint("❌ Booking submission failed: $e\n$st");
      return null;
    }
  }

  PropertyState? findPropertyStateForOwner(String ownerLocation) {
    try {
      String fullLocationName = _getLocationName(ownerLocation);

      debugPrint(
          "🔍 Looking for property state for: '$ownerLocation' -> '$fullLocationName'");
      debugPrint(
          "🔍 Available locations in state: ${_locationsInState.map((l) => l.locationName).toList()}");

      PropertyState? found = _locationsInState
          .where((loc) =>
              loc.locationName.toLowerCase().trim() ==
              fullLocationName.toLowerCase().trim())
          .firstOrNull;

      if (found != null) {
        debugPrint("✅ Found exact match in current state: ${found.stateName}");
        return found;
      }

      debugPrint(
          "🔍 Searching in global data manager for location: $fullLocationName");
      final allLocations = _globalDataManager.getAllLocationsFromAllStates();
      found = allLocations
          .where((loc) =>
              loc.locationName.toLowerCase().trim() ==
              fullLocationName.toLowerCase().trim())
          .firstOrNull;

      if (found != null) {
        debugPrint(
            "✅ Found in global data: stateName='${found.stateName}', locationName='${found.locationName}'");
        return found;
      }

      // --- Fuzzy Match Fallback ---
      // Try matching without 'Z' at the end or removing common prefixes
      debugPrint("🔍 Trying fuzzy match for '$fullLocationName'...");
      String searchName = fullLocationName.toLowerCase().trim();

      // If we're looking for PAXTONZ, also try PAXTON
      String alternativeName = searchName.endsWith('z')
          ? searchName.substring(0, searchName.length - 1)
          : searchName + 'z';

      found = allLocations.where((loc) {
        String locName = loc.locationName.toLowerCase().trim();
        return locName == alternativeName ||
            locName.contains(searchName) ||
            searchName.contains(locName) && locName.length > 3;
      }).firstOrNull;

      if (found != null) {
        debugPrint(
            "✅ Found via fuzzy match: '${found.locationName}' for '$fullLocationName'");
        return found;
      }

      debugPrint("❌ Location '$fullLocationName' not found anywhere");
      debugPrint(
          "❌ Available locations in global data: ${allLocations.map((l) => '${l.locationName}(${l.stateName})').toList()}");

      // Second Fallback: If we really can't find it, but we have some locations,
      // maybe return the first one as a last resort OR return a synthetic one?
      // For now, let's keep it null but log heavily.
      return null;
    } catch (e) {
      debugPrint("❌ Error in findPropertyStateForOwner for $ownerLocation: $e");
      return null;
    }
  }

  String _getLocationName(String code) {
    switch (code.toUpperCase()) {
      case "22M":
        return "22MACALISTERZ";
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
      case "STAL":
        return "STALLIONZ";
      default:
        return code;
    }
  }

  void clearSelectionCache() {
    _selectedState = '';
    _locationsInState.clear();
    _roomTypes.clear();
    _blockedDates.clear();

    _roomTypeCache.clear();

    UserPointBalance.clear();

    debugPrint("✅ Selection cache cleared in OwnerProfileVM");
    notifyListeners();
  }

  Future<void> ensureAllLocationDataLoaded() async {
    debugPrint("🔄 Ensuring all location data is loaded in OwnerProfileVM...");
    await _globalDataManager.fetchAllLocationsForAllStates();
    debugPrint("✅ All location data loaded in OwnerProfileVM");
  }

  void clearLocationCache() {
    _states.clear();
    _locationsInState.clear();
    _selectedState = '';

    _roomTypes.clear();
    _roomTypeCache.clear();

    _blockedDates.clear();

    debugPrint("✅ Location cache cleared in OwnerProfileVM");
    notifyListeners();
  }

  void resetNavigationState() {
    clearSelectionCache();
    clearLocationCache();

    _isLoadingStates = false;
    _isLoadingLocations = false;
    _isLoadingRoomTypes = false;
    _isLoadingBlockedDates = false;

    _error = null;

    debugPrint("✅ Navigation state completely reset in OwnerProfileVM");
    notifyListeners();
  }

  Future<void> refreshPointsForUnit(String location, String unitNo) async {
    UserPointBalance.clear();
    await fetchRedemptionBalancePoints(location: location, unitNo: unitNo);
  }

  void clearRoomTypesForNewLocation() {
    _roomTypes.clear();
    _roomTypeCache.clear();
    notifyListeners();
  }

  Future<void> checkRole() async {
    try {
      final currentUsers = _globalDataManager.users.isNotEmpty
          ? _globalDataManager.users
          : _users;

      if (currentUsers.isEmpty) {
        _canSwitchUser = false;
        notifyListeners();
        return;
      }

      final roleString = currentUsers.first.role ?? '';

      final roles = roleString
          .split(',')
          .map((s) => s.trim().toUpperCase())
          .where((s) => s.isNotEmpty)
          .toList();

      _canSwitchUser = roles.contains('MOBILE-ADMIN');
    } catch (e) {
      debugPrint('❌ Error checking role: $e');
      _canSwitchUser = false;
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> validateSwitchUser(String email) async {
    try {
      final res = await _userRepository.validateSwitchUser(email);
      return res;
    } catch (e) {
      debugPrint('❌ Error validating user $email: $e');
      return {'success': false, 'body': e.toString(), 'statusCode': 500};
    }
  }

  Future<String?> switchUserAndReload(String email) async {
    try {
      // ✅ PWA: Save admin tokens before switching (for later restore via Revert)
      if (kIsWeb) {
        debugPrint('🔄 PWA Mode: Saving admin session before switch');
        await OAuth2Provider.instance.saveAdminSession();
      }

      // ✅ Use server-side session impersonation (works on both PWA and Mobile)
      final confirmRes = await _userRepository.confirmSwitchUser(email);
      debugPrint('✅ confirmSwitchUser response: $confirmRes');

      if (confirmRes['success'] != true) {
        final body = confirmRes['body']?.toString() ?? 'Unknown switch error';
        debugPrint('❌ confirmSwitchUser failed: $body');
        return body;
      }

      debugPrint('✅ Server session updated for switch user');

      // Persist switched email so PWA reload can restore state
      await _globalDataManager.enableSwitchUser(email);

      if (kIsWeb) {
        // Track impersonated email in OAuth2Provider
        await OAuth2Provider.instance.setImpersonatedEmail(email);

        // PWA: Force hard navigation reset to reload with switched session
        debugPrint('🔄 PWA Mode: Performing hard navigation reset');
        AuthService.navigatorKey?.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Splashscreen()),
          (route) => false,
        );
        return null;
      }

      // ✅ Mobile: Force refresh to get switched user's data
      await _globalDataManager.resetAndRefreshData();

      // ✅ Post-switch verification: confirm loaded user matches target
      final loadedUsers = _globalDataManager.users;
      if (loadedUsers.isNotEmpty) {
        final loadedEmail = (loadedUsers.first.email ?? loadedUsers.first.ownerEmail ?? '').toLowerCase();
        if (loadedEmail != email.toLowerCase()) {
          debugPrint('⚠️ Post-switch mismatch: expected=$email, loaded=$loadedEmail');
          return 'Switch appeared successful but loaded data belongs to "$loadedEmail" instead of "$email". Please try again.';
        }
      }

      debugPrint('✅ switchUserAndReload completed and verified for $email');
      notifyListeners();
      return null;
    } catch (e, st) {
      debugPrint('❌ switchUserAndReload failed: $e\n$st');
      return e.toString();
    }
  }

  Future<void> cancelUser(String email) async {
    // ✅ PWA: Restore admin's original token via OAuth2Provider
    if (kIsWeb) {
      debugPrint('🔄 PWA Mode: Restoring admin session via OAuth2Provider');

      final restored = await OAuth2Provider.instance.switchBack();
      if (!restored) {
        debugPrint('⚠️ OAuth2Provider switchBack failed — admin may need to re-login');
      }

      await _userRepository.cancelSwitchUser(email);
      await _globalDataManager.disableSwitchUser();

      debugPrint('🔄 PWA Mode: Hard reset after switch back');
      AuthService.navigatorKey?.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Splashscreen()),
        (route) => false,
      );
      return;
    }

    // ✅ Mobile: Session-based cancel
    await _userRepository.cancelSwitchUser(email);
    await _globalDataManager.disableSwitchUser();

    await _globalDataManager.initializeData(forceRefresh: true);

    debugPrint('Cancel user operation executed and data refreshed.');
    notifyListeners();
  }
}
