
import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'marina_hotel.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // جدول الحجوزات المحلي
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        guest_name TEXT NOT NULL,
        guest_phone TEXT NOT NULL,
        guest_email TEXT,
        guest_id_type TEXT,
        guest_id_number TEXT,
        guest_nationality TEXT,
        guest_address TEXT,
        room_number TEXT NOT NULL,
        checkin_date TEXT NOT NULL,
        checkout_date TEXT,
        status TEXT DEFAULT 'محجوزة',
        notes TEXT,
        calculated_nights INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_action TEXT
      )
    ''');

    // جدول الغرف المحلي
    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        room_number TEXT UNIQUE NOT NULL,
        type TEXT NOT NULL,
        price REAL NOT NULL,
        status TEXT DEFAULT 'شاغرة',
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_action TEXT
      )
    ''');

    // جدول المدفوعات المحلي
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        booking_id INTEGER,
        server_booking_id INTEGER,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_action TEXT,
        FOREIGN KEY (booking_id) REFERENCES bookings (id)
      )
    ''');

    // جدول المصروفات المحلي
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        expense_type TEXT NOT NULL,
        related_id INTEGER,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        created_by INTEGER,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_action TEXT
      )
    ''');

    // جدول الموظفين المحلي
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        name TEXT NOT NULL,
        basic_salary REAL DEFAULT 0,
        status TEXT DEFAULT 'active',
        created_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_action TEXT
      )
    ''');

    // جدول الموردين المحلي
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        name TEXT NOT NULL,
        contact_info TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_action TEXT
      )
    ''');

    // جدول سحوبات الرواتب المحلي
    await db.execute('''
      CREATE TABLE salary_withdrawals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        employee_id INTEGER,
        server_employee_id INTEGER,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        withdrawal_type TEXT DEFAULT 'cash',
        created_at TEXT,
        is_synced INTEGER DEFAULT 0,
        sync_action TEXT,
        FOREIGN KEY (employee_id) REFERENCES employees (id)
      )
    ''');

    // جدول طابور المزامنة
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        data TEXT,
        created_at TEXT,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // جدول الإعدادات المحلية
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT
      )
    ''');

    // إدراج بيانات أولية
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // إعدادات افتراضية
    await db.insert('app_settings', {
      'key': 'last_sync',
      'value': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert('app_settings', {
      'key': 'offline_mode',
      'value': 'true',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  // دوال CRUD للحجوزات
  Future<List<Map<String, dynamic>>> getBookings() async {
    final db = await database;
    return await db.query('bookings', orderBy: 'created_at DESC');
  }

  Future<int> insertBooking(Map<String, dynamic> booking) async {
    final db = await database;
    booking['created_at'] = DateTime.now().toIso8601String();
    booking['is_synced'] = 0;
    booking['sync_action'] = 'create';
    
    final id = await db.insert('bookings', booking);
    await _addToSyncQueue('bookings', id, 'create', booking);
    return id;
  }

  Future<int> updateBooking(int id, Map<String, dynamic> booking) async {
    final db = await database;
    booking['updated_at'] = DateTime.now().toIso8601String();
    booking['is_synced'] = 0;
    booking['sync_action'] = 'update';
    
    final result = await db.update('bookings', booking, where: 'id = ?', whereArgs: [id]);
    await _addToSyncQueue('bookings', id, 'update', booking);
    return result;
  }

  Future<int> deleteBooking(int id) async {
    final db = await database;
    final booking = (await db.query('bookings', where: 'id = ?', whereArgs: [id])).first;
    await _addToSyncQueue('bookings', id, 'delete', booking as Map<String, dynamic>);
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  // دوال CRUD للغرف
  Future<List<Map<String, dynamic>>> getRooms() async {
    final db = await database;
    return await db.query('rooms', orderBy: 'room_number');
  }

  Future<int> insertRoom(Map<String, dynamic> room) async {
    final db = await database;
    room['created_at'] = DateTime.now().toIso8601String();
    room['is_synced'] = 0;
    room['sync_action'] = 'create';
    
    final id = await db.insert('rooms', room);
    await _addToSyncQueue('rooms', id, 'create', room);
    return id;
  }

  Future<int> updateRoom(int id, Map<String, dynamic> room) async {
    final db = await database;
    room['updated_at'] = DateTime.now().toIso8601String();
    room['is_synced'] = 0;
    room['sync_action'] = 'update';
    
    final result = await db.update('rooms', room, where: 'id = ?', whereArgs: [id]);
    await _addToSyncQueue('rooms', id, 'update', room);
    return result;
  }

  Future<int> deleteRoom(int id) async {
    final db = await database;
    final room = (await db.query('rooms', where: 'id = ?', whereArgs: [id])).first;
    await _addToSyncQueue('rooms', id, 'delete', room as Map<String, dynamic>);
    return await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }

  // دوال CRUD للمدفوعات
  Future<List<Map<String, dynamic>>> getPayments({int? bookingId}) async {
    final db = await database;
    if (bookingId != null) {
      return await db.query('payments', 
          where: 'booking_id = ?', 
          whereArgs: [bookingId],
          orderBy: 'payment_date DESC');
    }
    return await db.query('payments', orderBy: 'payment_date DESC');
  }

  Future<int> insertPayment(Map<String, dynamic> payment) async {
    final db = await database;
    payment['created_at'] = DateTime.now().toIso8601String();
    payment['is_synced'] = 0;
    payment['sync_action'] = 'create';

    final id = await db.insert('payments', payment);
    await _addToSyncQueue('payments', id, 'create', payment);
    return id;
  }

  // دوال CRUD للمصروفات
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  Future<int> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    expense['created_at'] = DateTime.now().toIso8601String();
    expense['is_synced'] = 0;
    expense['sync_action'] = 'create';

    final id = await db.insert('expenses', expense);
    await _addToSyncQueue('expenses', id, 'create', expense);
    return id;
  }

  // دوال للموظفين والموردين
  Future<List<Map<String, dynamic>>> getEmployees() async {
    final db = await database;
    return await db.query('employees', where: 'status = ?', whereArgs: ['active']);
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final db = await database;
    return await db.query('suppliers');
  }

  // دوال سحوبات الرواتب
  Future<List<Map<String, dynamic>>> getSalaryWithdrawals() async {
    final db = await database;
    return await db.query('salary_withdrawals', orderBy: 'date DESC');
  }

  Future<int> insertSalaryWithdrawal(Map<String, dynamic> withdrawal) async {
    final db = await database;
    withdrawal['created_at'] = DateTime.now().toIso8601String();
    withdrawal['is_synced'] = 0;
    withdrawal['sync_action'] = 'create';

    final id = await db.insert('salary_withdrawals', withdrawal);
    await _addToSyncQueue('salary_withdrawals', id, 'create', withdrawal);
    return id;
  }

  // إدارة طابور المزامنة
  Future<void> _addToSyncQueue(String tableName, int recordId, String action, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> clearSyncQueue(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSyncQueueError(int id, String error) async {
    final db = await database;
    await db.update('sync_queue', {
      'last_error': error,
      'retry_count': 1,
    }, where: 'id = ?', whereArgs: [id]);
  }

  // إعدادات التطبيق
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query('app_settings', where: 'key = ?', whereArgs: [key]);
    return result.isNotEmpty ? result.first['value'] as String? : null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('app_settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // تنظيف قاعدة البيانات
  Future<void> clearAllData() async {
    final db = await database;
    final tables = ['bookings', 'rooms', 'payments', 'expenses', 'employees', 'suppliers', 'salary_withdrawals', 'sync_queue'];
    
    for (String table in tables) {
      await db.delete(table);
    }
    
    await _insertInitialData(db);
  }

  // إغلاق قاعدة البيانات
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
