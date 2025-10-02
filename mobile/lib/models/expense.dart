class Expense {
  final int? id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String? receipt;
  final String addedBy;
  final DateTime? createdAt;

  Expense({
    this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.receipt,
    required this.addedBy,
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      receipt: json['receipt'],
      addedBy: json['added_by'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
      'receipt': receipt,
      'added_by': addedBy,
    };
  }
}
