import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late ApiService _apiService;
  Map<String, dynamic> _reportsData = {};
  bool _isLoading = true;
  String _selectedPeriod = 'today';

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = ApiService(authService);
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await _apiService.getReports();
      setState(() {
        _reportsData = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل التقارير: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Period Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip('اليوم', 'today'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('هذا الأسبوع', 'week'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('هذا الشهر', 'month'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('هذا العام', 'year'),
                ],
              ),
            ),
          ),

          // Reports Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadReports,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Financial Summary
                          Text(
                            'الملخص المالي',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _buildFinancialCard(
                                'إجمالي الإيرادات',
                                _reportsData['total_revenue']?.toString() ?? '0',
                                'ريال',
                                Icons.trending_up,
                                Colors.green,
                              ),
                              _buildFinancialCard(
                                'إجمالي المصروفات',
                                _reportsData['total_expenses']?.toString() ?? '0',
                                'ريال',
                                Icons.trending_down,
                                Colors.red,
                              ),
                              _buildFinancialCard(
                                'صافي الربح',
                                _reportsData['net_profit']?.toString() ?? '0',
                                'ريال',
                                Icons.account_balance_wallet,
                                Colors.blue,
                              ),
                              _buildFinancialCard(
                                'المبالغ المعلقة',
                                _reportsData['pending_payments']?.toString() ?? '0',
                                'ريال',
                                Icons.schedule,
                                Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Bookings Summary
                          Text(
                            'ملخص الحجوزات',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _buildStatCard(
                                'إجمالي الحجوزات',
                                _reportsData['total_bookings']?.toString() ?? '0',
                                Icons.book,
                                Colors.blue,
                              ),
                              _buildStatCard(
                                'الحجوزات النشطة',
                                _reportsData['active_bookings']?.toString() ?? '0',
                                Icons.bed,
                                Colors.green,
                              ),
                              _buildStatCard(
                                'الحجوزات المكتملة',
                                _reportsData['completed_bookings']?.toString() ?? '0',
                                Icons.check_circle,
                                Colors.purple,
                              ),
                              _buildStatCard(
                                'الحجوزات الملغاة',
                                _reportsData['cancelled_bookings']?.toString() ?? '0',
                                Icons.cancel,
                                Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Room Occupancy
                          Text(
                            'إشغال الغرف',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'معدل الإشغال',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        '${_reportsData['occupancy_rate'] ?? 0}%',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: ((_reportsData['occupancy_rate'] ?? 0) / 100).toDouble(),
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildOccupancyItem(
                                        'غرف متاحة',
                                        _reportsData['available_rooms']?.toString() ?? '0',
                                        Colors.green,
                                      ),
                                      _buildOccupancyItem(
                                        'غرف محجوزة',
                                        _reportsData['occupied_rooms']?.toString() ?? '0',
                                        Colors.red,
                                      ),
                                      _buildOccupancyItem(
                                        'غرف صيانة',
                                        _reportsData['maintenance_rooms']?.toString() ?? '0',
                                        Colors.orange,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Top Performing Metrics
                          Text(
                            'أداء متميز',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildPerformanceItem(
                                    'أكثر الغرف حجزاً',
                                    _reportsData['top_room']?.toString() ?? 'غير متوفر',
                                    Icons.star,
                                  ),
                                  const Divider(),
                                  _buildPerformanceItem(
                                    'متوسط مدة الإقامة',
                                    '${_reportsData['avg_stay_duration'] ?? 0} أيام',
                                    Icons.schedule,
                                  ),
                                  const Divider(),
                                  _buildPerformanceItem(
                                    'متوسط الإيراد اليومي',
                                    '${_reportsData['avg_daily_revenue'] ?? 0} ريال',
                                    Icons.attach_money,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = value;
        });
        _loadReports();
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildFinancialCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              '$value $unit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
