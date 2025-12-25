import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/dio_client.dart';
import 'auth_api.dart';
import 'auth_model.dart';

class AuthController extends ChangeNotifier {
  static const _kTokenKey = 'access_token';

  final DioClient _client;
  late final AuthApi _api = AuthApi(_client);

  String? _token;
  UserOut? _me;

  AuthController(this._client);

  UserOut? get me => _me;
  String? get token => _token;
  bool get isAuthed => _token != null && _token!.isNotEmpty;

  Future<void> loadSession() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kTokenKey);
    if (t == null || t.isEmpty) return;

    _token = t;
    _client.setAccessToken(t);
    try {
      _me = await _api.me();
    } catch (_) {
      // 토큰이 만료/무효면 세션 제거
      await logout();
      return;
    }
    notifyListeners();
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final tokenRes = await _api.login(email: email, phone: null, password: password);
    await _persistToken(tokenRes.accessToken);
    _me = await _api.me();
    notifyListeners();
  }

  Future<void> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final tokenRes = await _api.login(email: null, phone: phone, password: password);
    await _persistToken(tokenRes.accessToken);
    _me = await _api.me();
    notifyListeners();
  }

  Future<void> signupThenLogin({
    String? email,
    String? phone,
    required String password,
    required UserRole role,
  }) async {
    // 서버는 signup에 토큰을 안 주므로: signup -> login -> me
    await _api.signup(email: email, phone: phone, password: password, role: role);

    final tokenRes = await _api.login(email: email, phone: phone, password: password);
    await _persistToken(tokenRes.accessToken);

    _me = await _api.me();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _me = null;
    _client.setAccessToken(null);

    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kTokenKey);

    notifyListeners();
  }

  Future<void> _persistToken(String token) async {
    _token = token;
    _client.setAccessToken(token);

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTokenKey, token);
  }
}
