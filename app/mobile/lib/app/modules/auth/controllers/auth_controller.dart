import 'package:get/get.dart';

import '../../../services/api_client.dart';
import '../../../models/auth_models.dart';

class AuthController extends GetxController {
  final _api = ApiClient();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final isAdmin = false.obs;
  final profile = Rxn<UserProfile>();

  String? get token => _api.token;

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _api.init();
    if (_api.hasToken) {
      await fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    final res = await _api.get(
      '/auth/me',
      auth: true,
      fromJsonT: (json) => UserProfile.fromJson(json),
    );
    if (res.success && res.data != null) {
      profile.value = res.data;
      isLoggedIn.value = true;
      isAdmin.value = res.data!.isAdmin;
    } else {
      await _api.clearToken();
      isLoggedIn.value = false;
      isAdmin.value = false;
      profile.value = null;
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final req = RegisterRequest(name: name, email: email, password: password);
      final res = await _api.post(
        '/auth/register',
        body: req.toJson(),
        fromJsonT: (json) => AuthData.fromJson(json),
      );
      if (res.success && res.data != null) {
        await _api.setToken(res.data!.token);
        await fetchProfile();
        return null;
      }
      return res.message ?? 'Registration failed';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final req = LoginRequest(email: email, password: password);
      final res = await _api.post(
        '/auth/login',
        body: req.toJson(),
        fromJsonT: (json) => AuthData.fromJson(json),
      );
      if (res.success && res.data != null) {
        await _api.setToken(res.data!.token);
        await fetchProfile();
        return null;
      }
      return res.message ?? 'Login failed';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    isLoggedIn.value = false;
    isAdmin.value = false;
    profile.value = null;
  }
}
