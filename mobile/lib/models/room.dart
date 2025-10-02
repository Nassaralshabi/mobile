class Room {
  final int id;
  final String roomNumber;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final String status;
  final String? description;
  final List<String>? amenities;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.status,
    this.description,
    this.amenities,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      roomNumber: json['room_number'] ?? '',
      roomType: json['room_type'] ?? '',
      pricePerNight: double.parse(json['price_per_night'].toString()),
      capacity: json['capacity'] ?? 1,
      status: json['status'] ?? 'available',
      description: json['description'],
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities'].split(','))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'room_type': roomType,
      'price_per_night': pricePerNight,
      'capacity': capacity,
      'status': status,
      'description': description,
      'amenities': amenities?.join(','),
    };
  }

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isMaintenance => status == 'maintenance';
  bool get isOutOfOrder => status == 'out_of_order';
}
