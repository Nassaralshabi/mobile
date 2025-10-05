
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  String? _username;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get username => _username;

  AuthService() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _token = await _secureStorage.read(key: 'auth_token');
    _username = await _secureStorage.read(key: 'username');
    if (_token != null) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password, bool isOnline) async {
    if (isOnline) {
      try {
        // Try to login online
        final prefs = await SharedPreferences.getInstance();
        final baseUrl = prefs.getString('server_url') ?? 'http://localhost/marina-hotel/api';
        final response = await http.post(
          Uri.parse('$baseUrl/login.php'),
          body: {
            'username': username,
            'password': password,
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            _isLoggedIn = true;
            _token = data['token'];
            _username = username;
            await _secureStorage.write(key: 'auth_token', value: _token);
            await _secureStorage.write(key: 'username', value: _username);
            await _secureStorage.write(key: 'password', value: password); // For offline login
            notifyListeners();
            return true;
          }
        }
        return false;
      } catch (e) {
        // If online login fails, try offline
        return _offlineLogin(username, password);
      }
    } else {
      // If offline, try to login with stored credentials
      return _offlineLogin(username, password);
    }
  }

  Future<bool> _offlineLogin(String username, String password) async {
    final storedUsername = await _secureStorage.read(key: 'username');
    final storedPassword = await _secureStorage.read(key: 'password');

    if (username == storedUsername && password == storedPassword) {
      _isLoggedIn = true;
      _token = await _secureStorage.read(key: 'auth_token');
      _username = storedUsername;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _username = null;
    await _secureStorage.deleteAll();
    notifyListeners();
  }

  Map<String, String> getAuthHeaders() {
    if (_token == null) return {};
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }
}
