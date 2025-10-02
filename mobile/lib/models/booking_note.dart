class BookingNote {
  final int? id;
  final int bookingId;
  final String note;
  final String alertType;
  final DateTime? alertUntil;
  final String addedBy;
  final DateTime? createdAt;

  BookingNote({
    this.id,
    required this.bookingId,
    required this.note,
    required this.alertType,
    this.alertUntil,
    required this.addedBy,
    this.createdAt,
  });

  factory BookingNote.fromJson(Map<String, dynamic> json) {
    return BookingNote(
      id: json['id'],
      bookingId: json['booking_id'],
      note: json['note'] ?? '',
      alertType: json['alert_type'] ?? 'low',
      alertUntil: json['alert_until'] != null ? DateTime.parse(json['alert_until']) : null,
      addedBy: json['added_by'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'note': note,
      'alert_type': alertType,
      'alert_until': alertUntil?.toIso8601String(),
      'added_by': addedBy,
    };
  }

  bool get isHighPriority => alertType == 'high';
  bool get isMediumPriority => alertType == 'medium';
  bool get isLowPriority => alertType == 'low';
  
  bool get isAlertActive => alertUntil != null && DateTime.now().isBefore(alertUntil!);
}
