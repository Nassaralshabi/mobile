class Payment {
  final int? id;
  final int bookingId;
  final double amount;
  final String paymentMethod;
  final String revenueType;
  final String? receiptNumber;
  final String? description;
  final String? notes;
  final DateTime paymentDate;
  final DateTime? createdAt;

  Payment({
    this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    this.revenueType = 'room',
    this.receiptNumber,
    this.description,
    this.notes,
    required this.paymentDate,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: double.parse(json['amount'].toString()),
      paymentMethod: json['payment_method'] ?? 'نقداً',
      revenueType: json['revenue_type'] ?? 'room',
      receiptNumber: json['receipt_number'],
      description: json['description'],
      notes: json['notes'],
      paymentDate: DateTime.parse(json['payment_date']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'payment_method': paymentMethod,
      'revenue_type': revenueType,
      'receipt_number': receiptNumber,
      'description': description,
      'notes': notes,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
    };
  }

  bool get isCash => paymentMethod == 'نقداً' || paymentMethod == 'cash';
  bool get isCard => paymentMethod == 'بطاقة' || paymentMethod == 'card';
  bool get isTransfer => paymentMethod == 'تحويل' || paymentMethod == 'transfer';
}
