class RegisterRequest {
  final String name;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class AuthData {
  final String id;
  final String name;
  final String email;
  final String token;

  AuthData({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        token: json['token'],
      );
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        createdAt: json['createdAt'],
      );

  bool get isAdmin => role == 'admin';
}
