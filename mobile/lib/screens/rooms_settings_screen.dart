import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/offline_api_service.dart';

class RoomsSettingsScreen extends StatefulWidget {
  const RoomsSettingsScreen({super.key});

  @override
  State<RoomsSettingsScreen> createState() => _RoomsSettingsScreenState();
}

class _RoomsSettingsScreenState extends State<RoomsSettingsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final OfflineApiService _apiService = OfflineApiService();
  
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = false;
  
  // Room types and their default prices
  final Map<String, double> _roomTypeDefaults = {
    'سرير فردي': 15000.0,
    'سرير عائلي': 15000.0,
    'غرفة مزدوجة': 17000.0,
    'جناح': 20000.0,
  };

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _dbService.getRooms();
      setState(() => _rooms = rooms);
    } catch (e) {
      _showSnackBar('خطأ في تحميل الغرف: $e', isError: true);
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
        title: const Text('إعدادات الغرف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRoomDialog,
            tooltip: 'إضافة غرفة جديدة',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRooms,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildQuickActions(),
                Expanded(child: _buildRoomsList()),
              ],
            ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _showBulkPriceUpdateDialog,
                  icon: const Icon(Icons.attach_money, size: 18),
                  label: const Text('تحديث الأسعار'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showBulkStatusUpdateDialog,
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('تحديث الحالات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _generateRoomsReport,
                  icon: const Icon(Icons.assessment, size: 18),
                  label: const Text('تقرير الغرف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsList() {
    if (_rooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد غرف مضافة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'اضغط على + لإضافة غرفة جديدة',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return _buildRoomCard(room);
      },
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final isAvailable = room['status'] == 'شاغرة';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'غرفة ${room['room_number']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleRoomAction(value, room),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'status',
                      child: Row(
                        children: [
                          Icon(Icons.update, size: 18),
                          SizedBox(width: 8),
                          Text('تغيير الحالة'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'النوع: ${room['type']}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'السعر: ${room['price']} ريال',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAvailable ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    room['status'],
                    style: TextStyle(
                      color: isAvailable ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleRoomAction(String action, Map<String, dynamic> room) {
    switch (action) {
      case 'edit':
        _showEditRoomDialog(room);
        break;
      case 'status':
        _toggleRoomStatus(room);
        break;
      case 'delete':
        _deleteRoom(room);
        break;
    }
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => _RoomDialog(
        title: 'إضافة غرفة جديدة',
        roomTypeDefaults: _roomTypeDefaults,
        onSave: (roomData) async {
          try {
            await _dbService.insertRoom(roomData);
            _showSnackBar('تم إضافة الغرفة بنجاح');
            _loadRooms();
          } catch (e) {
            _showSnackBar('خطأ في إضافة الغرفة: $e', isError: true);
          }
        },
      ),
    );
  }

  void _showEditRoomDialog(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) => _RoomDialog(
        title: 'تعديل الغرفة',
        roomData: room,
        roomTypeDefaults: _roomTypeDefaults,
        onSave: (roomData) async {
          try {
            await _dbService.updateRoom(room['id'], roomData);
            _showSnackBar('تم تعديل الغرفة بنجاح');
            _loadRooms();
          } catch (e) {
            _showSnackBar('خطأ في تعديل الغرفة: $e', isError: true);
          }
        },
      ),
    );
  }

  Future<void> _toggleRoomStatus(Map<String, dynamic> room) async {
    final newStatus = room['status'] == 'شاغرة' ? 'محجوزة' : 'شاغرة';
    
    try {
      await _dbService.updateRoom(room['id'], {'status': newStatus});
      _showSnackBar('تم تحديث حالة الغرفة');
      _loadRooms();
    } catch (e) {
      _showSnackBar('خطأ في تحديث الحالة: $e', isError: true);
    }
  }

  Future<void> _deleteRoom(Map<String, dynamic> room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف غرفة ${room['room_number']}؟'),
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
        await _dbService.deleteRoom(room['id']);
        _showSnackBar('تم حذف الغرفة');
        _loadRooms();
      } catch (e) {
        _showSnackBar('خطأ في حذف الغرفة: $e', isError: true);
      }
    }
  }

  void _showBulkPriceUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => _BulkPriceUpdateDialog(
        rooms: _rooms,
        onUpdate: _loadRooms,
      ),
    );
  }

  void _showBulkStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => _BulkStatusUpdateDialog(
        rooms: _rooms,
        onUpdate: _loadRooms,
      ),
    );
  }

  void _generateRoomsReport() {
    // Implementation for generating rooms report
    _showSnackBar('سيتم تنفيذ تقرير الغرف قريباً');
  }
}

class _RoomDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? roomData;
  final Map<String, double> roomTypeDefaults;
  final Function(Map<String, dynamic>) onSave;

  const _RoomDialog({
    required this.title,
    this.roomData,
    required this.roomTypeDefaults,
    required this.onSave,
  });

  @override
  State<_RoomDialog> createState() => _RoomDialogState();
}

class _RoomDialogState extends State<_RoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedType = 'سرير فردي';
  String _selectedStatus = 'شاغرة';

  @override
  void initState() {
    super.initState();
    if (widget.roomData != null) {
      _roomNumberController.text = widget.roomData!['room_number'] ?? '';
      _priceController.text = widget.roomData!['price']?.toString() ?? '';
      _selectedType = widget.roomData!['type'] ?? 'سرير فردي';
      _selectedStatus = widget.roomData!['status'] ?? 'شاغرة';
    } else {
      _priceController.text = widget.roomTypeDefaults[_selectedType]?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _roomNumberController,
              decoration: const InputDecoration(
                labelText: 'رقم الغرفة',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الغرفة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع الغرفة',
                border: OutlineInputBorder(),
              ),
              items: widget.roomTypeDefaults.keys.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _priceController.text = widget.roomTypeDefaults[value]?.toString() ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'السعر (ريال)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال السعر';
                }
                if (double.tryParse(value) == null) {
                  return 'يرجى إدخال رقم صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'الحالة',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'شاغرة', child: Text('شاغرة')),
                DropdownMenuItem(value: 'محجوزة', child: Text('محجوزة')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final roomData = {
                'room_number': _roomNumberController.text,
                'type': _selectedType,
                'price': double.parse(_priceController.text),
                'status': _selectedStatus,
              };
              widget.onSave(roomData);
              Navigator.pop(context);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class _BulkPriceUpdateDialog extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final VoidCallback onUpdate;

  const _BulkPriceUpdateDialog({
    required this.rooms,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحديث الأسعار بالجملة'),
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

class _BulkStatusUpdateDialog extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final VoidCallback onUpdate;

  const _BulkStatusUpdateDialog({
    required this.rooms,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحديث الحالات بالجملة'),
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
