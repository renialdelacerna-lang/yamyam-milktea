# Yamyam Milk Tea - Technical Documentation

## Table of Contents
1. [System Overview](#system-overview)
2. [Technical Architecture](#technical-architecture)
3. [Database Schema](#database-schema)
4. [API Reference](#api-reference)
5. [User Guide](#user-guide)
6. [Development Guide](#development-guide)

---

## System Overview

### Purpose
The Yamyam Milk Tea application is a comprehensive inventory management system designed for milk tea shops to manage their products, orders, and stock levels efficiently.

### Key Benefits
- **Efficiency**: Quick access to all business operations
- **Accuracy**: Validated data entry prevents errors
- **Persistence**: All data saved locally and survives app restarts
- **Usability**: Intuitive interface requires minimal training

### Target Users
- Milk tea shop owners
- Store managers
- Counter staff
- Inventory managers

---

## Technical Architecture

### Technology Stack
```
┌─────────────────────────────────────┐
│         Flutter Framework           │
│         (UI & Business Logic)       │
├─────────────────────────────────────┤
│         Hive Database               │
│      (Local Data Storage)           │
├─────────────────────────────────────┤
│      Operating System               │
│    (Android / iOS / Windows)        │
└─────────────────────────────────────┘
```

### Layer Architecture
```
Presentation Layer (UI)
    ↓
    Screens (home_screen, menu_screen, order_screen, inventory_screen)
    ↓
Business Logic Layer
    ↓
    Services (database_service)
    ↓
Data Layer
    ↓
    Models (product, order, inventory)
    ↓
Persistence Layer
    ↓
    Hive Database (Local Storage)
```

### Design Patterns Used

1. **Repository Pattern**: `DatabaseService` acts as a repository
2. **Singleton Pattern**: Single instance of `DatabaseService`
3. **Factory Pattern**: Model constructors and `copyWith` methods
4. **Widget Composition**: Reusable UI components

---

## Database Schema

### Hive Type IDs
- **0**: Product
- **1**: OrderItem
- **2**: Order
- **3**: InventoryItem

### Product Model
```dart
@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0) String id;              // Unique identifier
  @HiveField(1) String name;            // Product name
  @HiveField(2) String category;        // Milk Tea, Fruit Tea, Toppings
  @HiveField(3) double price;           // Price in PHP
  @HiveField(4) String description;     // Product description
  @HiveField(5) DateTime createdAt;     // Creation timestamp
}
```

**Constraints**:
- `id`: Auto-generated using timestamp
- `name`: Required, non-empty
- `category`: Must be one of predefined categories
- `price`: Must be positive, max 2 decimal places
- `description`: Required, non-empty

### OrderItem Model
```dart
@HiveType(typeId: 1)
class OrderItem extends HiveObject {
  @HiveField(0) String productId;       // Reference to Product
  @HiveField(1) String productName;     // Snapshot of product name
  @HiveField(2) double productPrice;    // Snapshot of product price
  @HiveField(3) int quantity;           // Number of items
}
```

**Computed Fields**:
- `totalPrice`: Calculated as `productPrice * quantity`

### Order Model
```dart
@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0) String id;              // Unique identifier
  @HiveField(1) String customerName;    // Customer's name
  @HiveField(2) List<OrderItem> items;  // List of order items
  @HiveField(3) double totalAmount;     // Total order amount
  @HiveField(4) DateTime timestamp;     // Order creation time
  @HiveField(5) String status;          // Order status
}
```

**Status Values**:
- `Pending`: Order received, not started
- `Preparing`: Order being prepared
- `Completed`: Order fulfilled
- `Cancelled`: Order cancelled

### InventoryItem Model
```dart
@HiveType(typeId: 3)
class InventoryItem extends HiveObject {
  @HiveField(0) String id;              // Unique identifier
  @HiveField(1) String ingredientName;  // Ingredient name
  @HiveField(2) double stockQuantity;   // Current stock level
  @HiveField(3) String unit;            // Measurement unit
  @HiveField(4) DateTime lastUpdated;   // Last update timestamp
  @HiveField(5) double? minStockLevel;  // Low stock threshold (optional)
}
```

**Computed Fields**:
- `isLowStock`: Returns `true` if `stockQuantity <= minStockLevel`

**Supported Units**:
- kg (kilograms)
- liters
- pieces
- grams
- ml (milliliters)
- cups
- bags

---

## API Reference

### DatabaseService

#### Initialization
```dart
Future<void> initialize()
```
Initializes Hive and opens all database boxes. Must be called before any other operations.

**Usage**:
```dart
final databaseService = DatabaseService();
await databaseService.initialize();
```

---

### Product Operations

#### Add Product
```dart
Future<void> addProduct(Product product)
```
Adds a new product to the database.

**Parameters**:
- `product`: Product object to add

**Example**:
```dart
final product = Product(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'Matcha Milk Tea',
  category: 'Milk Tea',
  price: 75.00,
  description: 'Premium Japanese matcha with fresh milk',
  createdAt: DateTime.now(),
);
await databaseService.addProduct(product);
```

#### Get All Products
```dart
List<Product> getAllProducts()
```
Returns all products from the database.

#### Get Product by ID
```dart
Product? getProduct(String id)
```
Returns a single product or `null` if not found.

#### Update Product
```dart
Future<void> updateProduct(Product product)
```
Updates an existing product.

#### Delete Product
```dart
Future<void> deleteProduct(String id)
```
Deletes a product by ID.

#### Get Products by Category
```dart
List<Product> getProductsByCategory(String category)
```
Returns products filtered by category.

---

### Order Operations

#### Add Order
```dart
Future<void> addOrder(Order order)
```
Creates a new order.

**Example**:
```dart
final order = Order(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  customerName: 'Juan dela Cruz',
  items: [
    OrderItem(
      productId: 'product_id_123',
      productName: 'Classic Milk Tea',
      productPrice: 65.00,
      quantity: 2,
    ),
  ],
  totalAmount: 130.00,
  timestamp: DateTime.now(),
  status: 'Pending',
);
await databaseService.addOrder(order);
```

#### Get All Orders
```dart
List<Order> getAllOrders()
```
Returns all orders.

#### Get Orders Sorted by Date
```dart
List<Order> getOrdersSortedByDate()
```
Returns orders sorted by timestamp (newest first).

#### Get Orders by Status
```dart
List<Order> getOrdersByStatus(String status)
```
Returns orders filtered by status.

#### Update Order
```dart
Future<void> updateOrder(Order order)
```
Updates an existing order.

#### Delete Order
```dart
Future<void> deleteOrder(String id)
```
Deletes an order by ID.

---

### Inventory Operations

#### Add Inventory Item
```dart
Future<void> addInventoryItem(InventoryItem item)
```
Adds a new inventory item.

**Example**:
```dart
final item = InventoryItem(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  ingredientName: 'Black Tea Leaves',
  stockQuantity: 25.0,
  unit: 'kg',
  lastUpdated: DateTime.now(),
  minStockLevel: 5.0,
);
await databaseService.addInventoryItem(item);
```

#### Get All Inventory Items
```dart
List<InventoryItem> getAllInventoryItems()
```
Returns all inventory items.

#### Get Low Stock Items
```dart
List<InventoryItem> getLowStockItems()
```
Returns items where `stockQuantity <= minStockLevel`.

#### Update Inventory Item
```dart
Future<void> updateInventoryItem(InventoryItem item)
```
Updates an existing inventory item.

#### Delete Inventory Item
```dart
Future<void> deleteInventoryItem(String id)
```
Deletes an inventory item by ID.

---

## User Guide

### Getting Started

1. **Launch the App**: Open the Yamyam Milk Tea app
2. **View Dashboard**: See overview statistics and quick actions
3. **Navigate**: Tap on any card to access that feature

### Managing Products

#### Add a Product
1. Go to **Menu Management**
2. Tap **+ Add Product** button
3. Fill in the form:
   - Product Name (required)
   - Category (dropdown)
   - Price (required, positive number)
   - Description (required)
4. Tap **Add Product**

#### Edit a Product
1. Go to **Menu Management**
2. Find the product in the list
3. Tap the **⋮** menu icon
4. Select **Edit**
5. Update the fields
6. Tap **Update Product**

#### Delete a Product
1. Go to **Menu Management**
2. Find the product
3. Tap the **⋮** menu icon
4. Select **Delete**
5. Confirm deletion

### Managing Orders

#### Create an Order
1. Go to **Orders**
2. Tap **+ New Order** button
3. Enter customer name
4. Tap **Add Item** to select products
5. Choose product and quantity
6. Repeat for all items
7. Review total amount
8. Tap **Create Order**

#### Update Order Status
1. Go to **Orders**
2. Tap on an order to expand
3. Tap **Update Status**
4. Select new status (Pending, Preparing, Completed, Cancelled)

#### Delete an Order
1. Go to **Orders**
2. Tap on an order to expand
3. Tap the **🗑️** delete icon
4. Confirm deletion

### Managing Inventory

#### Add Inventory Item
1. Go to **Inventory**
2. Tap **+ Add Item** button
3. Fill in the form:
   - Ingredient Name (required)
   - Stock Quantity (required)
   - Unit (dropdown)
   - Minimum Stock Level (optional, for alerts)
4. Tap **Add Item**

#### Update Stock Levels
1. Go to **Inventory**
2. Find the item
3. Tap the **⋮** menu icon
4. Select **Edit**
5. Update stock quantity
6. Tap **Update Item**

#### Monitor Low Stock
1. Go to **Inventory**
2. Toggle **Low Stock Only** filter
3. View items below minimum threshold
4. Restock as needed

---

## Development Guide

### Setting Up Development Environment

1. **Install Flutter**
   ```bash
   # Download from https://flutter.dev/docs/get-started/install
   flutter doctor
   ```

2. **Clone Project**
   ```bash
   git clone <repository-url>
   cd flutter_final_inventory
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Generate Code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run App**
   ```bash
   flutter run
   ```

### Code Generation

When modifying Hive models, regenerate TypeAdapters:

```bash
# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch

# Build once
flutter pub run build_runner build --delete-conflicting-outputs
```

### Adding a New Model

1. Create model file in `lib/models/`:
```dart
import 'package:hive/hive.dart';
part 'my_model.g.dart';

@HiveType(typeId: 4) // Use next available ID
class MyModel extends HiveObject {
  @HiveField(0)
  String id;
  
  // Add more fields...
  
  MyModel({required this.id});
}
```

2. Run build_runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Register adapter in `database_service.dart`:
```dart
if (!Hive.isAdapterRegistered(4)) {
  Hive.registerAdapter(MyModelAdapter());
}
```

### Testing

#### Manual Testing Checklist
- [ ] All screens load without errors
- [ ] Forms validate inputs correctly
- [ ] CRUD operations work for all entities
- [ ] Data persists after app restart
- [ ] Delete confirmations appear
- [ ] Success/error messages display
- [ ] Empty states show correctly
- [ ] Navigation flows work smoothly

#### Testing Data Persistence
1. Add some data
2. Close the app completely
3. Reopen the app
4. Verify data is still present

### Common Development Tasks

#### Clear All Data (for testing)
```dart
await databaseService.clearAllData();
```

#### Reset Build
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Format Code
```bash
dart format lib/
```

#### Analyze Code
```bash
flutter analyze
```

### Best Practices

1. **Always validate user input**
2. **Use confirmation dialogs for destructive actions**
3. **Provide feedback for all user actions**
4. **Handle errors gracefully**
5. **Keep UI responsive (use async/await)**
6. **Follow Flutter naming conventions**
7. **Comment complex logic**
8. **Keep widgets small and focused**
9. **Reuse components where possible**
10. **Test on multiple devices**

---

## Support

For issues or questions:
1. Check this documentation
2. Review the README.md
3. Examine the code comments
4. Consult Flutter documentation: https://flutter.dev/docs

---

**Last Updated**: November 2026  
**Version**: 1.0.0  
**Maintained By**: Development Team
