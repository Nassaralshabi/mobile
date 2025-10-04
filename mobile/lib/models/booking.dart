class Booking {
  final int? id;
  final String guestName;
  final String guestPhone;
  final String guestEmail;
  final String? guestId;
  final String? nationality;
  final String? address;
  final int roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String status;
  final String? notes;
  final int? calculatedNights;
  final double totalAmount;
  final double paidAmount;
  final double? discountAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id,
    required this.guestName,
    required this.guestPhone,
    required this.guestEmail,
    this.guestId,
    this.nationality,
    this.address,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    this.notes,
    this.calculatedNights,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.discountAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final total = double.tryParse(json['total_amount']?.toString() ?? '') ?? 0;
    final paid = double.tryParse(json['paid_amount']?.toString() ?? '') ?? 0;
    return Booking(
      id: json['id'],
      guestName: json['guest_name'] ?? '',
      guestPhone: json['guest_phone'] ?? '',
      guestEmail: json['guest_email'] ?? '',
      guestId: json['guest_id'],
      nationality: json['nationality'],
      address: json['address'],
      roomNumber: json['room_number'] ?? 0,
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: DateTime.parse(json['check_out_date']),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      calculatedNights: json['calculated_nights'],
      totalAmount: total,
      paidAmount: paid,
      discountAmount: json['discount_amount'] != null
          ? double.tryParse(json['discount_amount'].toString())
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'guest_email': guestEmail,
      'guest_id': guestId,
      'nationality': nationality,
      'address': address,
      'room_number': roomNumber,
      'check_in_date': checkInDate.toIso8601String().split('T')[0],
      'check_out_date': checkOutDate.toIso8601String().split('T')[0],
      'status': status,
      'notes': notes,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'discount_amount': discountAmount,
    };
  }

  int get numberOfNights => calculatedNights ?? checkOutDate.difference(checkInDate).inDays;

  double get remainingAmount {
    final remaining = totalAmount - paidAmount;
    return remaining < 0 ? 0 : remaining;
  }
  
  bool get isCheckedIn => status == 'checked_in';
  bool get isCheckedOut => status == 'checked_out';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
}
