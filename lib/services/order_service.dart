import '../models/user.dart';
import '../models/order.dart';
import '../models/menu_item.dart';
import '../models/payment.dart';

class OrderService {
  final List<User> users = [
    User(id: 1, name: 'Ludbin'),
    User(id: 2, name: 'Sergio Ampuero'),
    User(id: 3, name: 'Jhonny'),
    User(id: 4, name: 'Grissel'),
    User(id: 5, name: 'Jorge'),
    User(id: 6, name: 'Albert'),
    User(id: 7, name: 'Angela'),
    User(id: 8, name: 'Carlitos'),
    User(id: 9, name: 'Sergio Machaca'),
    User(id: 10, name: 'Kevin'),
    User(id: 11, name: 'Juan Carlos'),
    User(id: 12, name: 'Ronald'),
    User(id: 13, name: 'Alexander'),
    User(id: 14, name: 'Amigo de Ronald'),
  ];

  final List<MenuItem> menuItems = [
    MenuItem(id: 1, name: 'Salteñas', price: 6.00),
    MenuItem(id: 2, name: 'Rellenos', price: 5.00),
    MenuItem(id: 3, name: 'Tucumanas', price: 6.00),
    MenuItem(id: 4, name: 'Pie', price: 5.00),
  ];

  List<Order> orders = [];
  List<Payment> payments = [];

  void addOrder(int userId, int itemId, int quantity) {
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
  }

  void recordPayment(int orderId, double amountPaid) {
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

    final order = orders.firstWhere((o) => o.id == orderId);
    payments.add(Payment(
      id: DateTime.now().millisecondsSinceEpoch,
      orderId: orderId,
      userName: order.userName,
      amount: amountPaid,
      date: DateTime.now().toLocal().toString().split(' ')[0],
    ));
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
