import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/offline_api_service.dart';
import '../services/database_service.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  final OfflineApiService _offlineApiService = OfflineApiService();
  final DatabaseService _dbService = DatabaseService();
  Map<String, dynamic>? _syncStatus;
  List<Map<String, dynamic>> _syncQueue = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _offlineApiService.getSyncStatus();
      final queue = await _dbService.getSyncQueue();
      
      setState(() {
        _syncStatus = status;
        _syncQueue = queue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل حالة المزامنة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة المزامنة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSyncStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSyncStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConnectionStatus(),
                    const SizedBox(height: 20),
                    _buildSyncActions(),
                    const SizedBox(height: 20),
                    _buildSyncStatistics(),
                    const SizedBox(height: 20),
                    _buildSyncQueue(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildConnectionStatus() {
    final isOnline = _syncStatus?['is_online'] ?? false;
    final isSyncing = _syncStatus?['is_syncing'] ?? false;
    final syncStatus = _syncStatus?['sync_status'] ?? 'غير معروف';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline ? 'متصل بالإنترنت' : 'غير متصل',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        syncStatus,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            
            if (_syncStatus?['last_sync_time'] != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'آخر مزامنة: ${DateFormat('dd/MM/yyyy - HH:mm').format(_syncStatus!['last_sync_time'])}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncActions() {
    final isOnline = _syncStatus?['is_online'] ?? false;
    final isSyncing = _syncStatus?['is_syncing'] ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات المزامنة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSyncing ? null : () => _forceSync(),
                    icon: Icon(isSyncing ? Icons.sync : Icons.sync_alt),
                    label: Text(isSyncing ? 'جاري المزامنة...' : 'مزامنة يدوية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOnline ? null : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showClearDataDialog(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('مسح البيانات'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (!isOnline)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'أنت تعمل في الوضع غير المتصل. ستتم مزامنة البيانات عند توفر الإنترنت.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatistics() {
    final pendingCount = _syncStatus?['pending_sync_count'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات المزامنة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'في انتظار المزامنة',
                    pendingCount.toString(),
                    Icons.pending_actions,
                    pendingCount > 0 ? Colors.orange : Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'في الطابور',
                    _syncQueue.length.toString(),
                    Icons.queue,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncQueue() {
    if (_syncQueue.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green[400],
              ),
              const SizedBox(height: 12),
              Text(
                'جميع البيانات متزامنة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'لا توجد عناصر في انتظار المزامنة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طابور المزامنة (${_syncQueue.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _syncQueue.length > 10 ? 10 : _syncQueue.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _syncQueue[index];
                return _buildQueueItem(item);
              },
            ),
            
            if (_syncQueue.length > 10) ...[
              const Divider(),
              Center(
                child: Text(
                  'و ${_syncQueue.length - 10} عنصر آخر...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> item) {
    final tableName = item['table_name'];
    final action = item['action'];
    final createdAt = DateTime.tryParse(item['created_at'] ?? '');
    final retryCount = item['retry_count'] ?? 0;
    final hasError = item['last_error'] != null;

    String tableDisplayName = _getTableDisplayName(tableName);
    String actionDisplayName = _getActionDisplayName(action);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: hasError ? Colors.red : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$actionDisplayName في $tableDisplayName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (createdAt != null)
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                if (hasError)
                  Text(
                    'خطأ: ${item['last_error']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          
          if (retryCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'إعادة: $retryCount',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTableDisplayName(String tableName) {
    switch (tableName) {
      case 'bookings':
        return 'الحجوزات';
      case 'payments':
        return 'المدفوعات';
      case 'expenses':
        return 'المصروفات';
      case 'salary_withdrawals':
        return 'سحوبات الرواتب';
      case 'rooms':
        return 'الغرف';
      default:
        return tableName;
    }
  }

  String _getActionDisplayName(String action) {
    switch (action) {
      case 'create':
        return 'إضافة';
      case 'update':
        return 'تحديث';
      case 'delete':
        return 'حذف';
      default:
        return action;
    }
  }

  Future<void> _forceSync() async {
    try {
      await _offlineApiService.forceSync();
      await _loadSyncStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت المزامنة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المزامنة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح البيانات'),
        content: const Text(
          'هل أنت متأكد من مسح جميع البيانات المحلية؟\n\nسيتم حذف جميع البيانات غير المتزامنة نهائياً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      await _dbService.clearAllData();
      await _loadSyncStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم مسح جميع البيانات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في مسح البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
