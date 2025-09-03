import 'package:mana_mana_app/provider/api_service.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';

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

  /// Get available rooms for a date range
  Future<List<dynamic>> getAvailableRooms({
    required String location,
    required String checkIn,
    required String checkOut,
    required int rooms,
  }) async {
    final url =
        "${ApiEndpoint.getRoomRate}?location=$location&checkIn=$checkIn&checkOut=$checkOut&rooms=$rooms";
    final res = await _apiService.post(url);
    return res ?? [];
  }

  Future<List<dynamic>> getAvailableRoomTypes() async {
    final res = await _apiService.post(ApiEndpoint.getRoomType);
    return res ?? [];
  }
}
