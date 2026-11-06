import 'package:hive/hive.dart';

part 'product.g.dart';

/// Product/Menu Item model representing items available in the milk tea shop
/// Stores product information with Hive for local persistence
@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category; // Milk Tea, Fruit Tea, Toppings

  @HiveField(3)
  double price;

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.createdAt,
  });

  /// Creates a copy of this product with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, price: $price)';
  }
}
