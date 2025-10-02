import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import 'payment_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز ${booking.guestName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit booking screen
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'receipt':
                  _showReceipt(context);
                  break;
                case 'payment':
                  _navigateToPayments(context);
                  break;
                case 'checkout':
                  _showCheckoutDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'receipt',
                child: Row(
                  children: [
                    Icon(Icons.receipt),
                    SizedBox(width: 8),
                    Text('إيصال'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'payment',
                child: Row(
                  children: [
                    Icon(Icons.payment),
                    SizedBox(width: 8),
                    Text('المدفوعات'),
                  ],
                ),
              ),
              if (booking.isPending || booking.isCheckedIn)
                const PopupMenuItem(
                  value: 'checkout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('تسجيل خروج'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(booking.status),
                      color: _getStatusColor(booking.status),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(booking.status),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _getStatusColor(booking.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'حجز رقم ${booking.id}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Guest Information
            _buildSection(
              context,
              'بيانات النزيل',
              Icons.person,
              [
                _buildInfoRow('الاسم', booking.guestName),
                _buildInfoRow('الهاتف', booking.guestPhone),
                if (booking.guestEmail.isNotEmpty)
                  _buildInfoRow('البريد الإلكتروني', booking.guestEmail),
              ],
            ),
            const SizedBox(height: 16),

            // Booking Information
            _buildSection(
              context,
              'بيانات الحجز',
              Icons.hotel,
              [
                _buildInfoRow('رقم الغرفة', booking.roomNumber.toString()),
                _buildInfoRow('تاريخ الوصول', DateFormat('dd/MM/yyyy').format(booking.checkInDate)),
                _buildInfoRow('تاريخ المغادرة', DateFormat('dd/MM/yyyy').format(booking.checkOutDate)),
                _buildInfoRow('عدد الليالي', booking.numberOfNights.toString()),
                if (booking.notes != null && booking.notes!.isNotEmpty)
                  _buildInfoRow('ملاحظات', booking.notes!),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline
            if (booking.createdAt != null)
              _buildSection(
                context,
                'التوقيت',
                Icons.schedule,
                [
                  _buildInfoRow('تاريخ الحجز', DateFormat('dd/MM/yyyy - HH:mm').format(booking.createdAt!)),
                ],
              ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToPayments(context),
                icon: const Icon(Icons.payment),
                label: const Text('عرض المدفوعات'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (booking.isPending)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCheckinDialog(context),
                  icon: const Icon(Icons.login),
                  label: const Text('تسجيل وصول'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

            if (booking.isCheckedIn)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCheckoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل مغادرة'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'checked_in':
        return Colors.green;
      case 'checked_out':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'checked_in':
        return Icons.login;
      case 'checked_out':
        return Icons.logout;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'checked_in':
        return 'تم الوصول';
      case 'checked_out':
        return 'تم المغادرة';
      default:
        return status;
    }
  }

  void _navigateToPayments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(booking: booking),
      ),
    );
  }

  void _showCheckinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل وصول'),
        content: Text('هل تريد تسجيل وصول ${booking.guestName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Update booking status to checked_in
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل مغادرة'),
        content: Text('هل تريد تسجيل مغادرة ${booking.guestName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Update booking status to checked_out
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showReceipt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إيصال الحجز'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'فندق مارينا',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('رقم الحجز: ${booking.id}'),
              Text('النزيل: ${booking.guestName}'),
              Text('الغرفة: ${booking.roomNumber}'),
              Text('الوصول: ${DateFormat('dd/MM/yyyy').format(booking.checkInDate)}'),
              Text('المغادرة: ${DateFormat('dd/MM/yyyy').format(booking.checkOutDate)}'),
              const Divider(),
              Text('رقم الحجز: ${booking.id}'),
              Text('النزيل: ${booking.guestName}'),
              Text('الغرفة: ${booking.roomNumber}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Print or share receipt
              Navigator.pop(context);
            },
            child: const Text('طباعة'),
          ),
        ],
      ),
    );
  }
}
