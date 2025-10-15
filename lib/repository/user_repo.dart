import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/provider/api_service.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  Future<List<User>> getUsers() async {
    return await _apiService.post(ApiEndpoint.ownerUserData).then(
      (res) {
        try {
          if (res == null) {
            print("⚠️ API returned null for ownerUserData");
            return [];
          }
          print("✅ API call succeeded, parsing user data...");
          final user = User.fromJson(res);
          print("✅ Successfully parsed user: ${user.email}");
          return [user];
        } catch (e) {
          print("❌ Error parsing user data: $e");
          print("❌ Raw response that failed to parse: $res");
          return [];
        }
      },
    );
  }
}
