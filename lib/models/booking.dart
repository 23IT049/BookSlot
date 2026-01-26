class Booking {
  final String id;
  final String userId;
  final String scheduleId;
  final DateTime bookingTime;
  final String status;
  final String? notes;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.bookingTime,
    this.status = 'confirmed',
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scheduleId': scheduleId,
      'bookingTime': bookingTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      scheduleId: json['scheduleId'],
      bookingTime: DateTime.parse(json['bookingTime']),
      status: json['status'] ?? 'confirmed',
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? scheduleId,
    DateTime? bookingTime,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scheduleId: scheduleId ?? this.scheduleId,
      bookingTime: bookingTime ?? this.bookingTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
