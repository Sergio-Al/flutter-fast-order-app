import 'package:office_order_app/services/database_helper.dart';

import '../models/user.dart';
import '../models/order.dart';
import '../models/menu_item.dart';
import '../models/payment.dart';

class OrderService {
  List<User> users = [];
  List<MenuItem> menuItems = [];
  List<Order> orders = [];
  List<Payment> payments = [];

  // Get database instance
  final dbHelper = DatabaseHelper.instance;

  OrderService() {
    loadDataFromDatabase();
  }

  // Load data from database
  Future<void> loadDataFromDatabase() async {
    users = await dbHelper.getUsers();
    menuItems = await dbHelper.getMenuItems();
    orders = await dbHelper.getOrders();
    payments = await dbHelper.getPayments();
  }

  Future<void> addOrder(int userId, int itemId, int quantity) async {
    final user = users.firstWhere((u) => u.id == userId);
    final item = menuItems.firstWhere((i) => i.id == itemId);

    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: userId,
      userName: user.name,
      itemId: itemId,
      itemName: item.name,
      price: item.price,
      quantity: quantity,
      total: item.price * quantity,
    );

    orders.add(newOrder);

    // Save order to database
    await dbHelper.insertOrder(newOrder);
  }

  Future<void> recordPayment(int orderId, double amountPaid) async {
    orders = orders.map((order) {
      if (order.id == orderId) {
        final change = amountPaid - order.total;
        return Order(
          id: order.id,
          userId: order.userId,
          userName: order.userName,
          itemId: order.itemId,
          itemName: order.itemName,
          price: order.price,
          quantity: order.quantity,
          total: order.total,
          paid: true,
          amountPaid: amountPaid,
          change: change > 0 ? change : 0,
        );
      }
      return order;
    }).toList();

    // Get the updated order
    final order = orders.firstWhere((o) => o.id == orderId);

    // Update order in database
    await dbHelper.updateOrder(order);

    // Create and save payment to database
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch,
      orderId: orderId,
      userName: order.userName,
      amount: amountPaid,
      date: DateTime.now().toLocal().toString().split(' ')[0],
    );

    // Save payment to database
    await dbHelper.insertPayment(payment);
  }

  Map<String, double> calculateTotals() {
    final total = orders.fold(0.0, (sum, order) => sum + order.total);
    final totalPaid = orders
        .where((order) => order.paid)
        .fold(0.0, (sum, order) => sum + order.total);
    final totalPending = total - totalPaid;

    return {
      'total': total,
      'totalPaid': totalPaid,
      'totalPending': totalPending,
    };
  }
}
