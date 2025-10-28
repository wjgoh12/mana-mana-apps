import 'package:flutter/material.dart';
import 'package:mana_mana_app/model/OwnerPropertyList.dart';
import 'package:mana_mana_app/model/bookingHistory.dart';
import 'package:mana_mana_app/model/bookingRoom.dart';
import 'package:mana_mana_app/model/calendarBlockedDate.dart';
import 'package:mana_mana_app/model/propertyState.dart';
import 'package:mana_mana_app/model/roomType.dart';
import 'package:mana_mana_app/model/unitAvailablePoints.dart';
import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/global_data_manager.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/repository/user_repo.dart';
import 'package:mana_mana_app/repository/property_list.dart';

class OwnerProfileVM extends ChangeNotifier {
  //repo
  final RedemptionRepository _ownerBookingRepository = RedemptionRepository();
  final UserRepository _userRepository = UserRepository();
  final PropertyListRepository _propertyRepository = PropertyListRepository();

  //state
  bool _isLoadingStates = false;
  bool _isLoadingLocations = false;
  String? _error;
  bool _showMyInfo = true;
  final GlobalDataManager _globalDataManager = GlobalDataManager();
  bool _isLoadingBookingHistory = false;
  bool _isLoadingAvailablePoints = false;
  bool _isLoadingBlockedDates = false;

  //data
  List<User> _users = [];
  final UserPointBalance = [];
  List<String> _states = [];
  List<PropertyState> _locationsInState = [];
  String _selectedState = '';
  List<BookingHistory> _bookingHistory = [];
  List<UnitAvailablePoint> _unitAvailablePoints = [];
  List<CalendarBlockedDate> _blockedDates = [];
  List<RoomType> _roomTypes = [];
  bool _isLoadingRoomTypes = false;

  //getters
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

  // Getters that delegate to GlobalDataManager
  List<User> get users => _globalDataManager.users;
  List<OwnerPropertyList> get ownerUnits => _globalDataManager.ownerUnits;

  // Add helper methods to safely access data
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
    return ownerUnits.first.bank?.toString() ?? 'No Information';
  }

  String getAccountNumber() {
    if (ownerUnits.isEmpty) return 'No Information';
    return ownerUnits.first.accountnumber?.toString() ?? 'No Information';
  }

  Future<void> fetchData() async {
    // Use global data manager instead of making individual API calls
    await _globalDataManager.initializeData();
    _users = await _userRepository.getUsers();

    // After loading users, evaluate roles
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
      // debugPrint("✅ Booking history length: ${_bookingHistory.length}");
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
      notifyListeners();
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
      notifyListeners();
      // ❌ BUG: wrong flag here
      _isLoadingBookingHistory = false;

      // ✅ Correct it:
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
      // First check if we already have the locations cached
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
      // Get all states first
      _states = await _ownerBookingRepository.getAvailableStates();

      // Batch load locations for all states
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
      // First check if we have any available points
      if (_unitAvailablePoints.isEmpty) {
        debugPrint('⚠️ Fetching available points first...');
        await fetchUserAvailablePoints();
      }

      // Use provided location/unit or fall back to first available
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

  // Cache for room types
  Map<String, List<RoomType>> _roomTypeCache = {};

  // Role-based flags
  bool _canSwitchUser = false;

  /// Whether the current user is allowed to see the "Switch User" button
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

    // Return cached data immediately if available
    if (_roomTypeCache.containsKey(cacheKey)) {
      _roomTypes = _roomTypeCache[cacheKey]!;
      notifyListeners();
      return;
    }

    // Only show loading if we don't have cached data
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
      // Only clear room types if we don't have cached data
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
  }) async {
    try {
      return await _ownerBookingRepository.submitBooking(
        bookingRoom: bookingRoom, // ✅ match repo
        point: point, //available points
        propertyStates: propertyStates,
        checkIn: checkIn,
        checkOut: checkOut,
        quantity: quantity,
        points: points, //required points
        guestName: guestName,
      );
    } catch (e, st) {
      debugPrint("❌ Booking submission failed: $e\n$st");
      return null;
    }
  }

  // inside OwnerProfileVM
  PropertyState? findPropertyStateForOwner(String ownerLocation) {
    try {
      // Convert location code to full name for matching
      String fullLocationName = _getLocationName(ownerLocation);

      debugPrint(
          "🔍 Looking for property state for: '$ownerLocation' -> '$fullLocationName'");
      debugPrint(
          "🔍 Available locations in state: ${_locationsInState.map((l) => l.locationName).toList()}");

      // First try exact match with full location name in current state list
      PropertyState? found = _locationsInState
          .where((loc) =>
              loc.locationName.toLowerCase() == fullLocationName.toLowerCase())
          .firstOrNull;

      if (found != null) {
        debugPrint("✅ Found exact match in current state: ${found.stateName}");
        return found;
      }

      // If not found in current state list, check the global data manager
      debugPrint(
          "🔍 Searching in global data manager for location: $fullLocationName");
      final allLocations = _globalDataManager.getAllLocationsFromAllStates();
      found = allLocations
          .where((loc) =>
              loc.locationName.toLowerCase() == fullLocationName.toLowerCase())
          .firstOrNull;

      if (found != null) {
        debugPrint(
            "✅ Found in global data: stateName='${found.stateName}', locationName='${found.locationName}'");
        return found;
      }

      debugPrint("❌ Location '$fullLocationName' not found anywhere");
      debugPrint(
          "❌ Available locations in global data: ${allLocations.map((l) => '${l.locationName}(${l.stateName})').toList()}");
      return null;
    } catch (e) {
      debugPrint("❌ Error in findPropertyStateForOwner for $ownerLocation: $e");
      return null;
    }
  }

  // Helper method to convert location code to full name
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
        return code; // Return original code if no match found
    }
  }

  void clearSelectionCache() {
    // Clear any selection-related state variables
    _selectedState = '';
    _locationsInState.clear();
    _roomTypes.clear();
    _blockedDates.clear();

    // Clear room type cache to ensure fresh data on next selection
    _roomTypeCache.clear();

    // IMPORTANT: Clear user point balance to force refresh for new unit
    UserPointBalance.clear();

    debugPrint("✅ Selection cache cleared in OwnerProfileVM");
    notifyListeners();
  }

  // Add public method to ensure all location data is loaded
  Future<void> ensureAllLocationDataLoaded() async {
    debugPrint("🔄 Ensuring all location data is loaded in OwnerProfileVM...");
    await _globalDataManager.fetchAllLocationsForAllStates();
    debugPrint("✅ All location data loaded in OwnerProfileVM");
  }

  // Clear location cache method
  void clearLocationCache() {
    // Clear location-related cached data
    _states.clear();
    _locationsInState.clear();
    _selectedState = '';

    // Clear room types as they are location-dependent
    _roomTypes.clear();
    _roomTypeCache.clear();

    // Clear blocked dates as they are location-dependent
    _blockedDates.clear();

    debugPrint("✅ Location cache cleared in OwnerProfileVM");
    notifyListeners();
  }

  // Optional: Complete reset method for thorough clearing
  void resetNavigationState() {
    // Reset all navigation-related state
    clearSelectionCache();
    clearLocationCache();

    // Reset loading states
    _isLoadingStates = false;
    _isLoadingLocations = false;
    _isLoadingRoomTypes = false;
    _isLoadingBlockedDates = false;

    // Clear any error states
    _error = null;

    debugPrint("✅ Navigation state completely reset in OwnerProfileVM");
    notifyListeners();
  }

  // Add this method to OwnerProfileVM
  Future<void> refreshPointsForUnit(String location, String unitNo) async {
    // Force clear and refresh points for specific unit
    UserPointBalance.clear();
    await fetchRedemptionBalancePoints(location: location, unitNo: unitNo);
  }

  // Add this method to OwnerProfileVM
  void clearRoomTypesForNewLocation() {
    _roomTypes.clear();
    _roomTypeCache.clear();
    notifyListeners();
  }

  Future<void> checkRole() async {
    try {
      // Determine the source of users - prefer global manager's users
      final currentUsers = _globalDataManager.users.isNotEmpty
          ? _globalDataManager.users
          : _users;

      if (currentUsers.isEmpty) {
        _canSwitchUser = false;
        notifyListeners();
        return;
      }

      final roleString = currentUsers.first.role ?? '';

      // roles field may be a comma separated string like "ADMIN,MOBILE-ADMIN"
      final roles = roleString
          .split(',')
          .map((s) => s.trim().toUpperCase())
          .where((s) => s.isNotEmpty)
          .toList();

      _canSwitchUser =
          roles.contains('ADMIN') || roles.contains('MOBILE-ADMIN');
    } catch (e) {
      debugPrint('❌ Error checking role: $e');
      _canSwitchUser = false;
    }

    notifyListeners();
  }

  // Validate switch user via repository and return the raw response map.
  Future<Map<String, dynamic>> validateSwitchUser(String email) async {
    try {
      final res = await _userRepository.validateSwitchUser(email);
      return res;
    } catch (e) {
      debugPrint('❌ Error validating user $email: $e');
      return {'success': false, 'body': e.toString(), 'statusCode': 500};
    }
  }

  /// Confirm the switch operation and then load the switched user's full
  /// profile and owner-units. Returns null on success or an error message.
  Future<String?> switchUserAndReload(String email) async {
    try {
      // Step 2: confirm switch on server
      final confirmRes = await _userRepository.confirmSwitchUser(email);
      if (confirmRes['success'] == false ||
          (confirmRes.containsKey('statusCode') &&
              confirmRes['statusCode'] != 200)) {
        return confirmRes['body']?.toString() ?? 'Confirm failed';
      }

      // Determine target email (server may echo impersonatedEmail)
      String targetEmail = email;
      if (confirmRes['impersonatedEmail'] != null &&
          confirmRes['impersonatedEmail'].toString().isNotEmpty) {
        targetEmail = confirmRes['impersonatedEmail'].toString();
      }

      // Step 3: fetch switched user's profile using dedicated method
      final switched = await _userRepository.getSwitchedUser(targetEmail);
      if (switched.isEmpty) {
        return 'Failed to fetch switched user profile for $targetEmail';
      }

      // If backend did not return the impersonated user's profile (for
      // example it returned the admin account), avoid applying the switch
      // — this prevents mixing admin metadata with another user's owner/units.
      final returnedEmail = (switched.first.email ?? '').toLowerCase();
      if (returnedEmail != targetEmail.toLowerCase()) {
        debugPrint(
            '⚠️ Backend returned $returnedEmail instead of $targetEmail; cannot apply server-driven impersonation without mixing admin metadata.');

        // Start a safe, explicit temporary "view-only" impersonation so QA
        // can inspect the target account UI even when the backend doesn't
        // return a full impersonated profile. This does NOT swap tokens.
        try {
          await startTemporaryImpersonation(targetEmail);
          debugPrint(
              '⏭️ Started temporary view-only impersonation for $targetEmail');
          return 'Started temporary view-only impersonation for $targetEmail (server did not return full profile).';
        } catch (e) {
          debugPrint('❌ Failed to start temporary impersonation: $e');
          return 'Server did not return full profile for $targetEmail; switch not applied.';
        }
      }

      // Step 4: fetch owner units for that email
      List<OwnerPropertyList> ownerUnits = [];
      try {
        ownerUnits =
            await _propertyRepository.getSwitchedOwnerUnit(email: targetEmail);
      } catch (e) {
        debugPrint('⚠️ Failed to fetch ownerUnits for $targetEmail: $e');
        ownerUnits = [];
      }

      // Apply impersonation data into GlobalDataManager so UI shows full
      // switched user's profile (does not swap tokens).
      _globalDataManager.applyImpersonationData(
          user: switched.first,
          ownerUnits: ownerUnits,
          notify: true // ← Make sure this is true
          );
      _globalDataManager.setImpersonatedEmail(targetEmail);

      debugPrint('✅ switchUserAndReload completed for $targetEmail');
      notifyListeners();
      return null;
    } catch (e, st) {
      debugPrint('❌ switchUserAndReload failed: $e\n$st');
      return e.toString();
    }
  }

  /// Start a temporary, client-side impersonation that clears current
  /// user-specific data immediately and loads data for [email] in the
  /// background. This does not require the backend to return a full
  /// impersonated profile — it simply gives QA a clean slate for viewing.
  Future<void> startTemporaryImpersonation(String email) async {
    try {
      debugPrint('OwnerProfileVM: starting temporary impersonation for $email');
      await _globalDataManager.impersonateUser(email);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ startTemporaryImpersonation failed: $e');
    }
  }

  /// Revert a temporary impersonation and restore backed-up admin data.
  Future<void> revertTemporaryImpersonation() async {
    try {
      debugPrint('OwnerProfileVM: reverting temporary impersonation');
      await _globalDataManager.revertImpersonation();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ revertTemporaryImpersonation failed: $e');
    }
  }

//cancel user/stop impersonate user
  Future<void> cancelUser(String email) async {
    await _userRepository.cancelSwitchUser(email);

    debugPrint("Cancel user operation executed.");
    return;
  }

//load impersonated user data
}
