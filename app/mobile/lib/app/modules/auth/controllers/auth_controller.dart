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
      final res = await _api.post<void>(
        '/auth/register',
        body: req.toJson(),
      );
      if (res.success) {
        return null;
      }
      return res.message ?? 'Registration failed';
    } finally {
      isLoading.value = false;
    }
  }

  Future<({String? error, bool needsVerification})> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final req = LoginRequest(email: email, password: password);
      final res = await _api.post<AuthData>(
        '/auth/login',
        body: req.toJson(),
        fromJsonT: (json) => AuthData.fromJson(json),
      );
      if (res.success && res.data != null) {
        await _api.setToken(res.data!.token);
        await fetchProfile();
        return (error: null, needsVerification: false);
      }
      if (res.needsVerification == true) {
        return (error: null, needsVerification: true);
      }
      return (error: res.message ?? 'Login failed', needsVerification: false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> verifyEmail({
    required String email,
    required String code,
  }) async {
    isLoading.value = true;
    try {
      final req = VerifyEmailRequest(email: email, code: code);
      final res = await _api.post<AuthData>(
        '/auth/verify-email',
        body: req.toJson(),
        fromJsonT: (json) => AuthData.fromJson(json),
      );
      if (res.success && res.data != null) {
        await _api.setToken(res.data!.token);
        await fetchProfile();
        return null;
      }
      return res.message ?? 'Verification failed';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> resendCode({
    required String email,
  }) async {
    isLoading.value = true;
    try {
      final req = ResendCodeRequest(email: email);
      final res = await _api.post<void>(
        '/auth/resend-code',
        body: req.toJson(),
      );
      if (res.success) {
        return null;
      }
      return res.message ?? 'Failed to resend code';
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
