import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_client.dart';

class ApiService {
  final ApiClient _apiClient;

  // API endpoints
  static const String _bookingsEndpoint = 'bookings.php';
  static const String _roomsEndpoint = 'rooms.php';
  static const String _reportsEndpoint = 'reports.php';
  static const String _expensesEndpoint = 'expenses.php';
  static const String _notesEndpoint = 'notes.php';
  static const String _paymentsEndpoint = 'payments.php';
  static const String _bookingNotesEndpoint = 'booking_notes.php';
  static const String _cashRegisterEndpoint = 'cash_register.php';
  static const String _employeesEndpoint = 'employees.php';
  static const String _suppliersEndpoint = 'suppliers.php';
  static const String _salaryWithdrawalsEndpoint = 'salary_withdrawals.php';

  ApiService(AuthService authService, {String? baseUrl}) 
      : _apiClient = ApiClient(
          baseUrl: baseUrl ?? 'http://localhost/marina-hotel/api',
          authService: authService,
          client: http.Client(),
        );

  // Bookings API
  Future<List<Map<String, dynamic>>> getBookings() async {
    final data = await _apiClient.get(_bookingsEndpoint);
    return List<Map<String, dynamic>>.from(data['bookings'] ?? []);
  }

  Future<void> addBooking(Map<String, dynamic> bookingData) async {
    await _apiClient.post(_bookingsEndpoint, bookingData);
  }

  Future<void> updateBooking(int bookingId, Map<String, dynamic> bookingData) async {
    await _apiClient.put('$_bookingsEndpoint?id=$bookingId', bookingData);
  }

  // Rooms API
  Future<List<Map<String, dynamic>>> getRooms() async {
    final data = await _apiClient.get(_roomsEndpoint);
    return List<Map<String, dynamic>>.from(data['rooms'] ?? []);
  }

  // Reports API
  Future<Map<String, dynamic>> getReports() async {
    return await _apiClient.get(_reportsEndpoint);
  }

  // Expenses API
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final data = await _apiClient.get(_expensesEndpoint);
    return List<Map<String, dynamic>>.from(data['expenses'] ?? []);
  }

  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    await _apiClient.post(_expensesEndpoint, expenseData);
  }

  // Notes API
  Future<List<Map<String, dynamic>>> getNotes() async {
    final data = await _apiClient.get(_notesEndpoint);
    return List<Map<String, dynamic>>.from(data['notes'] ?? []);
  }

  Future<void> addNote(Map<String, dynamic> noteData) async {
    await _apiClient.post(_notesEndpoint, noteData);
  }

  // Payment API
  Future<List<Map<String, dynamic>>> getPayments({int? bookingId}) async {
    String url = _paymentsEndpoint;
    if (bookingId != null) {
      url += '?booking_id=$bookingId';
    }
    final data = await _apiClient.get(url);
    return List<Map<String, dynamic>>.from(data['payments'] ?? []);
  }

  Future<void> addPayment(Map<String, dynamic> paymentData) async {
    await _apiClient.post(_paymentsEndpoint, paymentData);
  }

  // Booking Notes API
  Future<List<Map<String, dynamic>>> getBookingNotes(int bookingId) async {
    final data = await _apiClient.get('$_bookingNotesEndpoint?booking_id=$bookingId');
    return List<Map<String, dynamic>>.from(data['notes'] ?? []);
  }

  Future<void> addBookingNote(Map<String, dynamic> noteData) async {
    await _apiClient.post(_bookingNotesEndpoint, noteData);
  }

  // Cash Register API
  Future<Map<String, dynamic>> getCashRegister() async {
    return await _apiClient.get(_cashRegisterEndpoint);
  }

  // Employees API
  Future<List<Map<String, dynamic>>> getEmployees() async {
    final data = await _apiClient.get(_employeesEndpoint);
    return List<Map<String, dynamic>>.from(data['employees'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final data = await _apiClient.get(_suppliersEndpoint);
    return List<Map<String, dynamic>>.from(data['suppliers'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getSalaryWithdrawals() async {
    final data = await _apiClient.get(_salaryWithdrawalsEndpoint);
    return List<Map<String, dynamic>>.from(data['withdrawals'] ?? []);
  }

  Future<void> addSalaryWithdrawal(Map<String, dynamic> withdrawalData) async {
    await _apiClient.post(_salaryWithdrawalsEndpoint, withdrawalData);
  }
}
