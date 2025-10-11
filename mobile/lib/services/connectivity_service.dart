import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ConnectivityService extends ChangeNotifier {
  static ConnectivityService? _instance;

  final Connectivity _connectivity = Connectivity();
  final DatabaseService _dbService = DatabaseService();
  late ApiService _apiService;
  
  bool _isOnline = false;
  bool _isSyncing = false;
  String _syncStatus = 'غير متصل';
  DateTime? _lastSyncTime;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;

  factory ConnectivityService({AuthService? authService, ApiService? apiService}) {
    if (_instance == null) {
      final resolvedAuth = authService ?? AuthService();
      final resolvedApi = apiService ?? ApiService(resolvedAuth);
      _instance = ConnectivityService._internal(resolvedApi);
    } else if (apiService != null) {
      _instance!._setApiService(apiService);
    } else if (authService != null) {
      _instance!._setApiService(ApiService(authService));
    }
    return _instance!;
  }

  ConnectivityService._internal(ApiService apiService) {
    _setApiService(apiService);
    _initialize();
  }

  void _setApiService(ApiService apiService) {
    _apiService = apiService;
  }

  bool _isSuccessfulResponse(Map<String, dynamic> response) {
    if (response.isEmpty) return false;
    final successValue = response['success'];
    if (successValue is bool) {
      return successValue;
    }
    final statusValue = response['status'];
    if (statusValue is String) {
      return statusValue.toLowerCase() == 'success';
    }
    return true;
  }

  String _responseMessage(Map<String, dynamic> response, String fallback) {
    final message = response['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }

  int? _extractIntId(Map<String, dynamic> response, List<String> keys) {
    for (final key in keys) {
      final value = response[key];
      if (value == null) continue;
      if (value is int) {
        return value;
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  Future<void> initialize() async {
    await _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    await _initialize();
  }

  Future<void> _initialize() async {
    final initialStatus = await _connectivity.checkConnectivity();
    await _handleConnectivity(initialStatus);

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) async {
      await _handleConnectivity(result);
    });

    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isOnline && !_isSyncing) {
        syncData();
      }
    });

    final lastSync = await _dbService.getSetting('last_sync');
    if (lastSync != null) {
      _lastSyncTime = DateTime.tryParse(lastSync);
    }
  }

  Future<void> _handleConnectivity(ConnectivityResult result) async {
    try {
      final hasConnection = result != ConnectivityResult.none;

      if (hasConnection) {
        _isOnline = await _testServerConnection();
      } else {
        _isOnline = false;
      }

      _updateSyncStatus();
      notifyListeners();
    } catch (e) {
      _isOnline = false;
      _syncStatus = 'خطأ في فحص الاتصال';
      notifyListeners();
    }
  }

  Future<bool> _testServerConnection() async {
    try {
      await _apiService.getReports();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _updateSyncStatus() {
    if (_isSyncing) {
      _syncStatus = 'جاري المزامنة...';
    } else if (_isOnline) {
      _syncStatus = 'متصل - جاهز للمزامنة';
    } else {
      _syncStatus = 'غير متصل - وضع عدم الاتصال';
    }
  }

  // مزامنة البيانات مع الخادم
  Future<void> syncData() async {
    if (!_isOnline || _isSyncing) return;

    _isSyncing = true;
    _updateSyncStatus();
    notifyListeners();

    try {
      // 1. مزامنة البيانات المرجعية (الغرف، الموظفين، الموردين)
      await _syncReferenceData();
      
      // 2. رفع البيانات المحلية غير المتزامنة
      await _uploadLocalData();
      
      // 3. تحديث آخر وقت مزامنة
      _lastSyncTime = DateTime.now();
      await _dbService.setSetting('last_sync', _lastSyncTime!.toIso8601String());
      
      _syncStatus = 'تمت المزامنة بنجاح';
      
    } catch (e) {
      _syncStatus = 'خطأ في المزامنة: ${e.toString()}';
      if (kDebugMode) {
        print('Sync error: $e');
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
      
      // إعادة تعيين حالة المزامنة بعد 3 ثوان
      Timer(const Duration(seconds: 3), () {
        _updateSyncStatus();
        notifyListeners();
      });
    }
  }

  // مزامنة البيانات المرجعية من الخادم
  Future<void> _syncReferenceData() async {
    try {
      // مزامنة الغرف
      final serverRooms = await _apiService.getRooms();
      await _updateLocalRooms(serverRooms);

      // مزامنة الموظفين
      final serverEmployees = await _apiService.getEmployees();
      await _updateLocalEmployees(serverEmployees);

      // مزامنة الموردين
      final serverSuppliers = await _apiService.getSuppliers();
      await _updateLocalSuppliers(serverSuppliers);

    } catch (e) {
      throw Exception('فشل في مزامنة البيانات المرجعية: $e');
    }
  }

  // رفع البيانات المحلية غير المتزامنة
  Future<void> _uploadLocalData() async {
    final syncQueue = await _dbService.getSyncQueue();
    
    for (var item in syncQueue) {
      try {
        await _processSyncItem(item);
        await _dbService.clearSyncQueue(item['id']);
      } catch (e) {
        await _dbService.updateSyncQueueError(item['id'], e.toString());
        if (kDebugMode) {
          print('Failed to sync item ${item['id']}: $e');
        }
      }
    }
  }

  Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final tableName = item['table_name'];
    final recordId = item['record_id'];
    final action = item['action'];
    
    switch (tableName) {
      case 'bookings':
        await _syncBooking(recordId, action);
        break;
      case 'payments':
        await _syncPayment(recordId, action);
        break;
      case 'expenses':
        await _syncExpense(recordId, action);
        break;
      case 'salary_withdrawals':
        await _syncSalaryWithdrawal(recordId, action);
        break;
    }
  }

  Future<void> _syncBooking(int localId, String action) async {
    final db = await _dbService.database;
    final bookings = await db.query('bookings', where: 'id = ?', whereArgs: [localId]);
    
    if (bookings.isEmpty) return;
    
    final booking = bookings.first;
    
    if (action == 'create') {
      final response = await _apiService.addBooking(Map<String, dynamic>.from(booking));
      if (!_isSuccessfulResponse(response)) {
        throw Exception(_responseMessage(response, 'فشل في مزامنة الحجز'));
      }

      final serverId = _extractIntId(response, ['booking_id', 'id', 'server_id']);
      
      await db.update('bookings', {
        if (serverId != null) 'server_id': serverId,
        'is_synced': 1,
      }, where: 'id = ?', whereArgs: [localId]);
    }
  }

  Future<void> _syncPayment(int localId, String action) async {
    final db = await _dbService.database;
    final payments = await db.query('payments', where: 'id = ?', whereArgs: [localId]);
    
    if (payments.isEmpty) return;
    
    final payment = payments.first;
    
    if (action == 'create') {
      final bookings = await db.query('bookings', where: 'id = ?', whereArgs: [payment['booking_id']]);
      if (bookings.isEmpty || bookings.first['server_id'] == null) {
        throw Exception('الحجز غير متزامن');
      }
      
      final serverBookingId = bookings.first['server_id'];
      final payload = Map<String, dynamic>.from(payment)..['booking_id'] = serverBookingId;
      final response = await _apiService.addPayment(payload);
      if (!_isSuccessfulResponse(response)) {
        throw Exception(_responseMessage(response, 'فشل في مزامنة الدفعة'));
      }

      final paymentId = _extractIntId(response, ['payment_id', 'id', 'server_id']);
      
      await db.update('payments', {
        if (paymentId != null) 'server_id': paymentId,
        'server_booking_id': serverBookingId,
        'is_synced': 1,
      }, where: 'id = ?', whereArgs: [localId]);
    }
  }

  Future<void> _syncExpense(int localId, String action) async {
    final db = await _dbService.database;
    final expenses = await db.query('expenses', where: 'id = ?', whereArgs: [localId]);
    
    if (expenses.isEmpty) return;
    
    final expense = expenses.first;
    
    if (action == 'create') {
      final response = await _apiService.addExpense(Map<String, dynamic>.from(expense));
      if (!_isSuccessfulResponse(response)) {
        throw Exception(_responseMessage(response, 'فشل في مزامنة المصروف'));
      }

      final expenseId = _extractIntId(response, ['expense_id', 'id', 'server_id']);

      await db.update('expenses', {
        if (expenseId != null) 'server_id': expenseId,
        'is_synced': 1,
      }, where: 'id = ?', whereArgs: [localId]);
    }
  }

  Future<void> _syncSalaryWithdrawal(int localId, String action) async {
    final db = await _dbService.database;
    final withdrawals = await db.query('salary_withdrawals', where: 'id = ?', whereArgs: [localId]);
    
    if (withdrawals.isEmpty) return;
    
    final withdrawal = withdrawals.first;
    
    if (action == 'create') {
      final employees = await db.query('employees', where: 'id = ?', whereArgs: [withdrawal['employee_id']]);
      if (employees.isEmpty || employees.first['server_id'] == null) {
        throw Exception('الموظف غير متزامن');
      }
      
      final serverEmployeeId = employees.first['server_id'];
      final payload = Map<String, dynamic>.from(withdrawal)..['employee_id'] = serverEmployeeId;
      final response = await _apiService.addSalaryWithdrawal(payload);
      if (!_isSuccessfulResponse(response)) {
        throw Exception(_responseMessage(response, 'فشل في مزامنة سحب الراتب'));
      }

      final withdrawalId = _extractIntId(response, ['withdrawal_id', 'id', 'server_id']);
      
      await db.update('salary_withdrawals', {
        if (withdrawalId != null) 'server_id': withdrawalId,
        'server_employee_id': serverEmployeeId,
        'is_synced': 1,
      }, where: 'id = ?', whereArgs: [localId]);
    }
  }

  // تحديث البيانات المحلية
  Future<void> _updateLocalRooms(List<Map<String, dynamic>> serverRooms) async {
    final db = await _dbService.database;
    
    for (var serverRoom in serverRooms) {
      final existingRooms = await db.query('rooms', 
          where: 'room_number = ?', 
          whereArgs: [serverRoom['room_number']]);
      
      if (existingRooms.isNotEmpty) {
        // تحديث الغرفة الموجودة
        await db.update('rooms', {
          'server_id': serverRoom['id'],
          'type': serverRoom['type'],
          'price': serverRoom['price'],
          'status': serverRoom['status'],
          'is_synced': 1,
        }, where: 'room_number = ?', whereArgs: [serverRoom['room_number']]);
      } else {
        // إضافة غرفة جديدة
        await db.insert('rooms', {
          'server_id': serverRoom['id'],
          'room_number': serverRoom['room_number'],
          'type': serverRoom['type'],
          'price': serverRoom['price'],
          'status': serverRoom['status'],
          'created_at': DateTime.now().toIso8601String(),
          'is_synced': 1,
        });
      }
    }
  }

  Future<void> _updateLocalEmployees(List<Map<String, dynamic>> serverEmployees) async {
    final db = await _dbService.database;
    
    for (var serverEmployee in serverEmployees) {
      final existingEmployees = await db.query('employees', 
          where: 'server_id = ?', 
          whereArgs: [serverEmployee['id']]);
      
      if (existingEmployees.isNotEmpty) {
        // تحديث الموظف الموجود
        await db.update('employees', {
          'name': serverEmployee['name'],
          'basic_salary': serverEmployee['basic_salary'],
          'status': serverEmployee['status'],
          'is_synced': 1,
        }, where: 'server_id = ?', whereArgs: [serverEmployee['id']]);
      } else {
        // إضافة موظف جديد
        await db.insert('employees', {
          'server_id': serverEmployee['id'],
          'name': serverEmployee['name'],
          'basic_salary': serverEmployee['basic_salary'],
          'status': serverEmployee['status'],
          'created_at': DateTime.now().toIso8601String(),
          'is_synced': 1,
        });
      }
    }
  }

  Future<void> _updateLocalSuppliers(List<Map<String, dynamic>> serverSuppliers) async {
    final db = await _dbService.database;
    
    for (var serverSupplier in serverSuppliers) {
      final existingSuppliers = await db.query('suppliers', 
          where: 'server_id = ?', 
          whereArgs: [serverSupplier['id']]);
      
      if (existingSuppliers.isNotEmpty) {
        // تحديث المورد الموجود
        await db.update('suppliers', {
          'name': serverSupplier['name'],
          'contact_info': serverSupplier['contact_info'],
          'is_synced': 1,
        }, where: 'server_id = ?', whereArgs: [serverSupplier['id']]);
      } else {
        // إضافة مورد جديد
        await db.insert('suppliers', {
          'server_id': serverSupplier['id'],
          'name': serverSupplier['name'],
          'contact_info': serverSupplier['contact_info'] ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'is_synced': 1,
        });
      }
    }
  }

  // مزامنة يدوية
  Future<void> forceSync() async {
    if (!_isOnline) {
      final result = await _connectivity.checkConnectivity();
      await _handleConnectivity(result);
    }
    
    if (_isOnline) {
      await syncData();
    } else {
      _syncStatus = 'لا يمكن المزامنة - لا يوجد اتصال';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}
