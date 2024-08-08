import 'package:mana_mana_app/model/user_model.dart';
import 'package:mana_mana_app/provider/api_endpoint.dart';
import 'package:mana_mana_app/provider/api_service.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  Future<List<User>> getUsers() async {
    return await _apiService.post(ApiEndpoint.OWNER_USER_DATA).then((res) {
      try {
        return [User.fromJson(res)];
      } catch (e) {
        print("Error parsing user data: $e");
        return [];
      }
    });
  }

  Future<void> logoutFunc() async {
  }
}
