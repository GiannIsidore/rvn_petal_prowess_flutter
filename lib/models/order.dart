class Order {
  final int? id;
  final String product;
  final String size;
  final int quantity;
  final String customerName;
  final String email;
  final String phone;
  final String deliveryMethod;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? deliveryDistanceKm;
  final double deliveryCharge;
  final double unitPrice;
  final double totalPrice;
  final String dateNeeded;
  final String? timeNeeded;
  final String flowerPreferences;
  final String notes;
  final String status;
  final String? rejectionReason;
  final String? approvedAt;
  final String? rejectedAt;
  final String? readyAt;
  final String? completedAt;
  final String? createdAt;

  Order({
    this.id,
    required this.product,
    required this.size,
    required this.quantity,
    required this.customerName,
    required this.email,
    required this.phone,
    required this.deliveryMethod,
    required this.address,
    this.latitude,
    this.longitude,
    this.deliveryDistanceKm,
    this.deliveryCharge = 0,
    required this.unitPrice,
    required this.totalPrice,
    required this.dateNeeded,
    this.timeNeeded,
    this.flowerPreferences = '-',
    this.notes = '',
    this.status = 'Pending',
    this.rejectionReason,
    this.approvedAt,
    this.rejectedAt,
    this.readyAt,
    this.completedAt,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.tryParse(json['id'].toString()),
      product: json['product'] ?? '',
      size: json['size'] ?? 'Small',
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      customerName: json['customer_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      deliveryMethod: json['delivery_method'] ?? 'Pickup',
      address: json['address'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()),
      longitude: double.tryParse(json['longitude'].toString()),
      deliveryDistanceKm: double.tryParse(
        json['delivery_distance_km'].toString(),
      ),
      deliveryCharge: double.tryParse(json['delivery_charge'].toString()) ?? 0,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      dateNeeded: json['date_needed'] ?? '',
      timeNeeded: json['time_needed'],
      flowerPreferences: json['flower_preferences'] ?? '-',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'Pending',
      rejectionReason: json['rejection_reason'],
      approvedAt: json['approved_at'],
      rejectedAt: json['rejected_at'],
      readyAt: json['ready_at'],
      completedAt: json['completed_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'size': size,
      'quantity': quantity,
      'customer_name': customerName,
      'email': email,
      'phone': phone,
      'delivery_method': deliveryMethod,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_distance_km': deliveryDistanceKm,
      'delivery_charge': deliveryCharge,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'date_needed': dateNeeded,
      'time_needed': timeNeeded,
      'flower_preferences': flowerPreferences,
      'notes': notes,
      'status': status,
      'rejection_reason': rejectionReason,
      'approved_at': approvedAt,
      'rejected_at': rejectedAt,
      'ready_at': readyAt,
      'completed_at': completedAt,
      'created_at': createdAt,
    };
  }

  Order copyWith({
    int? id,
    String? product,
    String? size,
    int? quantity,
    String? customerName,
    String? email,
    String? phone,
    String? deliveryMethod,
    String? address,
    double? latitude,
    double? longitude,
    double? deliveryDistanceKm,
    double? deliveryCharge,
    double? unitPrice,
    double? totalPrice,
    String? dateNeeded,
    String? timeNeeded,
    String? flowerPreferences,
    String? notes,
    String? status,
    String? rejectionReason,
    String? approvedAt,
    String? rejectedAt,
    String? readyAt,
    String? completedAt,
    String? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      product: product ?? this.product,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryDistanceKm: deliveryDistanceKm ?? this.deliveryDistanceKm,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      dateNeeded: dateNeeded ?? this.dateNeeded,
      timeNeeded: timeNeeded ?? this.timeNeeded,
      flowerPreferences: flowerPreferences ?? this.flowerPreferences,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      readyAt: readyAt ?? this.readyAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
