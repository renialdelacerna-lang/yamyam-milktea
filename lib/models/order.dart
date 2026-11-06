import 'package:hive/hive.dart';

part 'order.g.dart';

/// Order item representing a single product in an order with quantity
@HiveType(typeId: 1)
class OrderItem extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  double productPrice;

  @HiveField(3)
  int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
  });

  /// Calculate total price for this order item
  double get totalPrice => productPrice * quantity;

  @override
  String toString() {
    return 'OrderItem(productName: $productName, quantity: $quantity, totalPrice: $totalPrice)';
  }
}

/// Order record storing customer order information
/// Manages complete order lifecycle from placement to completion
@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerName;

  @HiveField(2)
  List<OrderItem> items;

  @HiveField(3)
  double totalAmount;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String status; // Pending, Preparing, Completed, Cancelled

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    required this.status,
  });

  /// Calculate total amount from all order items
  static double calculateTotal(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Creates a copy of this order with updated fields
  Order copyWith({
    String? id,
    String? customerName,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? timestamp,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, customer: $customerName, total: $totalAmount, status: $status)';
  }
}
