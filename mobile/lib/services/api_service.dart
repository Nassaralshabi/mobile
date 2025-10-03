import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _baseUrl = 'http://localhost/marina-hotel/api';
  static String _authToken = 'your-auth-token-here';
  static String _apiKey = '';
  static String _username = '';
  static String _password = '';
  
  static String get baseUrl => _baseUrl;
  static String get authToken => _authToken;
  
  // تحديث إعدادات الخادم
  static Future<void> updateServerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('server_url') ?? 'http://localhost/marina-hotel/api';
    _authToken = prefs.getString('api_key') ?? 'your-auth-token-here';
    _apiKey = prefs.getString('api_key') ?? '';
    _username = prefs.getString('username') ?? '';
    _password = prefs.getString('password') ?? '';
  }

  final AuthService _authService;

  ApiService(this._authService);

  // Bookings API
  Future<List<Map<String, dynamic>>> getBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['bookings'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<bool> addBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings.php'),
        headers: _authService.getAuthHeaders(),
        body: json.encode(bookingData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding booking: $e');
      return false;
    }
  }

  Future<bool> updateBooking(int bookingId, Map<String, dynamic> bookingData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bookings.php?id=$bookingId'),
        headers: _authService.getAuthHeaders(),
        body: json.encode(bookingData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating booking: $e');
      return false;
    }
  }

  // Rooms API
  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rooms.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['rooms'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

  // Reports API
  Future<Map<String, dynamic>> getReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching reports: $e');
      return {};
    }
  }

  // Expenses API
  Future<List<Map<String, dynamic>>> getExpenses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/expenses.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['expenses'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching expenses: $e');
      return [];
    }
  }

  Future<bool> addExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/expenses.php'),
        headers: _authService.getAuthHeaders(),
        body: json.encode(expenseData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }

  // Notes API
  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['notes'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  Future<bool> addNote(Map<String, dynamic> noteData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes.php'),
        headers: _authService.getAuthHeaders(),
        body: json.encode(noteData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding note: $e');
      return false;
    }
  }

  // Payment API
  Future<List<Map<String, dynamic>>> getPayments({int? bookingId}) async {
    try {
      String url = '$baseUrl/payments.php';
      if (bookingId != null) {
        url += '?booking_id=$bookingId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['payments'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    }
  }

  Future<bool> addPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments.php'),
        headers: _authService.getAuthHeaders(),
        body: json.encode(paymentData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding payment: $e');
      return false;
    }
  }

  // Booking Notes API
  Future<List<Map<String, dynamic>>> getBookingNotes(int bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/booking_notes.php?booking_id=$bookingId'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['notes'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching booking notes: $e');
      return [];
    }
  }

  Future<bool> addBookingNote(Map<String, dynamic> noteData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/booking_notes.php'),
        headers: _authService.getAuthHeaders(),
        body: json.encode(noteData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding booking note: $e');
      return false;
    }
  }

  // Cash Register API
  Future<Map<String, dynamic>> getCashRegister() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cash_register.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching cash register: $e');
      return {};
    }
  }

  // Employees API
  Future<List<Map<String, dynamic>>> getEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['employees'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching employees: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/suppliers.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['suppliers'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching suppliers: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSalaryWithdrawals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/salary_withdrawals.php'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['withdrawals'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching salary withdrawals: $e');
      return [];
    }
  }

  Future<bool> addSalaryWithdrawal(Map<String, dynamic> withdrawalData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/salary_withdrawals.php'),
        headers: _authService.getAuthHeaders(),
        body: json.encode(withdrawalData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding salary withdrawal: $e');
      return false;
    }
  }
}
