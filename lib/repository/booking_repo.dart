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

  Future<List<dynamic>> getAvailableRoomTypes() async {
    final res = await _apiService.post(ApiEndpoint.getRoomType);
    return res ?? [];
  }

  Future<List<dynamic>> getUnitAvailablePoints({
    required String unitNo,
  }) async {
    final data = {
      "unitNo": unitNo,
    };

    final res =
        await _apiService.post(ApiEndpoint.getUnitAvailablePoints, data: data);
    return res ?? [];
  }
}
