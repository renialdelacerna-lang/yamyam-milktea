import 'package:hive/hive.dart';

part 'inventory.g.dart';

/// Inventory stock model for tracking ingredient quantities
/// Manages stock levels for milk tea shop supplies
@HiveType(typeId: 3)
class InventoryItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String ingredientName;

  @HiveField(2)
  double stockQuantity;

  @HiveField(3)
  String unit; // kg, liters, pieces, etc.

  @HiveField(4)
  DateTime lastUpdated;

  @HiveField(5)
  double? minStockLevel; // Optional: minimum stock level for alerts

  InventoryItem({
    required this.id,
    required this.ingredientName,
    required this.stockQuantity,
    required this.unit,
    required this.lastUpdated,
    this.minStockLevel,
  });

  /// Check if stock is low (below minimum threshold)
  bool get isLowStock {
    if (minStockLevel == null) return false;
    return stockQuantity <= minStockLevel!;
  }

  /// Creates a copy of this inventory item with updated fields
  InventoryItem copyWith({
    String? id,
    String? ingredientName,
    double? stockQuantity,
    String? unit,
    DateTime? lastUpdated,
    double? minStockLevel,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      ingredientName: ingredientName ?? this.ingredientName,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      minStockLevel: minStockLevel ?? this.minStockLevel,
    );
  }

  @override
  String toString() {
    return 'InventoryItem(name: $ingredientName, quantity: $stockQuantity $unit)';
  }
}
