import 'dart:convert';
import 'package:smartkasir/models/user.dart';
import 'package:smartkasir/services/api_client.dart';

class UserService {
  final ApiClient _api = ApiClient();

  Future<List<User>> getAll() async {
    final response = await _api.get('/users');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception("Gagal memuat pengguna: ${response.statusCode}");
  }

  Future<User> create(UserRequest request) async {
    final response = await _api.post('/users', body: request.toJson());
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception("Gagal menambah pengguna: ${response.statusCode} - ${response.body}");
  }

  Future<User> update(String id, UserRequest request) async {
    final response = await _api.put('/users/$id', body: request.toJson());
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception("Gagal mengupdate pengguna: ${response.statusCode} - ${response.body}");
  }

  Future<void> delete(String id) async {
    final response = await _api.delete('/users/$id');
    if (response.statusCode != 204) {
      throw Exception("Gagal menghapus pengguna: ${response.statusCode}");
    }
  }
}
