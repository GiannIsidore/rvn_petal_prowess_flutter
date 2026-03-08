import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../widgets/status_badge.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final AuthService _authService = AuthService();
  String? _activeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrders();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout'),
        content: Text('Logout from dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                ctx,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🌸 Owner Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.loadOrders,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(provider),
                  SizedBox(height: 24),
                  if (_activeFilter != null)
                    _buildFilteredSection(provider)
                  else ...[
                    _buildOrderSection(
                      '🟡 Pending Orders',
                      provider.pendingOrders,
                      _buildPendingActions,
                      showRejectionReason: false,
                      showStatusChangeTime: false,
                    ),
                    SizedBox(height: 24),
                    _buildOrderSection(
                      '⚙️ Processing Orders',
                      provider.processingOrders,
                      _buildProcessingActions,
                      showRejectionReason: false,
                      showStatusChangeTime: true,
                    ),
                    SizedBox(height: 24),
                    _buildOrderSection(
                      '📜 Order History',
                      provider.historyOrders,
                      _buildHistoryActions,
                      showRejectionReason: true,
                      showStatusChangeTime: true,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(OrdersProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Orders',
          provider.totalOrders,
          Colors.black87,
          null,
        ),
        _buildSummaryCard(
          'Pending',
          provider.pendingCount,
          Color(0xFF856404),
          'Pending',
        ),
        _buildSummaryCard(
          'Processing',
          provider.processingCount,
          Color(0xFF0066CC),
          'Processing',
        ),
        _buildSummaryCard(
          'Ready',
          provider.readyCount,
          Color(0xFF004080),
          'Ready',
        ),
        _buildSummaryCard(
          'Rejected',
          provider.rejectedCount,
          Color(0xFF721C24),
          'Rejected',
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    Color color,
    String? filterValue,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = _activeFilter == filterValue ? null : filterValue;
        });
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: _activeFilter == filterValue && filterValue != null
                ? Border.all(color: AppConstants.primaryColor, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredSection(OrdersProvider provider) {
    List<Order> filtered;
    switch (_activeFilter) {
      case 'Pending':
        filtered = provider.pendingOrders;
        break;
      case 'Processing':
        filtered = provider.processingOrders;
        break;
      case 'Ready':
        filtered = provider.readyOrders;
        break;
      case 'Rejected':
        filtered = provider.rejectedOrders;
        break;
      default:
        filtered = provider.orders;
    }

    Widget Function(Order) actionBuilder;
    if (_activeFilter == 'Processing') {
      actionBuilder = _buildProcessingActions;
    } else if (_activeFilter == 'Ready') {
      actionBuilder = _buildReadyActions;
    } else {
      actionBuilder = _buildHistoryActions;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$_activeFilter Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () => setState(() => _activeFilter = null),
              child: Text('Show All'),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (filtered.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No $_activeFilter orders yet.')),
            ),
          )
        else
          ...filtered.map(
            (order) => _buildOrderCard(
              order,
              actionBuilder,
              showRejectionReason: true,
              showStatusChangeTime: true,
            ),
          ),
      ],
    );
  }

  Widget _buildOrderSection(
    String title,
    List<Order> orders,
    Widget Function(Order) actionBuilder, {
    required bool showRejectionReason,
    required bool showStatusChangeTime,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            SizedBox(height: 16),
            if (orders.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No orders',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...orders.map(
                (order) => _buildOrderCard(
                  order,
                  actionBuilder,
                  showRejectionReason: showRejectionReason,
                  showStatusChangeTime: showStatusChangeTime,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    Order order,
    Widget Function(Order) actionBuilder, {
    required bool showRejectionReason,
    required bool showStatusChangeTime,
  }) {
    final String dateTime =
        '${order.dateNeeded} ${_formatTime(order.timeNeeded ?? '')}';
    final String statusChangeTime =
        order.approvedAt ?? order.rejectedAt ?? order.readyAt ?? '-';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.product,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          SizedBox(height: 8),
          _buildInfoRow('Size', order.size),
          _buildInfoRow('Customer', order.customerName),
          _buildInfoRow('Email', order.email),
          _buildInfoRow('Phone', order.phone),
          _buildInfoRow('Delivery', order.deliveryMethod),
          _buildInfoRow('Address', order.address),
          _buildInfoRow('Date & Time', dateTime),
          if (order.flowerPreferences != '-')
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: order.flowerPreferences.split(',').map((f) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            f.trim(),
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          _buildInfoRow('Notes', order.notes),
          _buildInfoRow('Qty', '${order.quantity}'),
          _buildInfoRow('Unit Price', '₱${order.unitPrice.toStringAsFixed(2)}'),
          _buildInfoRow(
            'Delivery Charge',
            '₱${order.deliveryCharge.toStringAsFixed(2)}',
          ),
          _buildInfoRow(
            'Total',
            '₱${order.totalPrice.toStringAsFixed(2)}',
            isBold: true,
          ),
          if (showStatusChangeTime)
            _buildInfoRow('Status Changed', statusChangeTime),
          if (showRejectionReason && order.rejectionReason != null)
            _buildInfoRow('Rejection Reason', order.rejectionReason!),
          SizedBox(height: 8),
          actionBuilder(order),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(Order order) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus(order.id!, 'Processing'),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF43A047)),
            child: Text('Approve'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showRejectionDialog(order.id!),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFC62828)),
            child: Text('Reject'),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingActions(Order order) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _updateStatus(order.id!, 'Ready'),
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1976D2)),
        child: Text('Mark as Ready'),
      ),
    );
  }

  Widget _buildReadyActions(Order order) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _markCompleted(order.id!),
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF9800)),
        child: Text('Ready to Pick Up/Deliver'),
      ),
    );
  }

  Widget _buildHistoryActions(Order order) {
    if (order.status == 'Ready') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _markCompleted(order.id!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9800),
              ),
              child: Text('Pick Up/Deliver'),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _deleteOrder(order.id!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF616161),
              ),
              child: Text('Delete'),
            ),
          ),
        ],
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _deleteOrder(order.id!),
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF616161)),
        child: Text('Delete'),
      ),
    );
  }

  void _updateStatus(int id, String status) {
    context.read<OrdersProvider>().updateOrderStatus(id, status).then((
      success,
    ) {
      if (!success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status')));
      }
    });
  }

  void _markCompleted(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Mark this order as picked up/delivered?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrdersProvider>().updateOrderStatus(id, 'Completed');
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(int orderId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject Order', style: TextStyle(color: Color(0xFFC62828))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejecting this order:'),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<OrdersProvider>().updateOrderStatus(
                orderId,
                'Rejected',
                rejectionReason: controller.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFC62828)),
            child: Text('Reject Order'),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Order'),
        content: Text('Delete this order permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrdersProvider>().deleteOrder(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF616161)),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int min = int.parse(parts[1]);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:${min.toString().padLeft(2, '0')} $ampm';
    } catch (e) {
      return timeStr;
    }
  }
}
