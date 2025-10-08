import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/booking.dart';
import '../models/payment.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late ApiService _apiService;
  List<Payment> _payments = [];
  bool _isLoading = true;
  double _totalPaid = 0.0;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = ApiService(authService);
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final bookingId = widget.booking.id;
    if (bookingId == null) {
      setState(() {
        _isLoading = false;
        _payments = [];
        _totalPaid = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن تحميل المدفوعات لأن الحجز غير محفوظ بعد'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentsData = await _apiService.getPayments(bookingId: bookingId);
      final payments = paymentsData.map((data) => Payment.fromJson(data)).toList();
      
      setState(() {
        _payments = payments;
        _totalPaid = payments.fold(0.0, (sum, payment) => sum + payment.amount);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المدفوعات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مدفوعات ${widget.booking.guestName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPayments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Payment Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إجمالي المدفوع',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${_totalPaid.toStringAsFixed(2)} ريال',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'غرفة ${widget.booking.roomNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(widget.booking.checkInDate)} - ${DateFormat('dd/MM/yyyy').format(widget.booking.checkOutDate)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد مدفوعات',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'اضغط على + لإضافة دفعة جديدة',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPayments,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _payments.length,
                          itemBuilder: (context, index) {
                            final payment = _payments[index];
                            return _buildPaymentCard(payment);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPaymentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payment.amount.toStringAsFixed(2)} ريال',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPaymentMethodText(payment.paymentMethod),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRevenueTypeColor(payment.revenueType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRevenueTypeColor(payment.revenueType).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getRevenueTypeText(payment.revenueType),
                    style: TextStyle(
                      color: _getRevenueTypeColor(payment.revenueType),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(payment.paymentDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                if (payment.receiptNumber != null && payment.receiptNumber!.isNotEmpty) ...[
                  Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'إيصال: ${payment.receiptNumber}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            
            if (payment.description != null && payment.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                payment.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة';
      case 'transfer':
        return 'تحويل';
      default:
        return method;
    }
  }

  String _getRevenueTypeText(String type) {
    switch (type) {
      case 'room':
        return 'غرفة';
      case 'restaurant':
        return 'مطعم';
      case 'services':
        return 'خدمات';
      case 'other':
        return 'أخرى';
      default:
        return type;
    }
  }

  Color _getRevenueTypeColor(String type) {
    switch (type) {
      case 'room':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      case 'services':
        return Colors.green;
      case 'other':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAddPaymentDialog() {
    final bookingId = widget.booking.id;
    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب حفظ الحجز قبل إضافة مدفوعات'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final receiptController = TextEditingController();
    String paymentMethod = 'cash';
    String revenueType = 'room';
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة دفعة جديدة'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ *',
                      border: OutlineInputBorder(),
                      suffixText: 'ريال',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال المبلغ';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يرجى إدخال مبلغ صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    initialValue: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'طريقة الدفع',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('نقداً')),
                      DropdownMenuItem(value: 'card', child: Text('بطاقة')),
                      DropdownMenuItem(value: 'transfer', child: Text('تحويل')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    initialValue: revenueType,
                    decoration: const InputDecoration(
                      labelText: 'نوع الإيراد',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'room', child: Text('غرفة')),
                      DropdownMenuItem(value: 'restaurant', child: Text('مطعم')),
                      DropdownMenuItem(value: 'services', child: Text('خدمات')),
                      DropdownMenuItem(value: 'other', child: Text('أخرى')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        revenueType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          paymentDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الدفع',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(paymentDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: receiptController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الإيصال',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'وصف',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final payment = Payment(
                  bookingId: bookingId,
                  amount: double.parse(amountController.text),
                  paymentMethod: paymentMethod,
                  revenueType: revenueType,
                  paymentDate: paymentDate,
                  receiptNumber: receiptController.text.trim().isEmpty 
                      ? null 
                      : receiptController.text.trim(),
                  description: descriptionController.text.trim().isEmpty 
                      ? null 
                      : descriptionController.text.trim(),
                );

                final success = await _apiService.addPayment(payment.toJson());
                
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة الدفعة بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadPayments();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('خطأ في إضافة الدفعة'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
