import 'package:pro.stations.wetaxi.ma/core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient _client;
  AuthRemoteDataSource(this._client);

  Future<Map<String, dynamic>> login(String phone, String password) async {
    return await _client.post(
      '/login',
      {'phone': phone, 'password': password},
      auth: false,
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _client.get('/me');
  }
}
