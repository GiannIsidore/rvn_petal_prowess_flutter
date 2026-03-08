import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrdersProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'Pending').toList();
  List<Order> get processingOrders =>
      _orders.where((o) => o.status == 'Processing').toList();
  List<Order> get readyOrders =>
      _orders.where((o) => o.status == 'Ready').toList();
  List<Order> get rejectedOrders =>
      _orders.where((o) => o.status == 'Rejected').toList();
  List<Order> get completedOrders =>
      _orders.where((o) => o.status == 'Completed').toList();
  List<Order> get historyOrders => _orders
      .where(
        (o) =>
            o.status == 'Ready' ||
            o.status == 'Rejected' ||
            o.status == 'Completed',
      )
      .toList();

  int get totalOrders => _orders.length;
  int get pendingCount => pendingOrders.length;
  int get processingCount => processingOrders.length;
  int get readyCount => readyOrders.length;
  int get rejectedCount => rejectedOrders.length;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    _orders = await _apiService.getOrders();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder(Order order) async {
    final result = await _apiService.createOrder(order);
    if (result['status'] == 1) {
      await loadOrders();
      return true;
    }
    return false;
  }

  Future<bool> updateOrderStatus(
    int id,
    String status, {
    String? rejectionReason,
  }) async {
    final result = await _apiService.updateOrderStatus(
      id,
      status,
      rejectionReason: rejectionReason,
    );
    if (result['status'] == 1) {
      await loadOrders();
      return true;
    }
    return false;
  }

  Future<bool> deleteOrder(int id) async {
    final result = await _apiService.deleteOrder(id);
    if (result['status'] == 1) {
      await loadOrders();
      return true;
    }
    return false;
  }
}
