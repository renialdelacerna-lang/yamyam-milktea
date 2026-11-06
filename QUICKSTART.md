# Yamyam Milk Tea - Quick Start Guide

## 🚀 5-Minute Setup

### Step 1: Prerequisites Check
Verify you have Flutter installed:
```bash
flutter doctor
```

You should see ✓ marks for Flutter and your target platform (Android/iOS).

### Step 2: Install Dependencies
```bash
cd flutter_final_inventory
flutter pub get
```

### Step 3: Verify Generated Files
The Hive TypeAdapters should already be generated. Check if these files exist:
- `lib/models/product.g.dart`
- `lib/models/order.g.dart`
- `lib/models/inventory.g.dart`

If not, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Run the App
```bash
flutter run
```

Choose your target device when prompted.

---

## 📖 First-Time Usage Tutorial

### Adding Your First Product

1. **Launch the app** - You'll see the home screen with "Yamyam Milk Tea"
2. **Tap "Menu Management"** - The blue card
3. **Tap "+ Add Product"** - The floating button at bottom right
4. **Fill in the form**:
   - **Product Name**: Classic Milk Tea
   - **Category**: Select "Milk Tea" from dropdown
   - **Price**: 65.00
   - **Description**: Traditional milk tea with tapioca pearls
5. **Tap "Add Product"** button
6. **Success!** - You'll see a green confirmation message

### Creating Your First Order

1. **Return to home screen** - Tap the back arrow
2. **Tap "Orders"** - The green card
3. **Tap "+ New Order"** - The floating button
4. **Enter customer name**: Juan dela Cruz
5. **Tap "Add Item"** button
6. **Select product**: Classic Milk Tea
7. **Set quantity**: 2
8. **Tap "Add"** in the dialog
9. **Review the order** - Total should show ₱130.00
10. **Tap "Create Order"** button
11. **Success!** - Order is created with "Pending" status

### Adding Inventory Items

1. **Return to home screen** - Tap the back arrow
2. **Tap "Inventory"** - The orange card
3. **Tap "+ Add Item"** - The floating button
4. **Fill in the form**:
   - **Ingredient Name**: Black Tea Leaves
   - **Stock Quantity**: 25
   - **Unit**: Select "kg" from dropdown
   - **Minimum Stock Level**: 5 (optional, for low stock alerts)
5. **Tap "Add Item"** button
6. **Success!** - Item added to inventory

---

## 💡 Quick Tips

### Navigation
- **Home button** (←) always takes you back
- **Three dots menu (⋮)** on items shows Edit/Delete options
- **Tap anywhere on a card** to expand/collapse details

### Filtering & Viewing
- **Menu**: Filter by category (All, Milk Tea, Fruit Tea, Toppings)
- **Orders**: Filter by status (All, Pending, Preparing, Completed, Cancelled)
- **Inventory**: Toggle "Low Stock Only" to see items needing restocking

### Editing Items
1. Find the item in the list
2. Tap the **⋮** menu icon
3. Select **Edit**
4. Make your changes
5. Tap **Update** button

### Deleting Items
1. Find the item in the list
2. Tap the **⋮** menu icon
3. Select **Delete**
4. **Confirm** in the dialog (or Cancel to abort)

### Updating Order Status
1. Go to **Orders**
2. **Tap on an order** to expand it
3. Tap **Update Status** button
4. Select new status from the menu

---

## 🎯 Sample Data for Testing

Want to quickly populate the app with test data? Add these:

### Sample Products

**Product 1:**
- Name: Classic Milk Tea
- Category: Milk Tea
- Price: 65.00
- Description: Traditional milk tea with tapioca pearls

**Product 2:**
- Name: Matcha Milk Tea
- Category: Milk Tea
- Price: 75.00
- Description: Premium Japanese matcha with fresh milk

**Product 3:**
- Name: Mango Fruit Tea
- Category: Fruit Tea
- Price: 70.00
- Description: Fresh mango fruit tea with real fruit pieces

**Product 4:**
- Name: Pearl Toppings
- Category: Toppings
- Price: 15.00
- Description: Chewy tapioca pearls add-on

### Sample Inventory

**Item 1:**
- Ingredient: Black Tea Leaves
- Quantity: 25
- Unit: kg
- Min Level: 5

**Item 2:**
- Ingredient: Tapioca Pearls
- Quantity: 50
- Unit: kg
- Min Level: 10

**Item 3:**
- Ingredient: Fresh Milk
- Quantity: 30
- Unit: liters
- Min Level: 10

**Item 4:**
- Ingredient: Matcha Powder
- Quantity: 8
- Unit: kg
- Min Level: 2

---

## ❓ Troubleshooting

### App won't start
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### "No device found" error
- Make sure USB debugging is enabled (Android)
- Make sure device is connected and authorized
- Run `flutter devices` to see available devices

### Changes not appearing
- Use **Hot Restart** (R in terminal) instead of Hot Reload (r)
- For model changes, always regenerate with build_runner

### Data not saving
- Check that `await databaseService.initialize()` completes in main.dart
- Close and reopen the app to verify persistence

---

## 📱 Recommended Testing Flow

1. ✅ Add 3-5 products
2. ✅ Create 2-3 orders
3. ✅ Add 4-5 inventory items
4. ✅ Edit a product
5. ✅ Update an order status
6. ✅ Delete an item (with confirmation)
7. ✅ **Close the app completely**
8. ✅ **Reopen the app**
9. ✅ Verify all data is still there
10. ✅ Test low stock filter in inventory

---

## 🎓 What to Show Your Professor

### Demonstrate These Features:

1. **CRUD Operations**
   - ✅ Create: Add new products, orders, inventory
   - ✅ Read: View lists and details
   - ✅ Update: Edit existing items
   - ✅ Delete: Remove with confirmation

2. **Input Validation**
   - Try to submit empty forms → Should show errors
   - Try negative prices → Should reject
   - Required fields marked with *

3. **Data Persistence**
   - Add data → Close app → Reopen → Data still there

4. **User Experience**
   - Clear navigation
   - Success/error messages
   - Empty states with helpful text
   - Confirmation dialogs for deletions

5. **Code Quality**
   - Show modular file structure
   - Point out comments and documentation
   - Explain Hive integration
   - Demonstrate TypeAdapter generation

---

## 📚 Next Steps

- Read **README.md** for detailed project information
- Check **DOCUMENTATION.md** for technical details
- Explore the code structure in `lib/` folder
- Review comments in the source code

---

**Good luck with your presentation! 🎉**
