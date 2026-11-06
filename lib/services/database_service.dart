import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/inventory.dart';

/// Central database service managing all Hive boxes and CRUD operations
/// Provides a clean interface for data persistence across the application
class DatabaseService {
  // Box names as constants to avoid typos
  static const String _productBoxName = 'products';
  static const String _orderBoxName = 'orders';
  static const String _inventoryBoxName = 'inventory';

  // Lazy-loaded box instances
  Box<Product>? _productBox;
  Box<Order>? _orderBox;
  Box<InventoryItem>? _inventoryBox;

  /// Initialize Hive and open all boxes
  /// Must be called before using any database operations
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters for custom types
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(OrderItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OrderAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(InventoryItemAdapter());
    }

    // Open boxes
    _productBox = await Hive.openBox<Product>(_productBoxName);
    _orderBox = await Hive.openBox<Order>(_orderBoxName);
    _inventoryBox = await Hive.openBox<InventoryItem>(_inventoryBoxName);
  }

  // ==================== PRODUCT OPERATIONS ====================

  /// Get the product box, ensuring it's initialized
  Box<Product> get _products {
    if (_productBox == null || !_productBox!.isOpen) {
      throw Exception('Product box not initialized. Call initialize() first.');
    }
    return _productBox!;
  }

  /// Add a new product to the database
  Future<void> addProduct(Product product) async {
    await _products.put(product.id, product);
  }

  /// Get all products from the database
  List<Product> getAllProducts() {
    return _products.values.toList();
  }

  /// Get a single product by ID
  Product? getProduct(String id) {
    return _products.get(id);
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    await _products.put(product.id, product);
  }

  /// Delete a product by ID
  Future<void> deleteProduct(String id) async {
    await _products.delete(id);
  }

  /// Get products filtered by category
  List<Product> getProductsByCategory(String category) {
    return _products.values
        .where((product) => product.category == category)
        .toList();
  }

  // ==================== ORDER OPERATIONS ====================

  /// Get the order box, ensuring it's initialized
  Box<Order> get _orders {
    if (_orderBox == null || !_orderBox!.isOpen) {
      throw Exception('Order box not initialized. Call initialize() first.');
    }
    return _orderBox!;
  }

  /// Add a new order to the database
  Future<void> addOrder(Order order) async {
    await _orders.put(order.id, order);
  }

  /// Get all orders from the database
  List<Order> getAllOrders() {
    return _orders.values.toList();
  }

  /// Get a single order by ID
  Order? getOrder(String id) {
    return _orders.get(id);
  }

  /// Update an existing order
  Future<void> updateOrder(Order order) async {
    await _orders.put(order.id, order);
  }

  /// Delete an order by ID
  Future<void> deleteOrder(String id) async {
    await _orders.delete(id);
  }

  /// Get orders sorted by date (newest first)
  List<Order> getOrdersSortedByDate() {
    final orders = _orders.values.toList();
    orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return orders;
  }

  /// Get orders filtered by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.values
        .where((order) => order.status == status)
        .toList();
  }

  // ==================== INVENTORY OPERATIONS ====================

  /// Get the inventory box, ensuring it's initialized
  Box<InventoryItem> get _inventory {
    if (_inventoryBox == null || !_inventoryBox!.isOpen) {
      throw Exception('Inventory box not initialized. Call initialize() first.');
    }
    return _inventoryBox!;
  }

  /// Add a new inventory item to the database
  Future<void> addInventoryItem(InventoryItem item) async {
    await _inventory.put(item.id, item);
  }

  /// Get all inventory items from the database
  List<InventoryItem> getAllInventoryItems() {
    return _inventory.values.toList();
  }

  /// Get a single inventory item by ID
  InventoryItem? getInventoryItem(String id) {
    return _inventory.get(id);
  }

  /// Update an existing inventory item
  Future<void> updateInventoryItem(InventoryItem item) async {
    await _inventory.put(item.id, item);
  }

  /// Delete an inventory item by ID
  Future<void> deleteInventoryItem(String id) async {
    await _inventory.delete(id);
  }

  /// Get low stock items (items below minimum threshold)
  List<InventoryItem> getLowStockItems() {
    return _inventory.values
        .where((item) => item.isLowStock)
        .toList();
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Clear all data from the database (use with caution)
  Future<void> clearAllData() async {
    await _products.clear();
    await _orders.clear();
    await _inventory.clear();
  }

  /// Close all boxes (call when app is terminated)
  Future<void> close() async {
    await _productBox?.close();
    await _orderBox?.close();
    await _inventoryBox?.close();
  }

  /// Get database statistics
  Map<String, int> getStats() {
    return {
      'products': _products.length,
      'orders': _orders.length,
      'inventory': _inventory.length,
    };
  }
}
