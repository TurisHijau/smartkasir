import 'package:smartkasir/models/store.dart';
import 'package:smartkasir/models/user.dart';

class AuthResponse {
  final String? token;
  final User user;
  final Store store;

  AuthResponse({
    this.token,
    required this.user,
    required this.store,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
      store: Store.fromJson(json['store']),
    );
  }
}

class RegisterRequest {
  final String businessName;
  final String? storeAddress;
  final String? storePhone;
  final String ownerName;
  final String username;
  final String password;
  final String? email;
  final String? ownerPhone;

  RegisterRequest({
    required this.businessName,
    this.storeAddress,
    this.storePhone,
    required this.ownerName,
    required this.username,
    required this.password,
    this.email,
    this.ownerPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      if (storeAddress != null) 'storeAddress': storeAddress,
      if (storePhone != null) 'storePhone': storePhone,
      'ownerName': ownerName,
      'username': username,
      'password': password,
      if (email != null) 'email': email,
      if (ownerPhone != null) 'ownerPhone': ownerPhone,
    };
  }
}
