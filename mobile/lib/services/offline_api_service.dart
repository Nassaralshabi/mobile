import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'connectivity_service.dart';
import 'api_service.dart';

class OfflineApiService {
  static final OfflineApiService _instance = OfflineApiService._internal();
  factory OfflineApiService() => _instance;
  OfflineApiService._internal();

  final DatabaseService _dbService = DatabaseService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final ApiService _apiService = ApiService();

  // Bookings
  Future<List<Map<String, dynamic>>> getBookings() async {
    if (_connectivityService.isOnline) {
      try {
        // محاولة جلب البيانات من الخادم
        final serverBookings = await _apiService.getBookings();
        // تحديث قاعدة البيانات المحلية
        await _updateLocalBookings(serverBookings);
        return serverBookings;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch from server, using local data: $e');
        }
      }
    }
    
    // جلب البيانات من قاعدة البيانات المحلية
    return await _dbService.getBookings();
  }

  Future<bool> addBooking(Map<String, dynamic> bookingData) async {
    try {
      // إضافة إلى قاعدة البيانات المحلية أولاً
      final localId = await _dbService.insertBooking(bookingData);
      
      if (_connectivityService.isOnline) {
        try {
          // محاولة الرفع للخادم فوراً
          final success = await _apiService.addBooking(bookingData);
          if (success) {
            // تحديث حالة المزامنة
            final db = await _dbService.database;
            await db.update('bookings', {
              'is_synced': 1,
              'sync_action': 'synced',
            }, where: 'id = ?', whereArgs: [localId]);
          }
          return success;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync booking immediately: $e');
          }
          // البيانات محفوظة محلياً وستتم المزامنة لاحقاً
          return true;
        }
      }
      
      // في الوضع غير المتصل، الحفظ المحلي يعتبر نجاحاً
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add booking: $e');
      }
      return false;
    }
  }

  Future<bool> updateBooking(int id, Map<String, dynamic> bookingData) async {
    try {
      // تحديث قاعدة البيانات المحلية
      await _dbService.updateBooking(id, bookingData);
      
      if (_connectivityService.isOnline) {
        try {
          // محاولة التحديث على الخادم
          final success = await _apiService.updateBooking(id, bookingData);
          if (success) {
            final db = await _dbService.database;
            await db.update('bookings', {
              'is_synced': 1,
              'sync_action': 'synced',
            }, where: 'id = ?', whereArgs: [id]);
          }
          return success;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync booking update: $e');
          }
          return true;
        }
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update booking: $e');
      }
      return false;
    }
  }

  // Rooms
  Future<List<Map<String, dynamic>>> getRooms() async {
    if (_connectivityService.isOnline) {
      try {
        final serverRooms = await _apiService.getRooms();
        await _updateLocalRooms(serverRooms);
        return serverRooms;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch rooms from server: $e');
        }
      }
    }
    
    return await _dbService.getRooms();
  }

  Future<List<Map<String, dynamic>>> getAvailableRooms({
    required String checkinDate,
    required String checkoutDate,
    String? roomType,
  }) async {
    // فحص التوفر محلياً
    final allRooms = await _dbService.getRooms();
    final bookings = await _dbService.getBookings();
    
    final availableRooms = <Map<String, dynamic>>[];
    
    for (var room in allRooms) {
      if (roomType != null && room['type'] != roomType) continue;
      
      // فحص إذا كانت الغرفة محجوزة في الفترة المطلوبة
      bool isAvailable = true;
      for (var booking in bookings) {
        if (booking['room_number'] == room['room_number'] &&
            booking['status'] == 'محجوزة') {
          final bookingCheckin = DateTime.parse(booking['checkin_date']);
          final bookingCheckout = booking['checkout_date'] != null 
              ? DateTime.parse(booking['checkout_date'])
              : bookingCheckin.add(const Duration(days: 30)); // افتراض 30 يوم إذا لم يحدد تاريخ مغادرة
          
          final requestedCheckin = DateTime.parse(checkinDate);
          final requestedCheckout = DateTime.parse(checkoutDate);
          
          // فحص التداخل في التواريخ
          if (requestedCheckin.isBefore(bookingCheckout) &&
              requestedCheckout.isAfter(bookingCheckin)) {
            isAvailable = false;
            break;
          }
        }
      }
      
      if (isAvailable) {
        availableRooms.add(room);
      }
    }
    
    return availableRooms;
  }

  // Payments
  Future<List<Map<String, dynamic>>> getPayments({int? bookingId}) async {
    if (_connectivityService.isOnline) {
      try {
        final serverPayments = await _apiService.getPayments(bookingId: bookingId);
        // تحديث البيانات المحلية
        await _updateLocalPayments(serverPayments, bookingId);
        return serverPayments;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch payments from server: $e');
        }
      }
    }
    
    return await _dbService.getPayments(bookingId: bookingId);
  }

  Future<bool> addPayment(Map<String, dynamic> paymentData) async {
    try {
      final localId = await _dbService.insertPayment(paymentData);
      
      if (_connectivityService.isOnline) {
        try {
          final success = await _apiService.addPayment(paymentData);
          if (success) {
            final db = await _dbService.database;
            await db.update('payments', {
              'is_synced': 1,
            }, where: 'id = ?', whereArgs: [localId]);
          }
          return success;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync payment: $e');
          }
          return true;
        }
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add payment: $e');
      }
      return false;
    }
  }

  // Expenses
  Future<List<Map<String, dynamic>>> getExpenses() async {
    if (_connectivityService.isOnline) {
      try {
        final serverExpenses = await _apiService.getExpenses();
        await _updateLocalExpenses(serverExpenses);
        return serverExpenses;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch expenses from server: $e');
        }
      }
    }
    
    return await _dbService.getExpenses();
  }

  Future<bool> addExpense(Map<String, dynamic> expenseData) async {
    try {
      final localId = await _dbService.insertExpense(expenseData);
      
      if (_connectivityService.isOnline) {
        try {
          final success = await _apiService.addExpense(expenseData);
          if (success) {
            final db = await _dbService.database;
            await db.update('expenses', {
              'is_synced': 1,
            }, where: 'id = ?', whereArgs: [localId]);
          }
          return success;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync expense: $e');
          }
          return true;
        }
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add expense: $e');
      }
      return false;
    }
  }

  // Employees & Suppliers
  Future<List<Map<String, dynamic>>> getEmployees() async {
    if (_connectivityService.isOnline) {
      try {
        final serverEmployees = await _apiService.getEmployees();
        await _updateLocalEmployees(serverEmployees);
        return serverEmployees;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch employees from server: $e');
        }
      }
    }
    
    return await _dbService.getEmployees();
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    if (_connectivityService.isOnline) {
      try {
        final serverSuppliers = await _apiService.getSuppliers();
        await _updateLocalSuppliers(serverSuppliers);
        return serverSuppliers;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch suppliers from server: $e');
        }
      }
    }
    
    return await _dbService.getSuppliers();
  }

  // Salary Withdrawals
  Future<List<Map<String, dynamic>>> getSalaryWithdrawals() async {
    if (_connectivityService.isOnline) {
      try {
        final serverWithdrawals = await _apiService.getSalaryWithdrawals();
        await _updateLocalSalaryWithdrawals(serverWithdrawals);
        return serverWithdrawals;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch salary withdrawals from server: $e');
        }
      }
    }
    
    return await _dbService.getSalaryWithdrawals();
  }

  Future<bool> addSalaryWithdrawal(Map<String, dynamic> withdrawalData) async {
    try {
      final localId = await _dbService.insertSalaryWithdrawal(withdrawalData);
      
      if (_connectivityService.isOnline) {
        try {
          final success = await _apiService.addSalaryWithdrawal(withdrawalData);
          if (success) {
            final db = await _dbService.database;
            await db.update('salary_withdrawals', {
              'is_synced': 1,
            }, where: 'id = ?', whereArgs: [localId]);
          }
          return success;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync salary withdrawal: $e');
          }
          return true;
        }
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add salary withdrawal: $e');
      }
      return false;
    }
  }

  // Helper methods to update local data
  Future<void> _updateLocalBookings(List<Map<String, dynamic>> serverBookings) async {
    final db = await _dbService.database;
    
    for (var serverBooking in serverBookings) {
      final existingBookings = await db.query('bookings', 
          where: 'server_id = ?', 
          whereArgs: [serverBooking['booking_id']]);
      
      if (existingBookings.isNotEmpty) {
        await db.update('bookings', {
          ...serverBooking,
          'server_id': serverBooking['booking_id'],
          'is_synced': 1,
        }, where: 'server_id = ?', whereArgs: [serverBooking['booking_id']]);
      } else {
        await db.insert('bookings', {
          ...serverBooking,
          'server_id': serverBooking['booking_id'],
          'is_synced': 1,
        });
      }
    }
  }

  Future<void> _updateLocalRooms(List<Map<String, dynamic>> serverRooms) async {
    final db = await _dbService.database;
    
    for (var serverRoom in serverRooms) {
      final existingRooms = await db.query('rooms', 
          where: 'room_number = ?', 
          whereArgs: [serverRoom['room_number']]);
      
      if (existingRooms.isNotEmpty) {
        await db.update('rooms', {
          'server_id': serverRoom['id'],
          'type': serverRoom['type'],
          'price': serverRoom['price'],
          'status': serverRoom['status'],
          'is_synced': 1,
        }, where: 'room_number = ?', whereArgs: [serverRoom['room_number']]);
      } else {
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

  Future<void> _updateLocalPayments(List<Map<String, dynamic>> serverPayments, int? bookingId) async {
    final db = await _dbService.database;
    
    for (var serverPayment in serverPayments) {
      final existingPayments = await db.query('payments', 
          where: 'server_id = ?', 
          whereArgs: [serverPayment['id']]);
      
      if (existingPayments.isEmpty) {
        await db.insert('payments', {
          'server_id': serverPayment['id'],
          'booking_id': bookingId,
          'server_booking_id': serverPayment['booking_id'],
          'amount': serverPayment['amount'],
          'payment_method': serverPayment['payment_method'],
          'payment_date': serverPayment['payment_date'],
          'notes': serverPayment['notes'],
          'created_at': serverPayment['created_at'],
          'is_synced': 1,
        });
      }
    }
  }

  Future<void> _updateLocalExpenses(List<Map<String, dynamic>> serverExpenses) async {
    final db = await _dbService.database;
    
    for (var serverExpense in serverExpenses) {
      final existingExpenses = await db.query('expenses', 
          where: 'server_id = ?', 
          whereArgs: [serverExpense['id']]);
      
      if (existingExpenses.isEmpty) {
        await db.insert('expenses', {
          'server_id': serverExpense['id'],
          'expense_type': serverExpense['expense_type'],
          'related_id': serverExpense['related_id'],
          'description': serverExpense['description'],
          'amount': serverExpense['amount'],
          'date': serverExpense['date'],
          'created_by': serverExpense['created_by'],
          'created_at': serverExpense['created_at'],
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
        await db.update('employees', {
          'name': serverEmployee['name'],
          'basic_salary': serverEmployee['basic_salary'],
          'status': serverEmployee['status'],
          'is_synced': 1,
        }, where: 'server_id = ?', whereArgs: [serverEmployee['id']]);
      } else {
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
        await db.update('suppliers', {
          'name': serverSupplier['name'],
          'contact_info': serverSupplier['contact_info'],
          'is_synced': 1,
        }, where: 'server_id = ?', whereArgs: [serverSupplier['id']]);
      } else {
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

  Future<void> _updateLocalSalaryWithdrawals(List<Map<String, dynamic>> serverWithdrawals) async {
    final db = await _dbService.database;
    
    for (var serverWithdrawal in serverWithdrawals) {
      final existingWithdrawals = await db.query('salary_withdrawals', 
          where: 'server_id = ?', 
          whereArgs: [serverWithdrawal['id']]);
      
      if (existingWithdrawals.isEmpty) {
        await db.insert('salary_withdrawals', {
          'server_id': serverWithdrawal['id'],
          'employee_id': null, // سيتم ربطه لاحقاً
          'server_employee_id': serverWithdrawal['employee_id'],
          'amount': serverWithdrawal['amount'],
          'date': serverWithdrawal['date'],
          'notes': serverWithdrawal['notes'],
          'withdrawal_type': serverWithdrawal['withdrawal_type'],
          'created_at': serverWithdrawal['created_at'],
          'is_synced': 1,
        });
      }
    }
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final syncQueue = await _dbService.getSyncQueue();
    final pendingCount = syncQueue.length;
    
    final lastSync = await _dbService.getSetting('last_sync');
    final lastSyncTime = lastSync != null ? DateTime.tryParse(lastSync) : null;
    
    return {
      'is_online': _connectivityService.isOnline,
      'is_syncing': _connectivityService.isSyncing,
      'sync_status': _connectivityService.syncStatus,
      'pending_sync_count': pendingCount,
      'last_sync_time': lastSyncTime,
    };
  }

  // Force sync
  Future<void> forceSync() async {
    await _connectivityService.forcSync();
  }
}
