# Yamyam Milk Tea - Inventory Management System

A production-grade Flutter mobile application for managing a milk tea shop's inventory, menu, and orders. Built for **CCIT-06: Application Development and Emerging Technologies** final project.

## 📱 Features

### Core Functionality
- **Menu Management**: Full CRUD operations for products/menu items
- **Order Management**: Create, track, and manage customer orders
- **Inventory Tracking**: Monitor stock levels with low-stock alerts
- **Data Persistence**: All data stored locally using Hive database

### User Interface
- Clean, intuitive dashboard with quick access to all features
- Responsive layouts optimized for mobile devices
- Visual feedback for all user actions
- Empty states with helpful guidance
- Confirmation dialogs for destructive operations

### Data Models
1. **Product/Menu Item**: Name, Category, Price, Description
2. **Order**: Customer Name, Items, Total Amount, Timestamp, Status
3. **Inventory**: Ingredient Name, Stock Quantity, Unit, Minimum Stock Level

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                  # App entry point & Hive initialization
├── models/                    # Data models with Hive annotations
│   ├── product.dart          # Product model
│   ├── order.dart            # Order & OrderItem models
│   └── inventory.dart        # Inventory model
├── services/                  # Business logic & database operations
│   └── database_service.dart # Hive CRUD operations manager
├── screens/                   # UI screens
│   ├── home_screen.dart      # Dashboard with statistics
│   ├── menu_screen.dart      # Menu/product management
│   ├── order_screen.dart     # Order creation & tracking
│   └── inventory_screen.dart # Stock management
└── widgets/                   # Reusable UI components
    ├── custom_button.dart    # Styled button component
    ├── confirmation_dialog.dart # Delete confirmation
    ├── empty_state.dart      # Empty list placeholder
    └── input_validators.dart # Form validation functions
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.13.0 or higher)
- Dart SDK (3.13.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator / iOS simulator

### Installation

1. **Clone or extract the project**
   ```bash
   cd flutter_final_inventory
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive TypeAdapters** (if not already generated)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Production Dependencies
- `hive: ^2.2.3` - Local NoSQL database
- `hive_flutter: ^1.1.0` - Hive Flutter integration
- `intl: ^0.19.0` - Date formatting utilities

### Development Dependencies
- `hive_generator: ^2.0.1` - Code generation for Hive
- `build_runner: ^2.4.13` - Build system for code generation
- `flutter_lints: ^6.0.0` - Linting rules

## 💾 Database Implementation

### Hive Setup
The app uses **Hive** for local data persistence with the following features:

1. **Type-safe storage** using custom TypeAdapters
2. **Automatic code generation** for adapters
3. **Fast read/write operations** with lazy loading
4. **Data persistence** across app restarts

### Database Operations
All CRUD operations are handled through `DatabaseService`:

```dart
// Example: Adding a product
final product = Product(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'Classic Milk Tea',
  category: 'Milk Tea',
  price: 65.00,
  description: 'Traditional milk tea with tapioca pearls',
  createdAt: DateTime.now(),
);
await databaseService.addProduct(product);
```

## 🎨 UI/UX Features

### Input Validation
- Required field validation
- Number format validation (prices, quantities)
- Positive number checks
- Maximum decimal place restrictions
- Real-time error feedback

### User Feedback
- Success/error snackbar messages
- Loading indicators for async operations
- Empty state guidance
- Confirmation dialogs for deletions
- Visual status indicators

### Navigation Flow
```
Home Screen (Dashboard)
    ├── Menu Management → Add/Edit Product
    ├── Orders → Create Order → Select Products
    └── Inventory → Add/Edit Stock Item
```

## 🔒 Data Safety

### Validation
- All forms include comprehensive input validation
- Required fields are clearly marked
- Invalid data is prevented from submission

### Confirmation
- Delete operations require user confirmation
- Clear warning messages before destructive actions
- Cancel options always available

## 📊 Testing Checklist

### CRUD Operations
- [x] Create new products, orders, and inventory items
- [x] Read/display all data in organized lists
- [x] Update existing records seamlessly
- [x] Delete records with confirmation

### Data Persistence
- [x] Data survives app restart
- [x] Hive boxes initialize correctly
- [x] TypeAdapters properly serialize/deserialize

### UI/UX
- [x] Clean, intuitive navigation
- [x] Responsive layouts on different screen sizes
- [x] Empty states display correctly
- [x] Form validation prevents invalid input
- [x] Success/error feedback works

## 📝 Code Quality

### Standards Followed
- Meaningful variable and class names
- Comprehensive code comments
- Modular file organization
- Separation of concerns (Models, Services, UI)
- No hardcoded sensitive data
- Consistent code formatting

### Documentation
- Function-level documentation
- Model field descriptions
- Complex logic explanations
- Usage examples in comments

## 🎓 Academic Information

**Course**: CCIT-06: Application Development and Emerging Technologies  
**Project**: Yamyam Milk Tea - Inventory Management System  
**Technology Stack**: Flutter, Dart, Hive  
**Database**: Hive (Local NoSQL)

### Learning Objectives Achieved
1. ✅ Mobile application development with Flutter
2. ✅ Local database integration (Hive)
3. ✅ CRUD operations implementation
4. ✅ User interface design and UX principles
5. ✅ Data persistence and state management
6. ✅ Form validation and error handling
7. ✅ Modular code architecture

## 🐛 Troubleshooting

### Common Issues

**Issue**: Build fails with TypeAdapter errors
```bash
# Solution: Regenerate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue**: Hot reload doesn't work after changes
```bash
# Solution: Hot restart the app
Press 'R' in terminal or click Hot Restart button
```

**Issue**: Data not persisting
```bash
# Solution: Check Hive initialization in main.dart
# Ensure await databaseService.initialize() completes before runApp()
```

## 📄 License

This project is created for educational purposes as part of a college final project.

## 👨‍💻 Developer Notes

### Future Enhancements
- Export data to CSV/PDF
- Search and filter functionality
- Sales reports and analytics
- Multi-user support with authentication
- Cloud synchronization
- Push notifications for low stock
- Barcode scanning for inventory

### Known Limitations
- Local-only storage (no cloud backup)
- Single-device usage
- No user authentication
- Limited to mobile platforms

---

**Built with ❤️ using Flutter & Dart**

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
