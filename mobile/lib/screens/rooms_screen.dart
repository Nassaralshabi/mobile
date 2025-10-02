import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/room.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  late ApiService _apiService;
  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = ApiService(authService);
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final roomsData = await _apiService.getRooms();
      final rooms = roomsData.map((data) => Room.fromJson(data)).toList();
      
      setState(() {
        _rooms = rooms;
        _filteredRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الغرف: $e')),
        );
      }
    }
  }

  void _filterRooms() {
    setState(() {
      _filteredRooms = _rooms.where((room) {
        final matchesSearch = room.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            room.roomType.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesStatus = _statusFilter == 'all' || room.status == _statusFilter;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'البحث في الغرف...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterRooms();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('الكل', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('متاحة', 'available'),
                      const SizedBox(width: 8),
                      _buildFilterChip('محجوزة', 'occupied'),
                      const SizedBox(width: 8),
                      _buildFilterChip('صيانة', 'maintenance'),
                      const SizedBox(width: 8),
                      _buildFilterChip('خارج الخدمة', 'out_of_order'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rooms Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRooms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hotel_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد غرف',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRooms,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredRooms.length,
                          itemBuilder: (context, index) {
                            final room = _filteredRooms[index];
                            return _buildRoomCard(room);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
        });
        _filterRooms();
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      child: InkWell(
        onTap: () => _showRoomDetails(room),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Number and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'غرفة ${room.roomNumber}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusIndicator(room.status),
                ],
              ),
              const SizedBox(height: 8),

              // Room Type
              Text(
                room.roomType,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),

              // Capacity
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${room.capacity} أشخاص',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Price
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${room.pricePerNight.toStringAsFixed(0)} ريال/ليلة',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: room.isAvailable ? () => _bookRoom(room) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: room.isAvailable 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    room.isAvailable ? 'حجز' : _getStatusText(room.status),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'available':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'occupied':
        color = Colors.red;
        icon = Icons.person;
        break;
      case 'maintenance':
        color = Colors.orange;
        icon = Icons.build;
        break;
      case 'out_of_order':
        color = Colors.grey;
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'متاحة';
      case 'occupied':
        return 'محجوزة';
      case 'maintenance':
        return 'صيانة';
      case 'out_of_order':
        return 'خارج الخدمة';
      default:
        return status;
    }
  }

  void _showRoomDetails(Room room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Room Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'غرفة ${room.roomNumber}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            room.roomType,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusIndicator(room.status),
                  ],
                ),
                const SizedBox(height: 24),

                // Room Details
                _buildDetailRow('السعة', '${room.capacity} أشخاص'),
                _buildDetailRow('السعر', '${room.pricePerNight.toStringAsFixed(0)} ريال/ليلة'),
                _buildDetailRow('الحالة', _getStatusText(room.status)),
                
                if (room.description != null && room.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'الوصف',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(room.description!),
                ],

                if (room.amenities != null && room.amenities!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'المرافق',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: room.amenities!.map((amenity) => Chip(
                      label: Text(amenity),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    )).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                if (room.isAvailable)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _bookRoom(room);
                      },
                      child: const Text('حجز هذه الغرفة'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _bookRoom(Room room) {
    // TODO: Navigate to booking screen with pre-filled room number
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم فتح صفحة الحجز للغرفة ${room.roomNumber}'),
      ),
    );
  }
}
