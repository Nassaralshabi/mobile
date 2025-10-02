class Employee {
  final int? id;
  final String name;
  final String position;
  final double basicSalary;
  final String status;
  final String? phone;
  final String? email;
  final DateTime? hireDate;
  final DateTime? createdAt;

  Employee({
    this.id,
    required this.name,
    required this.position,
    required this.basicSalary,
    required this.status,
    this.phone,
    this.email,
    this.hireDate,
    this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      basicSalary: double.parse(json['basic_salary'].toString()),
      status: json['status'] ?? 'active',
      phone: json['phone'],
      email: json['email'],
      hireDate: json['hire_date'] != null ? DateTime.parse(json['hire_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'basic_salary': basicSalary,
      'status': status,
      'phone': phone,
      'email': email,
      'hire_date': hireDate?.toIso8601String().split('T')[0],
    };
  }

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isTerminated => status == 'terminated';
}
