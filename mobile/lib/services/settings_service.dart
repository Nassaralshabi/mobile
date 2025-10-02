import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  // إعدادات الخادم
  String _serverUrl = 'http://localhost/marina-hotel/api';
  String _apiKey = '';
  String _username = '';
  String _password = '';
  int _connectionTimeout = 10;

  // إعدادات المزامنة
  bool _autoSync = true;
  int _syncInterval = 30;
  int _retryAttempts = 3;
  bool _syncOnWifiOnly = false;
  bool _enableOfflineMode = true;

  // إعدادات التطبيق
  String _language = 'ar';
  String _theme = 'light';
  bool _enableNotifications = true;
  bool _enableAnalytics = false;
  bool _enableDebugMode = false;

  // Getters
  String get serverUrl => _serverUrl;
  String get apiKey => _apiKey;
  String get username => _username;
  String get password => _password;
  int get connectionTimeout => _connectionTimeout;

  bool get autoSync => _autoSync;
  int get syncInterval => _syncInterval;
  int get retryAttempts => _retryAttempts;
  bool get syncOnWifiOnly => _syncOnWifiOnly;
  bool get enableOfflineMode => _enableOfflineMode;

  String get language => _language;
  String get theme => _theme;
  bool get enableNotifications => _enableNotifications;
  bool get enableAnalytics => _enableAnalytics;
  bool get enableDebugMode => _enableDebugMode;

  // تهيئة الإعدادات
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  // تحميل الإعدادات من التخزين المحلي
  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    _serverUrl = _prefs!.getString('server_url') ?? 'http://localhost/marina-hotel/api';
    _apiKey = _prefs!.getString('api_key') ?? '';
    _username = _prefs!.getString('username') ?? '';
    _password = _prefs!.getString('password') ?? '';
    _connectionTimeout = _prefs!.getInt('connection_timeout') ?? 10;

    _autoSync = _prefs!.getBool('auto_sync') ?? true;
    _syncInterval = _prefs!.getInt('sync_interval') ?? 30;
    _retryAttempts = _prefs!.getInt('retry_attempts') ?? 3;
    _syncOnWifiOnly = _prefs!.getBool('sync_wifi_only') ?? false;
    _enableOfflineMode = _prefs!.getBool('enable_offline_mode') ?? true;

    _language = _prefs!.getString('language') ?? 'ar';
    _theme = _prefs!.getString('theme') ?? 'light';
    _enableNotifications = _prefs!.getBool('enable_notifications') ?? true;
    _enableAnalytics = _prefs!.getBool('enable_analytics') ?? false;
    _enableDebugMode = _prefs!.getBool('enable_debug_mode') ?? false;

    notifyListeners();
  }

  // حفظ إعدادات الخادم
  Future<void> updateServerSettings({
    required String serverUrl,
    String? apiKey,
    String? username,
    String? password,
    int? connectionTimeout,
  }) async {
    if (_prefs == null) return;

    _serverUrl = serverUrl.trim();
    if (apiKey != null) _apiKey = apiKey.trim();
    if (username != null) _username = username.trim();
    if (password != null) _password = password.trim();
    if (connectionTimeout != null) _connectionTimeout = connectionTimeout;

    await _prefs!.setString('server_url', _serverUrl);
    await _prefs!.setString('api_key', _apiKey);
    await _prefs!.setString('username', _username);
    await _prefs!.setString('password', _password);
    await _prefs!.setInt('connection_timeout', _connectionTimeout);

    notifyListeners();
  }

  // حفظ إعدادات المزامنة
  Future<void> updateSyncSettings({
    bool? autoSync,
    int? syncInterval,
    int? retryAttempts,
    bool? syncOnWifiOnly,
    bool? enableOfflineMode,
  }) async {
    if (_prefs == null) return;

    if (autoSync != null) _autoSync = autoSync;
    if (syncInterval != null) _syncInterval = syncInterval;
    if (retryAttempts != null) _retryAttempts = retryAttempts;
    if (syncOnWifiOnly != null) _syncOnWifiOnly = syncOnWifiOnly;
    if (enableOfflineMode != null) _enableOfflineMode = enableOfflineMode;

    await _prefs!.setBool('auto_sync', _autoSync);
    await _prefs!.setInt('sync_interval', _syncInterval);
    await _prefs!.setInt('retry_attempts', _retryAttempts);
    await _prefs!.setBool('sync_wifi_only', _syncOnWifiOnly);
    await _prefs!.setBool('enable_offline_mode', _enableOfflineMode);

    notifyListeners();
  }

  // حفظ إعدادات التطبيق
  Future<void> updateAppSettings({
    String? language,
    String? theme,
    bool? enableNotifications,
    bool? enableAnalytics,
    bool? enableDebugMode,
  }) async {
    if (_prefs == null) return;

    if (language != null) _language = language;
    if (theme != null) _theme = theme;
    if (enableNotifications != null) _enableNotifications = enableNotifications;
    if (enableAnalytics != null) _enableAnalytics = enableAnalytics;
    if (enableDebugMode != null) _enableDebugMode = enableDebugMode;

    await _prefs!.setString('language', _language);
    await _prefs!.setString('theme', _theme);
    await _prefs!.setBool('enable_notifications', _enableNotifications);
    await _prefs!.setBool('enable_analytics', _enableAnalytics);
    await _prefs!.setBool('enable_debug_mode', _enableDebugMode);

    notifyListeners();
  }

  // إعادة تعيين جميع الإعدادات
  Future<void> resetAllSettings() async {
    if (_prefs == null) return;

    await _prefs!.clear();
    
    // إعادة تعيين القيم الافتراضية
    _serverUrl = 'http://localhost/marina-hotel/api';
    _apiKey = '';
    _username = '';
    _password = '';
    _connectionTimeout = 10;

    _autoSync = true;
    _syncInterval = 30;
    _retryAttempts = 3;
    _syncOnWifiOnly = false;
    _enableOfflineMode = true;

    _language = 'ar';
    _theme = 'light';
    _enableNotifications = true;
    _enableAnalytics = false;
    _enableDebugMode = false;

    notifyListeners();
  }

  // تصدير الإعدادات كـ JSON
  Map<String, dynamic> exportSettings() {
    return {
      'server_settings': {
        'server_url': _serverUrl,
        'api_key': _apiKey,
        'username': _username,
        'connection_timeout': _connectionTimeout,
      },
      'sync_settings': {
        'auto_sync': _autoSync,
        'sync_interval': _syncInterval,
        'retry_attempts': _retryAttempts,
        'sync_wifi_only': _syncOnWifiOnly,
        'enable_offline_mode': _enableOfflineMode,
      },
      'app_settings': {
        'language': _language,
        'theme': _theme,
        'enable_notifications': _enableNotifications,
        'enable_analytics': _enableAnalytics,
        'enable_debug_mode': _enableDebugMode,
      },
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // استيراد الإعدادات من JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      final serverSettings = settings['server_settings'] as Map<String, dynamic>?;
      if (serverSettings != null) {
        await updateServerSettings(
          serverUrl: serverSettings['server_url'] ?? _serverUrl,
          apiKey: serverSettings['api_key'],
          username: serverSettings['username'],
          connectionTimeout: serverSettings['connection_timeout'],
        );
      }

      final syncSettings = settings['sync_settings'] as Map<String, dynamic>?;
      if (syncSettings != null) {
        await updateSyncSettings(
          autoSync: syncSettings['auto_sync'],
          syncInterval: syncSettings['sync_interval'],
          retryAttempts: syncSettings['retry_attempts'],
          syncOnWifiOnly: syncSettings['sync_wifi_only'],
          enableOfflineMode: syncSettings['enable_offline_mode'],
        );
      }

      final appSettings = settings['app_settings'] as Map<String, dynamic>?;
      if (appSettings != null) {
        await updateAppSettings(
          language: appSettings['language'],
          theme: appSettings['theme'],
          enableNotifications: appSettings['enable_notifications'],
          enableAnalytics: appSettings['enable_analytics'],
          enableDebugMode: appSettings['enable_debug_mode'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error importing settings: $e');
      }
      rethrow;
    }
  }

  // التحقق من صحة رابط الخادم
  bool isValidServerUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasAbsolutePath && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // الحصول على رابط API كامل
  String getApiUrl(String endpoint) {
    final baseUrl = _serverUrl.endsWith('/') ? _serverUrl : '$_serverUrl/';
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseUrl$cleanEndpoint';
  }

  // الحصول على headers للطلبات
  Map<String, String> getApiHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }

    if (_username.isNotEmpty && _password.isNotEmpty) {
      final credentials = '$_username:$_password';
      final encoded = base64Encode(utf8.encode(credentials));
      headers['Authorization'] = 'Basic $encoded';
    }

    return headers;
  }

  // حفظ آخر وقت مزامنة
  Future<void> updateLastSyncTime() async {
    if (_prefs == null) return;
    await _prefs!.setString('last_sync_time', DateTime.now().toIso8601String());
  }

  // الحصول على آخر وقت مزامنة
  DateTime? getLastSyncTime() {
    if (_prefs == null) return null;
    final timeString = _prefs!.getString('last_sync_time');
    return timeString != null ? DateTime.tryParse(timeString) : null;
  }

  // حفظ حالة الاتصال الأخيرة
  Future<void> updateConnectionStatus(bool isConnected, {String? error}) async {
    if (_prefs == null) return;
    await _prefs!.setBool('last_connection_status', isConnected);
    await _prefs!.setString('last_connection_check', DateTime.now().toIso8601String());
    if (error != null) {
      await _prefs!.setString('last_connection_error', error);
    }
  }

  // الحصول على حالة الاتصال الأخيرة
  Map<String, dynamic> getLastConnectionStatus() {
    if (_prefs == null) return {};
    
    return {
      'is_connected': _prefs!.getBool('last_connection_status') ?? false,
      'last_check': _prefs!.getString('last_connection_check'),
      'last_error': _prefs!.getString('last_connection_error'),
    };
  }
}
