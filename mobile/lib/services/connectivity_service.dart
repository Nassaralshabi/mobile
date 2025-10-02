import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'database_service.dart';
import 'api_service.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final DatabaseService _dbService = DatabaseService();
  
  bool _isOnline = false;
  bool _isSyncing = false;
  String _syncStatus = 'غير متصل';
  DateTime? _lastSyncTime;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> initialize() async {
    // فحص الاتصال الأولي
    await _checkConnectivity();
    
    // مراقبة تغييرات الاتصال
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    
    // تشغيل مزامنة دورية كل 30 ثانية عند توفر الإنترنت
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isOnline && !_isSyncing) {
        syncData();
      }
    });

    // تحميل آخر وقت مزامنة
    final lastSync = await _dbService.getSetting('last_sync');
    if (lastSync != null) {
      _lastSyncTime = DateTime.tryParse(lastSync);
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasConnection = connectivityResults.any((result) => 
          result == ConnectivityResult.mobile || 
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);
      
      if (hasConnection) {
        // فحص الاتصال الفعلي بالخادم
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
      // تحديث إعدادات الخادم قبل الاختبار
      await ApiService.updateServerSettings();
      
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/test.php'),
        headers: {
          'Authorization': 'Bearer ${ApiService.authToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _checkConnectivity();
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
      final roomsResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/rooms.php'),
        headers: {'Authorization': 'Bearer token'},
      );
      
      if (roomsResponse.statusCode == 200) {
        final roomsData = json.decode(roomsResponse.body);
        await _updateLocalRooms(roomsData['rooms'] ?? []);
      }

      // مزامنة الموظفين
      final employeesResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/expenses.php?action=employees'),
        headers: {'Authorization': 'Bearer token'},
      );
      
      if (employeesResponse.statusCode == 200) {
        final employeesData = json.decode(employeesResponse.body);
        await _updateLocalEmployees(employeesData['employees'] ?? []);
      }

      // مزامنة الموردين
      final suppliersResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/expenses.php?action=suppliers'),
        headers: {'Authorization': 'Bearer token'},
      );
      
      if (suppliersResponse.statusCode == 200) {
        final suppliersData = json.decode(suppliersResponse.body);
        await _updateLocalSuppliers(suppliersData['suppliers'] ?? []);
      }

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
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/bookings.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token',
        },
        body: json.encode({
          'guest_name': booking['guest_name'],
          'guest_phone': booking['guest_phone'],
          'guest_email': booking['guest_email'],
          'guest_id_type': booking['guest_id_type'],
          'guest_id_number': booking['guest_id_number'],
          'guest_nationality': booking['guest_nationality'],
          'guest_address': booking['guest_address'],
          'room_number': booking['room_number'],
          'checkin_date': booking['checkin_date'],
          'checkout_date': booking['checkout_date'],
          'status': booking['status'],
          'notes': booking['notes'],
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // تحديث المعرف من الخادم
          await db.update('bookings', {
            'server_id': responseData['booking_id'],
            'is_synced': 1,
          }, where: 'id = ?', whereArgs: [localId]);
        }
      } else {
        throw Exception('فشل في رفع الحجز');
      }
    }
  }

  Future<void> _syncPayment(int localId, String action) async {
    final db = await _dbService.database;
    final payments = await db.query('payments', where: 'id = ?', whereArgs: [localId]);
    
    if (payments.isEmpty) return;
    
    final payment = payments.first;
    
    if (action == 'create') {
      // الحصول على معرف الحجز من الخادم
      final bookings = await db.query('bookings', where: 'id = ?', whereArgs: [payment['booking_id']]);
      if (bookings.isEmpty || bookings.first['server_id'] == null) {
        throw Exception('الحجز غير متزامن');
      }
      
      final serverBookingId = bookings.first['server_id'];
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/payments.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token',
        },
        body: json.encode({
          'booking_id': serverBookingId,
          'amount': payment['amount'],
          'payment_method': payment['payment_method'],
          'payment_date': payment['payment_date'],
          'notes': payment['notes'],
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          await db.update('payments', {
            'server_id': responseData['payment_id'],
            'server_booking_id': serverBookingId,
            'is_synced': 1,
          }, where: 'id = ?', whereArgs: [localId]);
        }
      } else {
        throw Exception('فشل في رفع الدفعة');
      }
    }
  }

  Future<void> _syncExpense(int localId, String action) async {
    final db = await _dbService.database;
    final expenses = await db.query('expenses', where: 'id = ?', whereArgs: [localId]);
    
    if (expenses.isEmpty) return;
    
    final expense = expenses.first;
    
    if (action == 'create') {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/expenses.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token',
        },
        body: json.encode({
          'expense_type': expense['expense_type'],
          'related_id': expense['related_id'],
          'description': expense['description'],
          'amount': expense['amount'],
          'date': expense['date'],
          'created_by': expense['created_by'],
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          await db.update('expenses', {
            'server_id': responseData['expense_id'],
            'is_synced': 1,
          }, where: 'id = ?', whereArgs: [localId]);
        }
      } else {
        throw Exception('فشل في رفع المصروف');
      }
    }
  }

  Future<void> _syncSalaryWithdrawal(int localId, String action) async {
    final db = await _dbService.database;
    final withdrawals = await db.query('salary_withdrawals', where: 'id = ?', whereArgs: [localId]);
    
    if (withdrawals.isEmpty) return;
    
    final withdrawal = withdrawals.first;
    
    if (action == 'create') {
      // الحصول على معرف الموظف من الخادم
      final employees = await db.query('employees', where: 'id = ?', whereArgs: [withdrawal['employee_id']]);
      if (employees.isEmpty || employees.first['server_id'] == null) {
        throw Exception('الموظف غير متزامن');
      }
      
      final serverEmployeeId = employees.first['server_id'];
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/expenses.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token',
        },
        body: json.encode({
          'action': 'add_salary_withdrawal',
          'employee_id': serverEmployeeId,
          'amount': withdrawal['amount'],
          'date': withdrawal['date'],
          'notes': withdrawal['notes'],
          'withdrawal_type': withdrawal['withdrawal_type'],
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          await db.update('salary_withdrawals', {
            'server_id': responseData['withdrawal_id'],
            'server_employee_id': serverEmployeeId,
            'is_synced': 1,
          }, where: 'id = ?', whereArgs: [localId]);
        }
      } else {
        throw Exception('فشل في رفع سحب الراتب');
      }
    }
  }

  // تحديث البيانات المحلية
  Future<void> _updateLocalRooms(List<dynamic> serverRooms) async {
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

  Future<void> _updateLocalEmployees(List<dynamic> serverEmployees) async {
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

  Future<void> _updateLocalSuppliers(List<dynamic> serverSuppliers) async {
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
  Future<void> forcSync() async {
    if (!_isOnline) {
      await _checkConnectivity();
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
