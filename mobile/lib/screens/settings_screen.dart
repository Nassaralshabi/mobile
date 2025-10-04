import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import 'sync_status_screen.dart';
import 'data_management_screen.dart';
import 'rooms_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _autoSync = true;
  int _syncInterval = 30;
  bool _syncOnWifiOnly = false;
  bool _enableNotifications = true;
  bool _enableOfflineMode = true;
  String _selectedLanguage = 'ar';
  String _selectedTheme = 'light';
  
  bool _isLoading = false;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _serverUrlController.text = prefs.getString('server_url') ?? 'http://localhost/marina-hotel/api';
        _apiKeyController.text = prefs.getString('api_key') ?? '';
        _usernameController.text = prefs.getString('username') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
        
        _autoSync = prefs.getBool('auto_sync') ?? true;
        _syncInterval = prefs.getInt('sync_interval') ?? 30;
        _syncOnWifiOnly = prefs.getBool('sync_wifi_only') ?? false;
        _enableNotifications = prefs.getBool('enable_notifications') ?? true;
        _enableOfflineMode = prefs.getBool('enable_offline_mode') ?? true;
        _selectedLanguage = prefs.getString('language') ?? 'ar';
        _selectedTheme = prefs.getString('theme') ?? 'light';
      });
    } catch (e) {
      _showSnackBar('خطأ في تحميل الإعدادات: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('server_url', _serverUrlController.text.trim());
      await prefs.setString('api_key', _apiKeyController.text.trim());
      await prefs.setString('username', _usernameController.text.trim());
      await prefs.setString('password', _passwordController.text.trim());
      
      await prefs.setBool('auto_sync', _autoSync);
      await prefs.setInt('sync_interval', _syncInterval);
      await prefs.setBool('sync_wifi_only', _syncOnWifiOnly);
      await prefs.setBool('enable_notifications', _enableNotifications);
      await prefs.setBool('enable_offline_mode', _enableOfflineMode);
      await prefs.setString('language', _selectedLanguage);
      await prefs.setString('theme', _selectedTheme);

      _showSnackBar('تم حفظ الإعدادات بنجاح');
      
      // إعادة تهيئة خدمة الاتصال مع الإعدادات الجديدة
      if (mounted) {
        final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
        await connectivityService.initialize();
      }
      
    } catch (e) {
      _showSnackBar('خطأ في حفظ الإعدادات: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    if (_serverUrlController.text.trim().isEmpty) {
      _showSnackBar('يرجى إدخال رابط الخادم أولاً', isError: true);
      return;
    }

    setState(() {
      _isTestingConnection = true;
    });

    try {
      // محاولة الاتصال بالخادم
      final url = _serverUrlController.text.trim();
      final testUrl = url.endsWith('/') ? '${url}test.php' : '$url/test.php';
      
      // هنا يمكن إضافة منطق اختبار الاتصال الفعلي
      await Future.delayed(const Duration(seconds: 2)); // محاكاة الاختبار
      
      _showSnackBar('✅ تم الاتصال بالخادم بنجاح!');
      
    } catch (e) {
      _showSnackBar('❌ فشل في الاتصال بالخادم: $e', isError: true);
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await _showConfirmDialog(
      'إعادة تعيين الإعدادات',
      'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟',
    );

    if (confirmed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _loadSettings();
      _showSnackBar('تم إعادة تعيين الإعدادات');
    }
  }

  Future<void> _clearLocalData() async {
    final confirmed = await _showConfirmDialog(
      'مسح البيانات المحلية',
      'هل أنت متأكد من مسح جميع البيانات المحلية؟\n\nسيتم حذف جميع البيانات غير المتزامنة نهائياً.',
    );

    if (confirmed) {
      try {
        final dbService = DatabaseService();
        await dbService.clearAllData();
        _showSnackBar('تم مسح البيانات المحلية بنجاح');
      } catch (e) {
        _showSnackBar('خطأ في مسح البيانات: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SyncStatusScreen(),
                ),
              );
            },
            tooltip: 'حالة المزامنة',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveSettings,
            tooltip: 'حفظ الإعدادات',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildServerSection(),
                  const SizedBox(height: 20),
                  _buildSyncSection(),
                  const SizedBox(height: 20),
                  _buildAppSection(),
                  const SizedBox(height: 20),
                  _buildDataManagementSection(),
                  const SizedBox(height: 20),
                  _buildDataSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildServerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'إعدادات الخادم',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'رابط الخادم *',
                hintText: 'http://your-server.com/marina-hotel/api',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
                helperText: 'رابط API الخاص بالخادم',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رابط الخادم';
                }
                if (!Uri.tryParse(value.trim())?.hasAbsolutePath == true) {
                  return 'يرجى إدخال رابط صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTestingConnection ? null : _testConnection,
                    icon: _isTestingConnection 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_find),
                    label: Text(_isTestingConnection ? 'جاري الاختبار...' : 'اختبار الاتصال'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'مفتاح API (اختياري)',
                hintText: 'أدخل مفتاح API إذا كان مطلوباً',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم (اختياري)',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور (اختياري)',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'إعدادات المزامنة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('المزامنة التلقائية'),
              subtitle: const Text('تفعيل المزامنة التلقائية مع الخادم'),
              value: _autoSync,
              onChanged: (value) {
                setState(() {
                  _autoSync = value;
                });
              },
            ),
            
            if (_autoSync) ...[
              const Divider(),
              ListTile(
                title: const Text('فترة المزامنة'),
                subtitle: Text('كل $_syncInterval ثانية'),
                trailing: SizedBox(
                  width: 100,
                  child: DropdownButton<int>(
                    value: _syncInterval,
                    items: [15, 30, 60, 120, 300].map((seconds) {
                      return DropdownMenuItem(
                        value: seconds,
                        child: Text('$seconds ث'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _syncInterval = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
            
            const Divider(),
            SwitchListTile(
              title: const Text('المزامنة عبر WiFi فقط'),
              subtitle: const Text('تجنب استخدام بيانات الهاتف'),
              value: _syncOnWifiOnly,
              onChanged: (value) {
                setState(() {
                  _syncOnWifiOnly = value;
                });
              },
            ),
            
            const Divider(),
            SwitchListTile(
              title: const Text('الوضع غير المتصل'),
              subtitle: const Text('السماح بالعمل بدون إنترنت'),
              value: _enableOfflineMode,
              onChanged: (value) {
                setState(() {
                  _enableOfflineMode = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'إعدادات التطبيق',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('الإشعارات'),
              subtitle: const Text('تفعيل إشعارات التطبيق'),
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                });
              },
            ),
            
            const Divider(),
            ListTile(
              title: const Text('اللغة'),
              subtitle: Text(_selectedLanguage == 'ar' ? 'العربية' : 'English'),
              trailing: SizedBox(
                width: 120,
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
              ),
            ),
            
            const Divider(),
            ListTile(
              title: const Text('المظهر'),
              subtitle: Text(_selectedTheme == 'light' ? 'فاتح' : 'داكن'),
              trailing: SizedBox(
                width: 100,
                child: DropdownButton<String>(
                  value: _selectedTheme,
                  items: const [
                    DropdownMenuItem(value: 'light', child: Text('فاتح')),
                    DropdownMenuItem(value: 'dark', child: Text('داكن')),
                    DropdownMenuItem(value: 'auto', child: Text('تلقائي')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTheme = value!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_applications, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'إعدادات البيانات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),
              title: const Text('إدارة البيانات الشاملة'),
              subtitle: const Text('عرض وإدارة جميع بيانات الفندق'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataManagementScreen(),
                  ),
                );
              },
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.hotel, color: Colors.green),
              title: const Text('إعدادات الغرف'),
              subtitle: const Text('إدارة الغرف والأسعار والحالات'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoomsSettingsScreen(),
                  ),
                );
              },
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.purple),
              title: const Text('إدارة الموظفين'),
              subtitle: const Text('إضافة وتعديل بيانات الموظفين'),
              onTap: () {
                _showSnackBar('سيتم تنفيذ هذه الميزة قريباً');
              },
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.business, color: Colors.teal),
              title: const Text('إدارة الموردين'),
              subtitle: const Text('إضافة وتعديل بيانات الموردين'),
              onTap: () {
                _showSnackBar('سيتم تنفيذ هذه الميزة قريباً');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'النسخ الاحتياطي والاستعادة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.cloud_sync, color: Colors.blue),
              title: const Text('حالة المزامنة'),
              subtitle: const Text('عرض تفاصيل المزامنة والطابور'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SyncStatusScreen(),
                  ),
                );
              },
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.orange),
              title: const Text('مسح البيانات المحلية'),
              subtitle: const Text('حذف جميع البيانات المحفوظة محلياً'),
              onTap: _clearLocalData,
            ),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.green),
              title: const Text('نسخ احتياطي'),
              subtitle: const Text('إنشاء نسخة احتياطية من البيانات'),
              onTap: () {
                _showSnackBar('ميزة النسخ الاحتياطي قيد التطوير');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('حفظ الإعدادات'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _resetSettings,
            icon: const Icon(Icons.restore),
            label: const Text('إعادة تعيين الإعدادات'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              foregroundColor: Colors.orange,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        Consumer<ConnectivityService>(
          builder: (context, connectivityService, child) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: connectivityService.isOnline 
                    ? Colors.green[50] 
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: connectivityService.isOnline 
                      ? Colors.green[200]! 
                      : Colors.red[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    connectivityService.isOnline 
                        ? Icons.cloud_done 
                        : Icons.cloud_off,
                    color: connectivityService.isOnline 
                        ? Colors.green 
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      connectivityService.syncStatus,
                      style: TextStyle(
                        color: connectivityService.isOnline 
                            ? Colors.green[700] 
                            : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _apiKeyController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
