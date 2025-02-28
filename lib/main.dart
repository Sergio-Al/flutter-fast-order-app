import 'package:flutter/material.dart';

void main() {
  runApp(OfficeOrderApp());
}

class OfficeOrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos para Oficina',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

// Modelos de datos
class User {
  final int id;
  final String name;
  bool active;

  User({required this.id, required this.name, this.active = true});
}

class MenuItem {
  final int id;
  final String name;
  final double price;

  MenuItem({required this.id, required this.name, required this.price});
}

class Order {
  final int id;
  final int userId;
  final String userName;
  final int itemId;
  final String itemName;
  final double price;
  final int quantity;
  final double total;
  bool paid;
  double? amountPaid;
  double change;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.total,
    this.paid = false,
    this.amountPaid,
    this.change = 0,
  });
}

class Payment {
  final int id;
  final int orderId;
  final String userName;
  final double amount;
  final String date;

  Payment({
    required this.id,
    required this.orderId,
    required this.userName,
    required this.amount,
    required this.date,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<User> users = [
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
  
  List<MenuItem> menuItems = [
    MenuItem(id: 1, name: 'Salteñas', price: 6.00),
    MenuItem(id: 2, name: 'Rellenos', price: 5.00),
    MenuItem(id: 3, name: 'Tucumanas', price: 6.00),
    MenuItem(id: 4, name: 'Pie', price: 5.00),
  ];
  
  List<Order> orders = [];
  List<Payment> payments = [];
  int? designatedPersonId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void selectDesignatedPerson(int userId) {
    setState(() {
      designatedPersonId = userId;
    });
  }

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
    
    setState(() {
      orders.add(newOrder);
    });
  }

  void recordPayment(int orderId, double amountPaid) {
    setState(() {
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
    });
  }

  Map<String, double> calculateTotals() {
    final total = orders.fold(0.0, (sum, order) => sum + order.total);
    final totalPaid = orders.where((order) => order.paid).fold(0.0, (sum, order) => sum + order.total);
    final totalPending = total - totalPaid;
    
    return {
      'total': total,
      'totalPaid': totalPaid,
      'totalPending': totalPending,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HANSA - Pedidos para Oficina'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pedidos'),
            Tab(text: 'Pagos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrdersTab(),
          PaymentsTab(),
        ],
      ),
    );
  }

  Widget OrdersTab() {
    // Estados locales para este tab
    int? selectedUserId;
    int? selectedItemId;
    int quantity = 1;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nuevo Pedido',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Selección de persona designada
          Text('Persona designada hoy:', style: TextStyle(fontWeight: FontWeight.w600)),
          DropdownButtonFormField<int>(
            value: designatedPersonId,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: Text('Selecciona una persona'),
            items: users.map((user) {
              return DropdownMenuItem(
                value: user.id,
                child: Text(user.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) selectDesignatedPerson(value);
            },
          ),
          SizedBox(height: 16),
          
          // Selección de quien pide
          Text('¿Quién pide?', style: TextStyle(fontWeight: FontWeight.w600)),
          StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<int>(
                value: selectedUserId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: Text('Selecciona una persona'),
                items: users.map((user) {
                  return DropdownMenuItem(
                    value: user.id,
                    child: Text(user.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedUserId = value);
                },
              );
            }
          ),
          SizedBox(height: 16),
          
          // Selección de ítem
          Text('¿Qué desea ordenar?', style: TextStyle(fontWeight: FontWeight.w600)),
          StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<int>(
                value: selectedItemId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: Text('Selecciona un item'),
                items: menuItems.map((item) {
                  return DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.name} - \$${item.price.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedItemId = value);
                },
              );
            }
          ),
          SizedBox(height: 16),
          
          // Selección de cantidad
          Text('Cantidad:', style: TextStyle(fontWeight: FontWeight.w600)),
          StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() => quantity = int.tryParse(value) ?? 1);
                },
                controller: TextEditingController(text: quantity.toString()),
              );
            }
          ),
          SizedBox(height: 16),
          
          // Botón para agregar pedido
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 45),
            ),
            onPressed: () {
              if (selectedUserId != null && selectedItemId != null) {
                addOrder(selectedUserId!, selectedItemId!, quantity);
                // Reset selecciones
                selectedUserId = null;
                selectedItemId = null;
                quantity = 1;
              }
            },
            child: Text('Agregar al Pedido'),
          ),
          
          SizedBox(height: 24),
          
          // Lista de pedidos
          Text(
            'Pedidos del día:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          orders.isEmpty
              ? Text('No hay pedidos registrados aún.', 
                  style: TextStyle(color: Colors.grey))
              : Column(
                  children: [
                    ...orders.map((order) => OrderItem(order: order, onPaymentRecord: recordPayment)),
                    SizedBox(height: 16),
                    // Resumen
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total:', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('\$${calculateTotals()['total']!.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pagado:', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('\$${calculateTotals()['totalPaid']!.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pendiente:', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('\$${calculateTotals()['totalPending']!.toStringAsFixed(2)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget PaymentsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registro de Pagos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          orders.where((o) => o.paid).isEmpty
              ? Text('No hay pagos registrados aún.', 
                  style: TextStyle(color: Colors.grey))
              : Column(
                  children: orders
                      .where((o) => o.paid)
                      .map((order) => PaymentItem(order: order))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final Order order;
  final Function(int, double) onPaymentRecord;

  const OrderItem({Key? key, required this.order, required this.onPaymentRecord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${order.itemName}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Cantidad: ${order.quantity} x \$${order.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                order.paid
                    ? Text('Pagado', style: TextStyle(color: Colors.green, fontSize: 12))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              double amount = order.total;
                              return AlertDialog(
                                title: Text('Registrar pago'),
                                content: TextField(
                                  decoration: InputDecoration(
                                    labelText: '¿Cuánto paga ${order.userName}?',
                                    suffixText: '\$',
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  controller: TextEditingController(text: order.total.toStringAsFixed(2)),
                                  onChanged: (value) {
                                    amount = double.tryParse(value) ?? order.total;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      onPaymentRecord(order.id, amount);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Registrar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Registrar pago'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentItem extends StatelessWidget {
  final Order order;

  const PaymentItem({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.itemName} x ${order.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Pagó: \$${order.amountPaid?.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (order.change > 0)
                      Text(
                        'Vuelto: \$${order.change.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
