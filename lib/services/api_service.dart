import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/product.dart';

class ApiService {
  // Change this URL to match your server's address.
  // - For web: 'http://localhost/RVN%20PETALS%20PROWESS/api'
  // - For Android emulator: 'http://10.0.2.2/RVN%20PETALS%20PROWESS/api'
  // - For physical device: 'http://<your-pc-ip>/RVN%20PETALS%20PROWESS/api'
  static const String baseUrl = 'http://localhost/RVN%20PETALS%20PROWESS/api';

  Future<Map<String, dynamic>> _post(
    String endpoint,
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        body: {'operation': operation, 'json': jsonEncode(data)},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 0, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 0, 'message': 'Connection error: $e'};
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders.php'),
        body: {'operation': 'getProducts', 'json': jsonEncode({})},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 1 && result['data'] != null) {
          return (result['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder(Order order) async {
    return await _post('orders.php', 'createOrder', order.toJson());
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders.php'),
        body: {'operation': 'getOrders', 'json': jsonEncode({})},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 1 && result['data'] != null) {
          return (result['data'] as List)
              .map((json) => Order.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    int id,
    String status, {
    String? rejectionReason,
  }) async {
    final data = {'id': id, 'status': status};
    if (rejectionReason != null) {
      data['rejection_reason'] = rejectionReason;
    }
    return await _post('orders.php', 'updateOrderStatus', data);
  }

  Future<Map<String, dynamic>> deleteOrder(int id) async {
    return await _post('orders.php', 'deleteOrder', {'id': id});
  }
}
