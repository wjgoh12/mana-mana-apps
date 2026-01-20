import 'package:mana_mana_app/core/constants/app_colors.dart';
import 'package:mana_mana_app/core/constants/app_fonts.dart';
import 'package:mana_mana_app/core/constants/app_dimens.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mana_mana_app/model/calendar_blocked_date.dart';
import 'package:mana_mana_app/repository/redemption_repo.dart';
import 'package:mana_mana_app/screens/book_freestay/view/room_details.dart';
import 'package:mana_mana_app/screens/book_freestay/view/select_date_room/widget/calendar.dart';
import 'package:mana_mana_app/screens/book_freestay/view/select_date_room/widget/sticky_bottom_bar.dart';
import 'package:mana_mana_app/screens/profile/view_model/owner_profile_view_model.dart';
import 'package:mana_mana_app/screens/book_freestay/widgets/roomtype_card.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mana_mana_app/model/roomtype.dart';
import 'package:mana_mana_app/widgets/responsive_size.dart';

class SelectDateRoom extends StatefulWidget {
  final String ownedLocation;
  final String ownedUnitNo;
  final String location;
  final String state;
  final double points;
  final double rangeStartBorderWidth;
  final double rangeEndBorderWidth;

  const SelectDateRoom({
    Key? key,
    required this.ownedLocation,
    required this.ownedUnitNo,
    required this.location,
    required this.state,
    required this.points,
    this.rangeStartBorderWidth = 1.0,
    this.rangeEndBorderWidth = 1.0,
  }) : super(key: key);

  static int getUserPointsBalance(OwnerProfileVM vm) {
    final points = vm.UserPointBalance.isNotEmpty
        ? vm.UserPointBalance.first.redemptionBalancePoints
        : 0;

    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(points);
    return formattedPoints.isNotEmpty
        ? int.parse(formattedPoints.replaceAll(',', ''))
        : 0;
  }

  static String getFormatUserPointsBalance(OwnerProfileVM vm) {
    final formatter = NumberFormat('#,###');
    return formatter.format(getUserPointsBalance(vm));
  }

  @override
  // ignore: library_private_types_in_public_api
  _SelectDateRoomState createState() => _SelectDateRoomState();
}

class _SelectDateRoomState extends State<SelectDateRoom> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _focusedDay;
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _selectedQuantity = 1;
  List<CalendarBlockedDate> _blockedDates = [];
  bool _isLoadingBlockedDates = true;
  bool _isLoadingRoomTypes = false;
  bool _hasPendingChanges = false;

  DateTime? _lastFetchedStart;
  DateTime? _lastFetchedEnd;
  int? _lastFetchedQuantity;

  RoomType? _selectedRoom;
  String? _selectedRoomId;
  late OwnerProfileVM _vm;
  Timer? _fetchDebounce;

  @override
  void initState() {
    super.initState();

    _focusedDay = DateTime.now().add(const Duration(days: 7));
    _selectedDay = null;

    _vm = context.read<OwnerProfileVM>();
    _fetchDebounce = null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchBlockedDates();

    setState(() => _isLoadingRoomTypes = true);
    try {
      await Future.wait([
        _vm.ensureAllLocationDataLoaded(),
        _vm.fetchRedemptionBalancePoints(
          location: widget.ownedLocation,
          unitNo: widget.ownedUnitNo,
        ),
        _vm.fetchRoomTypes(
          state: widget.state,
          bookingLocationName: widget.location,
          rooms: _selectedQuantity,
          arrivalDate: DateTime.now().add(const Duration(days: 7)),
          departureDate: DateTime.now().add(const Duration(days: 8)),
        ),
      ]);
    } catch (e) {
      debugPrint('Failed initial data load: $e');
    } finally {
      if (mounted) setState(() => _isLoadingRoomTypes = false);
    }
  }

  int getNumBedroomsFromRoomTypeName(String roomTypeName) {
    final regex = RegExp(r'(\d+)', caseSensitive: false);
    final match = regex.firstMatch(roomTypeName);
    if (match != null && match.groupCount >= 1) {
      return int.parse(match.group(1) ?? '1');
    }
    return 1;
  }

  String sanitizeRoomTypeName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;

    final firstToken = s.split(RegExp(r'\s+'))[0];

    if (RegExp(r'^\d').hasMatch(firstToken)) {
      return s.substring(firstToken.length).trim();
    }

    final isAllCaps = RegExp(r'^[A-Z]+$').hasMatch(firstToken);

    if (isAllCaps && firstToken.length >= 2 && firstToken.length <= 3) {
      return s.substring(firstToken.length).trim();
    }

    return s;
  }

  Future<void> _fetchBlockedDates() async {
    if (_blockedDates.isNotEmpty) return;

    setState(() => _isLoadingBlockedDates = true);
    try {
      final repo = RedemptionRepository();
      final res = await repo.getCalendarBlockedDates();
      final filteredDates = repo.filterBlockedDatesForState(res, widget.state);

      setState(() {
        _blockedDates = filteredDates;
        _isLoadingBlockedDates = false;
      });
    } catch (e) {
      debugPrint("Failed to fetch blocked dates: $e");
      setState(() => _isLoadingBlockedDates = false);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    if (start == null && end == null) {
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
        _selectedDay = null;
        _selectedQuantity = 1;
        _hasPendingChanges = false;
      });
      return;
    }

    if (start != null && end != null) {
      bool hasBlocked = false;
      for (DateTime d = start;
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))) {
        if (_isBlackoutDay(d)) {
          hasBlocked = true;
          break;
        }
      }

      if (hasBlocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selected range includes blocked dates. Please choose another range.',
            ),
            backgroundColor: Color.fromARGB(255, 203, 46, 46),
          ),
        );
        return;
      }
    }

    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
      _selectedDay = null;

      if (start != null && end == null) {
        _rangeStart = start;
        _rangeEnd = null;
        _hasPendingChanges = true;
      } else {
        _rangeStart = start;
        _rangeEnd = end;
        _selectedQuantity = 1;
        _hasPendingChanges = true;
      }
    });
    if (start != null && end != null) {
      _fetchDebounce?.cancel();
      _fetchDebounce = Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _fetchRoomTypesAndMaintainSelection();
      });
    }
  }

  Future<void> _fetchRoomTypesAndMaintainSelection() async {
    final start = _rangeStart ?? DateTime.now().add(const Duration(days: 7));
    final end = _rangeEnd ?? start.add(const Duration(days: 1));

    setState(() => _isLoadingRoomTypes = true);

    try {
      await _vm.fetchRoomTypes(
        state: widget.state,
        bookingLocationName: widget.location,
        rooms: _selectedQuantity,
        arrivalDate: _toDateOnly(start),
        departureDate: _toDateOnly(end),
      );

      setState(() {
        _lastFetchedStart = start;
        _lastFetchedEnd = end;
        _lastFetchedQuantity = _selectedQuantity;
        _hasPendingChanges = false;
      });

      if (_selectedRoomId != null) {
        _restoreRoomSelection();
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch room types: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update room prices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoomTypes = false);
      }
    }
  }

  void _restoreRoomSelection() {
    if (_selectedRoomId == null) return;

    debugPrint("🔍 Attempting to restore room selection: $_selectedRoomId");
    debugPrint("🔍 Current quantity: $_selectedQuantity");
    debugPrint(
        "🔍 Available rooms: ${_vm.roomTypes.map((r) => sanitizeRoomTypeName(r.roomTypeName)).toList()}");

    final matchingRoom = _vm.roomTypes.firstWhere(
      (room) => sanitizeRoomTypeName(room.roomTypeName) == _selectedRoomId,
      orElse: () => RoomType(
          roomTypeName: '',
          roomTypePoints: 0,
          pic: '',
          pic2: '',
          pic3: '',
          pic4: '',
          pic5: '',
          numberOfPax: 1),
    );

    if (matchingRoom.roomTypeName.isEmpty) {
      debugPrint("❌ Room not found in available rooms - deselecting");
      setState(() {
        _selectedRoom = null;
        _selectedRoomId = null;
      });

      return;
    }

    debugPrint("✅ Room found: ${matchingRoom.roomTypeName}");
    debugPrint("🔍 Room points: ${matchingRoom.roomTypePoints}");

    final isAffordable = isRoomAffordable(
      matchingRoom,
      1,
      _selectedQuantity,
    );

    debugPrint("🔍 Is affordable: $isAffordable");

    if (isAffordable) {
      debugPrint("✅ Room is affordable - keeping selection");
      setState(() {
        _selectedRoom = matchingRoom;
      });
    } else {
      debugPrint("❌ Room not affordable - deselecting");
      setState(() {
        _selectedRoom = null;
        _selectedRoomId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Insufficient points for the selected room.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fetchDebounce?.cancel();
    super.dispose();
  }

  int get duration {
    if (_rangeStart != null && _rangeEnd != null) {
      return _rangeEnd!.difference(_rangeStart!).inDays;
    }
    return 0;
  }

  DateTime _toDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isBlackoutDay(DateTime day) {
    final d = _toDateOnly(day);
    return _blockedDates.any(
      (bd) =>
          bd.contentType.toLowerCase() == "black" &&
          !d.isBefore(_toDateOnly(bd.dateFrom)) &&
          !d.isAfter(_toDateOnly(bd.dateTo)),
    );
  }

  DateTime getInitialFocusedDay() {
    final today = DateTime.now();
    final sevenDaysFromNow = today.add(const Duration(days: 7));

    bool hasAvailableDayThisMonth = false;
    DateTime firstOfMonth = DateTime(today.year, today.month, 1);
    DateTime lastOfMonth = DateTime(today.year, today.month + 1, 0);

    for (DateTime d = firstOfMonth;
        d.isBefore(lastOfMonth.add(const Duration(days: 1)));
        d = d.add(const Duration(days: 1))) {
      if (_isDayEnabled(d)) {
        hasAvailableDayThisMonth = true;
        break;
      }
    }

    if (hasAvailableDayThisMonth) {
      return today;
    }

    return sevenDaysFromNow;
  }

  bool _isDayEnabled(DateTime day) {
    final today = DateTime.now();
    final sevenDaysFromNow = today.add(const Duration(days: 7));
    return day.isAfter(sevenDaysFromNow) || isSameDay(day, sevenDaysFromNow);
  }

  bool isRoomAffordable(RoomType room, int duration, int quantity) {
    final userPoints = _vm.UserPointBalance.isNotEmpty
        ? _vm.UserPointBalance.first.redemptionBalancePoints
        : 0;

    final totalPoints = room.roomTypePoints;
    final isAffordable = totalPoints <= userPoints;

    return isAffordable;
  }

  bool _isDataStale() {
    if (_rangeStart == null || _rangeEnd == null) return false;

    return _lastFetchedStart == null ||
        _lastFetchedEnd == null ||
        _lastFetchedQuantity == null ||
        !isSameDay(_lastFetchedStart!, _rangeStart!) ||
        !isSameDay(_lastFetchedEnd!, _rangeEnd!) ||
        _lastFetchedQuantity != _selectedQuantity ||
        _hasPendingChanges;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OwnerProfileVM>();

    final String formattedPoints = _selectedRoom != null
        ? NumberFormat('#,###').format(_selectedRoom!.roomTypePoints)
        : '0';

    final bool dataIsStale = _isDataStale();

    if (_isLoadingBlockedDates) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Select Date and Room',
                style: TextStyle(
                  color: AppColors.primaryGrey,
                  fontFamily: AppFonts.outfit,
                  fontSize: AppDimens.fontSizeBig,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Select Date and Room',
              style: TextStyle(
                color: AppColors.primaryGrey,
                fontFamily: AppFonts.outfit,
                fontSize: AppDimens.fontSizeBig,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGrey,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 18),
                          child: Text(
                            '* The yellow icon indicates the peak dates',
                            style: TextStyle(
                              fontSize: AppDimens.fontSizeBig,
                              color: Color(0xFFFFCF00),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                CalendarWidget(
                  focusedDay: _focusedDay ?? DateTime.now(),
                  selectedDay: _selectedDay,
                  rangeStart: _rangeStart,
                  rangeEnd: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  blockedDates: _blockedDates,
                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSize.scaleWidth(18)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateCard('Check-In', _rangeStart),
                      _buildDateCard('Check-Out', _rangeEnd),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveSize.scaleHeight(10)),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveSize.scaleWidth(18),
                      vertical: ResponsiveSize.scaleHeight(5)),
                  child: _buildPointsAndQuantity(vm),
                ),

                if (dataIsStale && _rangeStart != null && _rangeEnd != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Room prices are updating...',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: AppDimens.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: ResponsiveSize.scaleHeight(26)),
                Padding(
                  padding: const EdgeInsets.only(left: 18, bottom: 8),
                  child: Text(
                    'Available Room Types',
                    style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width >= 600 ? 20 : 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                if (vm.roomTypes.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveSize.scaleWidth(18),
                        vertical: ResponsiveSize.scaleHeight(35)),
                    child: Center(
                      child: _isLoadingRoomTypes
                          ? const CircularProgressIndicator()
                          : Text(
                              'No rooms available',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeBig,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  )
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: vm.roomTypes.length,
                    itemBuilder: (context, index) {
                      final room = vm.roomTypes[index];
                      final displayName =
                          sanitizeRoomTypeName(room.roomTypeName);
                      final numberOfPax = room.numberOfPax;
                      final numBedRooms =
                          getNumBedroomsFromRoomTypeName(displayName);
                      final start = _rangeStart ??
                          DateTime.now().add(const Duration(days: 7));
                      final end =
                          _rangeEnd ?? start.add(const Duration(days: 1));

                      final isSelected = displayName == (_selectedRoomId ?? '');
                      final effectiveQuantity =
                          isSelected ? _selectedQuantity : 1;
                      double displayedPoints = room.roomTypePoints;
                      if (!isSelected && _selectedQuantity > 1) {
                        displayedPoints =
                            room.roomTypePoints / _selectedQuantity;
                      }

                      return RoomtypeCard(
                        key: ValueKey(displayName),
                        roomType: room,
                        displayName: displayName,
                        isSelected: isSelected,
                        enabled: true,
                        startDate: start,
                        endDate: end,
                        quantity: effectiveQuantity,
                        numberofPax: numberOfPax,
                        numBedrooms: numBedRooms,
                        displayedPoints: displayedPoints,
                        checkAffordable: (room, duration) {
                          final userPoints = vm.UserPointBalance.isNotEmpty
                              ? vm.UserPointBalance.first
                                  .redemptionBalancePoints
                              : 0;

                          return room.roomTypePoints <= userPoints;
                        },
                        onSelect: (selectedRoom) {
                          setState(() {
                            final isDifferentRoom = selectedRoom != null &&
                                _selectedRoom != null &&
                                sanitizeRoomTypeName(
                                        selectedRoom.roomTypeName) !=
                                    _selectedRoomId;

                            _selectedRoom = selectedRoom;
                            _selectedRoomId = selectedRoom != null
                                ? sanitizeRoomTypeName(
                                    selectedRoom.roomTypeName)
                                : null;

                            if (selectedRoom == null || isDifferentRoom) {
                              _selectedQuantity = 1;
                              _fetchRoomTypesAndMaintainSelection();
                            }
                          });
                        },
                        onQuantityChanged: (val) {
                          setState(() {
                            _selectedQuantity = val;
                            _hasPendingChanges = true;
                          });

                          // Only fetch if both dates are selected
                          if (_rangeStart != null && _rangeEnd != null) {
                            _fetchDebounce?.cancel();
                            _fetchDebounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                if (mounted && _selectedQuantity == val) {
                                  _fetchRoomTypesAndMaintainSelection();
                                }
                              },
                            );
                          }
                        },
                      );
                    },
                  ),

                SizedBox(
                    height: ResponsiveSize.scaleHeight(
                        150)), // Space for bottom bar
              ],
            ),
          ),
          SizedBox(height: ResponsiveSize.scaleHeight(20)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StickyBottomBar(
              selectedQuantity: _selectedQuantity,
              formattedPoints: formattedPoints,
              dataIsStale: dataIsStale,
              onNextPressed: _onNextPressed,
              hasRoomSelected: _selectedRoom != null,
              hasDatesSelected: _rangeStart != null && _rangeEnd != null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String title, DateTime? date) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      width: 160,
      child: Card(
        color: Colors.white,
        shadowColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                date != null
                    ? DateFormat('EEE, MMM d, yyyy').format(date)
                    : '-',
                style: const TextStyle(
                  fontSize: AppDimens.fontSizeSmall,
                  color: AppColors.primaryGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsAndQuantity(OwnerProfileVM vm) {
    final points = widget.points;

    final formatter = NumberFormat('#,###');
    final formattedPoints = formatter.format(points);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Available Point Balance:  ',
            style: TextStyle(
              fontSize: AppDimens.fontSizeSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            formattedPoints,
            style: TextStyle(
              color: AppColors.primaryGrey,
              fontSize: AppDimens.fontSizeBig,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _onNextPressed() async {
    if (_rangeStart == null || _rangeEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isDataStale()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updating room prices, please wait...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );

      await _fetchRoomTypesAndMaintainSelection();

      if (_isDataStale()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update prices. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a room type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedRoom!.roomTypePoints == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot proceed with 0 points. Please select a valid room.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isRoomAffordable(_selectedRoom!, 1, _selectedQuantity)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient points for this room.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ownerVM = Provider.of<OwnerProfileVM>(context, listen: false);
    final userPointsBalance = ownerVM.UserPointBalance.isNotEmpty
        ? ownerVM.UserPointBalance.first.redemptionBalancePoints
        : 0;

    final formatter = NumberFormat('#,###');
    final totalPoints = _selectedRoom!.roomTypePoints;
    final formattedPoints = formatter.format(totalPoints);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: _vm,
          child: RoomDetails(
            room: _selectedRoom!,
            checkIn: _rangeStart,
            checkOut: _rangeEnd,
            quantity: _selectedQuantity,
            userPointsBalance: userPointsBalance,
            ownerLocation: widget.ownedLocation,
            ownerUnitNo: widget.ownedUnitNo,
            bookingLocationName: widget.location,
            totalPoints: formattedPoints,
          ),
        ),
      ),
    );
  }
}
