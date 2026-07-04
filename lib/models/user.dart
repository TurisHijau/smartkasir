enum Role { OWNER, MANAGER, CASHIER }

class User {
  final String? id;
  final String? storeId;
  final String name;
  final String? email;
  final String username;
  final Role role;
  final String? phone;
  final double saldo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    this.storeId,
    required this.name,
    this.email,
    required this.username,
    required this.role,
    this.phone,
    this.saldo = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      storeId: json['storeId'],
      name: json['name'] ?? '',
      email: json['email'],
      username: json['username'] ?? '',
      role: Role.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => Role.CASHIER,
      ),
      phone: json['phone'],
      saldo: double.tryParse(json['saldo']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

class UserRequest {
  final String name;
  final String? email;
  final String username;
  final String password;
  final Role role;
  final String? phone;

  UserRequest({
    required this.name,
    this.email,
    required this.username,
    required this.password,
    required this.role,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'password': password,
      'role': role.name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}
