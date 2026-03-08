import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> login(String username, String password) async {
    final result = await _apiService.login(username, password);

    if (result['status'] == 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      if (result['data'] != null) {
        await prefs.setInt(
          'userId',
          int.parse(result['data']['id'].toString()),
        );
      }
      return true;
    }
    return false;
  }

  Future<bool> register(
    String username,
    String password,
    String ownerPassword,
  ) async {
    if (ownerPassword != '12345') {
      return false;
    }

    final result = await _apiService.register(username, password);
    return result['status'] == 1;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await prefs.remove('userId');
  }
}
