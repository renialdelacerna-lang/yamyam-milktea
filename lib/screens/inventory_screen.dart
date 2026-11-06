import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory.dart';
import '../services/database_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_validators.dart';

/// Inventory management screen for tracking stock levels
/// Supports adding, updating, and deleting inventory items
class InventoryScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const InventoryScreen({
    super.key,
    required this.databaseService,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> _items = [];
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  /// Load inventory items from database
  void _loadInventory() {
    setState(() {
      if (_showLowStockOnly) {
        _items = widget.databaseService.getLowStockItems();
      } else {
        _items = widget.databaseService.getAllInventoryItems();
      }
    });
  }

  /// Navigate to add/edit inventory form
  Future<void> _showInventoryForm({InventoryItem? item}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryFormScreen(
          databaseService: widget.databaseService,
          item: item,
        ),
      ),
    );

    if (result == true) {
      _loadInventory();
    }
  }

  /// Delete inventory item with confirmation
  Future<void> _deleteItem(InventoryItem item) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Inventory Item',
      message: 'Are you sure you want to delete "${item.ingredientName}"? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );

    if (confirmed) {
      await widget.databaseService.deleteInventoryItem(item.id);
      _loadInventory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.ingredientName} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = widget.databaseService.getLowStockItems().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (lowStockCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 16),
                    const SizedBox(width: 4),
                    Text('$lowStockCount Low'),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter toggle
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber, size: 16),
                        const SizedBox(width: 8),
                        Text('Low Stock Only ${lowStockCount > 0 ? "($lowStockCount)" : ""}'),
                      ],
                    ),
                    selected: _showLowStockOnly,
                    onSelected: (selected) {
                      setState(() {
                        _showLowStockOnly = selected;
                        _loadInventory();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.red[100],
                    checkmarkColor: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),

          // Inventory list
          Expanded(
            child: _items.isEmpty
                ? EmptyState(
                    icon: Icons.inventory_2,
                    title: _showLowStockOnly ? 'No Low Stock Items' : 'No Inventory',
                    message: _showLowStockOnly
                        ? 'All items are adequately stocked'
                        : 'Add your first inventory item to get started',
                    actionText: _showLowStockOnly ? null : 'Add Item',
                    onAction: _showLowStockOnly ? null : () => _showInventoryForm(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isLowStock = item.isLowStock;
                      final dateFormat = DateFormat('MMM dd, yyyy');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        color: isLowStock ? Colors.red[50] : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: isLowStock
                                ? Colors.red[100]
                                : Colors.orange[100],
                            child: Icon(
                              isLowStock ? Icons.warning : Icons.inventory,
                              color: isLowStock ? Colors.red[700] : Colors.orange[700],
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.ingredientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isLowStock)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'LOW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.inventory_2, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.stockQuantity} ${item.unit}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isLowStock ? Colors.red[700] : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              if (item.minStockLevel != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Min: ${item.minStockLevel} ${item.unit}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Updated: ${dateFormat.format(item.lastUpdated)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showInventoryForm(item: item);
                              } else if (value == 'delete') {
                                _deleteItem(item);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInventoryForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

/// Inventory form screen for adding/editing inventory items
class InventoryFormScreen extends StatefulWidget {
  final DatabaseService databaseService;
  final InventoryItem? item;

  const InventoryFormScreen({
    super.key,
    required this.databaseService,
    this.item,
  });

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _minStockController;
  String _selectedUnit = 'kg';
  bool _isLoading = false;

  final List<String> _units = ['kg', 'liters', 'pieces', 'grams', 'ml', 'cups', 'bags'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.ingredientName ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.stockQuantity.toString() ?? '',
    );
    _minStockController = TextEditingController(
      text: widget.item?.minStockLevel?.toString() ?? '',
    );
    _selectedUnit = widget.item?.unit ?? 'kg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  /// Save inventory item to database
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final minStock = _minStockController.text.trim().isEmpty
          ? null
          : double.parse(_minStockController.text);

      final item = InventoryItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ingredientName: _nameController.text.trim(),
        stockQuantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        lastUpdated: DateTime.now(),
        minStockLevel: minStock,
      );

      if (widget.item == null) {
        await widget.databaseService.addInventoryItem(item);
      } else {
        await widget.databaseService.updateInventoryItem(item);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.item == null
                  ? 'Inventory item added successfully'
                  : 'Inventory item updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Inventory Item' : 'Add Inventory Item'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ingredient Name *',
                hintText: 'e.g., Black Tea Leaves',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              validator: (value) => InputValidators.required(value, fieldName: 'Ingredient name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity *',
                      hintText: '0',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: InputValidators.nonNegativeNumber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit *',
                      border: OutlineInputBorder(),
                    ),
                    items: _units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minStockController,
              decoration: InputDecoration(
                labelText: 'Minimum Stock Level (Optional)',
                hintText: '0',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.warning_amber),
                helperText: 'Alert when stock falls below this level',
                helperMaxLines: 2,
                suffixText: _selectedUnit,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  return InputValidators.nonNegativeNumber(value, fieldName: 'Minimum stock level');
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: isEditing ? 'Update Item' : 'Add Item',
              onPressed: _saveItem,
              icon: isEditing ? Icons.save : Icons.add,
              isLoading: _isLoading,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
