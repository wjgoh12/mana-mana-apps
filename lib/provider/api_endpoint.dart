class ApiEndpoint {
  static const String ownerUserData = '/mobile/dash/owners';
  static const String ownerUnit = '/mobile/dash/units';
  static const String downloadPdfStatement = '/owners/statement/mobile';
  static const String downloadPdfAnnualStatement =
      '/owners/statement/annual/mobile';
  static const String dashboardTotalByMonth = '/mobile/dash/total_bymonth';
  static const String dashboardReveueByYear = '/mobile/dash/total_byyear';
  static const String getUnitByMonth =
      '/mobile/dash/total_bymonth_single_type_unit';
  static const String locationByMonth = '/mobile/dash/total_bymonth_location';
  static const String userLogout = '/mobile/dash/refs/logout';
  static const String propertyContractType =
      '/mobile/enqs/getPropertyOverviewContractType';
  static const String propertyOccupancyRate =
      '/mobile/enqs/propertyOverviewOccupanceRate';
  static const String getCalendarBlockDate =
      '/mobile/enqs/getCalendarBlockedDates';
  static const String getAllState = '/mobile/enqs/getAllRedemptionRate';
  static const String getRoomRate =
      '/mobile/enqs/calendarBooking/rooms?location=SCARLETZ&checkIn=2025-10-14&checkOut=2025-10-17&rooms=2';
  static const String getRoomType = '/mobile/enqs/getAvailableRoomTypes';
  static const String getRedemptionAndBalancePoints =
      '/mobile/enqs/redemption/getRedemptionPointsAndBalancePoints';
  static const String saveBookingDetailsAndRoomType =
      '/mobile/enqs/redemption/saveBookingDetailRoomType';
  static const String getUnitAvailablePoint =
      '/mobile/enqs/redemption/getUnitAvailablePoint';

  static const String getBookingHistory =
      '/mobile/enqs/redemption/getBookingHistory';
  static const String getAllRedemptionRate =
      '/mobile/enqs/getAllRedemptionRate';
}
