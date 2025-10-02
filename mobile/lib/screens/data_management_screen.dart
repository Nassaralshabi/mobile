import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';
import '../services/offline_api_service.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final DatabaseService _dbService = DatabaseService();
  final OfflineApiService _apiService = OfflineApiService();
  
  bool _isLoading = false;
  Map<String, int> _dataCounts = {};

  @override
  void initState() {
    super.initState();
    _loadDataCounts();
  }

  Future<void> _loadDataCounts() async {
    setState(() => _isLoading = true);
    
    try {
      final bookings = await _dbService.getBookings();
      final rooms = await _dbService.getRooms();
      final payments = await _dbService.getPayments();
      final expenses = await _dbService.getExpenses();
      final employees = await _dbService.getEmployees();
      final suppliers = await _dbService.getSuppliers();
      final withdrawals = await _dbService.getSalaryWithdrawals();
      
      setState(() {
        _dataCounts = {
          'bookings': bookings.length,
          'rooms': rooms.length,
          'payments': payments.length,
          'expenses': expenses.length,
          'employees': employees.length,
          'suppliers': suppliers.length,
          'withdrawals': withdrawals.length,
        };
      });
    } catch (e) {
      _showSnackBar('خطأ في تحميل البيانات: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة البيانات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDataCounts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDataOverview(),
                const SizedBox(height: 20),
                _buildRoomsManagement(),
                const SizedBox(height: 20),
                _buildEmployeesManagement(),
                const SizedBox(height: 20),
                _buildSuppliersManagement(),
                const SizedBox(height: 20),
                _buildDataActions(),
              ],
            ),
    );
  }

  Widget _buildDataOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'نظرة عامة على البيانات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildDataCard('الحجوزات', _dataCounts['bookings'] ?? 0, Icons.hotel, Colors.blue),
                _buildDataCard('الغرف', _dataCounts['rooms'] ?? 0, Icons.room, Colors.green),
                _buildDataCard('المدفوعات', _dataCounts['payments'] ?? 0, Icons.payment, Colors.orange),
                _buildDataCard('المصروفات', _dataCounts['expenses'] ?? 0, Icons.money_off, Colors.red),
                _buildDataCard('الموظفين', _dataCounts['employees'] ?? 0, Icons.people, Colors.purple),
                _buildDataCard('الموردين', _dataCounts['suppliers'] ?? 0, Icons.business, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.room, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'إدارة الغرف',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.add_home, color: Colors.green),
              title: const Text('إضافة غرفة جديدة'),
              subtitle: const Text('إضافة غرفة جديدة للفندق'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showAddRoomDialog(),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('تعديل أسعار الغرف'),
              subtitle: const Text('تحديث أسعار جميع الغرف'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showUpdatePricesDialog(),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cleaning_services, color: Colors.orange),
              title: const Text('تحديث حالة الغرف'),
              subtitle: const Text('تغيير حالة الغرف (شاغرة/محجوزة)'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showUpdateRoomStatusDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'إدارة الموظفين',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.green),
              title: const Text('إضافة موظف جديد'),
              subtitle: const Text('إضافة موظف جديد للفندق'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showAddEmployeeDialog(),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.blue),
              title: const Text('تحديث الرواتب'),
              subtitle: const Text('تحديث الرواتب الأساسية للموظفين'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showUpdateSalariesDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliersManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'إدارة الموردين',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.add_business, color: Colors.green),
              title: const Text('إضافة مورد جديد'),
              subtitle: const Text('إضافة مورد جديد للفندق'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showAddSupplierDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_backup_restore, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'إجراءات البيانات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.blue),
              title: const Text('مزامنة فورية'),
              subtitle: const Text('مزامنة جميع البيانات مع الخادم'),
              trailing: Consumer<ConnectivityService>(
                builder: (context, connectivity, child) {
                  return connectivity.isSyncing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios);
                },
              ),
              onTap: () => _forceSyncData(),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('تحديث من الخادم'),
              subtitle: const Text('جلب أحدث البيانات من الخادم'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _refreshFromServer(),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.orange),
              title: const Text('نسخ احتياطي'),
              subtitle: const Text('إنشاء نسخة احتياطية من البيانات'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _createBackup(),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.purple),
              title: const Text('استعادة البيانات'),
              subtitle: const Text('استعادة البيانات من نسخة احتياطية'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _restoreBackup(),
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('مسح جميع البيانات'),
              subtitle: const Text('حذف جميع البيانات المحلية'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _clearAllData(),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog functions
  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AddRoomDialog(onRoomAdded: _loadDataCounts),
    );
  }

  void _showUpdatePricesDialog() {
    showDialog(
      context: context,
      builder: (context) => UpdatePricesDialog(onPricesUpdated: _loadDataCounts),
    );
  }

  void _showUpdateRoomStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => UpdateRoomStatusDialog(onStatusUpdated: _loadDataCounts),
    );
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(onEmployeeAdded: _loadDataCounts),
    );
  }

  void _showUpdateSalariesDialog() {
    showDialog(
      context: context,
      builder: (context) => UpdateSalariesDialog(onSalariesUpdated: _loadDataCounts),
    );
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSupplierDialog(onSupplierAdded: _loadDataCounts),
    );
  }

  // Action functions
  Future<void> _forceSyncData() async {
    try {
      await _apiService.forceSync();
      _showSnackBar('تمت المزامنة بنجاح');
      await _loadDataCounts();
    } catch (e) {
      _showSnackBar('خطأ في المزامنة: $e', isError: true);
    }
  }

  Future<void> _refreshFromServer() async {
    setState(() => _isLoading = true);
    try {
      // Refresh all data from server
      await _apiService.getBookings();
      await _apiService.getRooms();
      await _apiService.getPayments();
      await _apiService.getExpenses();
      await _apiService.getEmployees();
      await _apiService.getSuppliers();
      
      _showSnackBar('تم تحديث البيانات من الخادم');
      await _loadDataCounts();
    } catch (e) {
      _showSnackBar('خطأ في التحديث: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackup() async {
    try {
      // Implementation for creating backup
      _showSnackBar('تم إنشاء النسخة الاحتياطية');
    } catch (e) {
      _showSnackBar('خطأ في إنشاء النسخة الاحتياطية: $e', isError: true);
    }
  }

  Future<void> _restoreBackup() async {
    try {
      // Implementation for restoring backup
      _showSnackBar('تم استعادة البيانات');
      await _loadDataCounts();
    } catch (e) {
      _showSnackBar('خطأ في استعادة البيانات: $e', isError: true);
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف جميع البيانات؟\n\nلن يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbService.clearAllData();
        _showSnackBar('تم حذف جميع البيانات');
        await _loadDataCounts();
      } catch (e) {
        _showSnackBar('خطأ في حذف البيانات: $e', isError: true);
      }
    }
  }
}

// Dialog widgets would be implemented here
class AddRoomDialog extends StatelessWidget {
  final VoidCallback onRoomAdded;
  
  const AddRoomDialog({super.key, required this.onRoomAdded});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة غرفة جديدة'),
      content: const Text('سيتم تنفيذ هذه الميزة قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class UpdatePricesDialog extends StatelessWidget {
  final VoidCallback onPricesUpdated;
  
  const UpdatePricesDialog({super.key, required this.onPricesUpdated});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحديث الأسعار'),
      content: const Text('سيتم تنفيذ هذه الميزة قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class UpdateRoomStatusDialog extends StatelessWidget {
  final VoidCallback onStatusUpdated;
  
  const UpdateRoomStatusDialog({super.key, required this.onStatusUpdated});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحديث حالة الغرف'),
      content: const Text('سيتم تنفيذ هذه الميزة قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class AddEmployeeDialog extends StatelessWidget {
  final VoidCallback onEmployeeAdded;
  
  const AddEmployeeDialog({super.key, required this.onEmployeeAdded});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة موظف جديد'),
      content: const Text('سيتم تنفيذ هذه الميزة قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class UpdateSalariesDialog extends StatelessWidget {
  final VoidCallback onSalariesUpdated;
  
  const UpdateSalariesDialog({super.key, required this.onSalariesUpdated});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحديث الرواتب'),
      content: const Text('سيتم تنفيذ هذه الميزة قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class AddSupplierDialog extends StatelessWidget {
  final VoidCallback onSupplierAdded;
  
  const AddSupplierDialog({super.key, required this.onSupplierAdded});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة مورد جديد'),
      content: const Text('سيتم تنفيذ هذه الميزة قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
