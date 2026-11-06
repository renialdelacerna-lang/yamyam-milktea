import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_validators.dart';

/// Order management screen for creating and viewing orders
/// Supports full order lifecycle from creation to completion
class OrderScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const OrderScreen({
    super.key,
    required this.databaseService,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Order> _orders = [];
  String _selectedStatus = 'All';
  final List<String> _statusFilters = ['All', 'Pending', 'Preparing', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  /// Load orders from database
  void _loadOrders() {
    setState(() {
      if (_selectedStatus == 'All') {
        _orders = widget.databaseService.getOrdersSortedByDate();
      } else {
        _orders = widget.databaseService.getOrdersByStatus(_selectedStatus);
      }
    });
  }

  /// Navigate to create new order
  Future<void> _createOrder() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderScreen(
          databaseService: widget.databaseService,
        ),
      ),
    );

    if (result == true) {
      _loadOrders();
    }
  }

  /// Update order status
  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    final updatedOrder = order.copyWith(status: newStatus);
    await widget.databaseService.updateOrder(updatedOrder);
    _loadOrders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Delete order with confirmation
  Future<void> _deleteOrder(Order order) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Order',
      message: 'Are you sure you want to delete this order? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );

    if (confirmed) {
      await widget.databaseService.deleteOrder(order.id);
      _loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status filter
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((status) {
                  final isSelected = status == _selectedStatus;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = status;
                          _loadOrders();
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.green[100],
                      checkmarkColor: Colors.green[700],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders list
          Expanded(
            child: _orders.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long,
                    title: 'No Orders',
                    message: _selectedStatus == 'All'
                        ? 'Create your first order to get started'
                        : 'No orders with this status',
                    actionText: 'Create Order',
                    onAction: _createOrder,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(order.status).withValues(alpha: 0.2),
                            child: Icon(
                              Icons.shopping_bag,
                              color: _getStatusColor(order.status),
                            ),
                          ),
                          title: Text(
                            order.customerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(dateFormat.format(order.timestamp)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      order.status,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: _getStatusColor(order.status).withValues(alpha: 0.2),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${order.items.length} item(s)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text(
                            '₱${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Items:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...order.items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.quantity}x ${item.productName}',
                                            ),
                                          ),
                                          Text(
                                            '₱${item.totalPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '₱${order.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      if (order.status != 'Completed' && order.status != 'Cancelled')
                                        Expanded(
                                          child: PopupMenuButton<String>(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.update, color: Colors.white, size: 18),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Update Status',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onSelected: (status) => _updateOrderStatus(order, status),
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'Pending',
                                                child: Text('Pending'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'Preparing',
                                                child: Text('Preparing'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'Completed',
                                                child: Text('Completed'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'Cancelled',
                                                child: Text('Cancelled'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => _deleteOrder(order),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Delete Order',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createOrder,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Screen for creating new orders
class CreateOrderScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const CreateOrderScreen({
    super.key,
    required this.databaseService,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final List<OrderItem> _orderItems = [];
  final List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  /// Load available products
  void _loadProducts() {
    setState(() {
      _products.addAll(widget.databaseService.getAllProducts());
    });
  }

  /// Add item to order
  void _addItem() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No products available. Please add products first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Product? selectedProduct;
    int quantity = 1;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Product>(
                    decoration: const InputDecoration(
                      labelText: 'Select Product',
                      border: OutlineInputBorder(),
                    ),
                    items: _products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text('${product.name} - ₱${product.price.toStringAsFixed(2)}'),
                      );
                    }).toList(),
                    onChanged: (product) {
                      setDialogState(() {
                        selectedProduct = product;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: '1',
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      quantity = int.tryParse(value) ?? 1;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedProduct != null && quantity > 0) {
                      Navigator.pop(context, {
                        'product': selectedProduct,
                        'quantity': quantity,
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final product = result['product'] as Product;
      final qty = result['quantity'] as int;

      setState(() {
        _orderItems.add(
          OrderItem(
            productId: product.id,
            productName: product.name,
            productPrice: product.price,
            quantity: qty,
          ),
        );
      });
    }
  }

  /// Remove item from order
  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  /// Create order
  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item to the order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _customerNameController.text.trim(),
        items: _orderItems,
        totalAmount: Order.calculateTotal(_orderItems),
        timestamp: DateTime.now(),
        status: 'Pending',
      );

      await widget.databaseService.addOrder(order);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating order: $e'),
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
    final total = Order.calculateTotal(_orderItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name *',
                      hintText: 'Enter customer name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        InputValidators.required(value, fieldName: 'Customer name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_orderItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No items added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._orderItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text(
                            'Quantity: ${item.quantity} × ₱${item.productPrice.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₱${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₱${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Create Order',
                    onPressed: _createOrder,
                    icon: Icons.check,
                    isLoading: _isLoading,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
