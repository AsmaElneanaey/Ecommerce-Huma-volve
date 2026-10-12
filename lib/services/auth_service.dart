import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    
    final cachedUserJson = prefs.getString('cached_user');
    if (cachedUserJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(cachedUserJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    if (isAuthenticated) {
      try {
        await fetchProfile();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<AuthResponseModel> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      final authData = AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      _token = authData.accessToken;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', authData.accessToken);
      await prefs.setString('refresh_token', authData.refreshToken);

      await fetchProfile();

      _isLoading = false;
      notifyListeners();
      return authData;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? avatar,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.users,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'avatar': avatar ?? 'https://i.pravatar.cc/300',
        },
      );

      final newUser = UserModel.fromJson(response.data as Map<String, dynamic>);
      _isLoading = false;
      notifyListeners();
      return newUser;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<UserModel?> fetchProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);
      _currentUser = UserModel.fromJson(response.data as Map<String, dynamic>);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user', jsonEncode(_currentUser!.toJson()));

      notifyListeners();
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('cached_user');
    notifyListeners();
  }
}
