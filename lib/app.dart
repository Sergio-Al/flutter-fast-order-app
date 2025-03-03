import 'package:flutter/material.dart';

import 'package:office_order_app/screens/tabs/orders_tab.dart';
import 'package:office_order_app/screens/tabs/payment_tab.dart';
import 'package:office_order_app/services/order_service.dart';

class OfficeOrderApp extends StatelessWidget {
  const OfficeOrderApp({Key? key}) : super(key: key);

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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? designatedPersonId;

  final OrderService _orderService = OrderService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HANSA - Pedidos para Oficina'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pedidos'),
            Tab(text: 'Pagos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrdersTab(
              users: _orderService.users,
              menuItems: _orderService.menuItems,
              orders: _orderService.orders,
              designatedPersonId: designatedPersonId,
              selectDesignatedPerson: selectDesignatedPerson,
              addOrder: _addOrderAndUpdateUI,
              recordPayment: _recordPaymentAndUpdateUI,
              calculateTotals: _orderService.calculateTotals),
          PaymentTab(orders: _orderService.orders)
        ],
      ),
    );
  }

  void _addOrderAndUpdateUI(int userId, int itemId, int quantity) {
    setState(() {
      _orderService.addOrder(userId, itemId, quantity);
    });
  }

  void _recordPaymentAndUpdateUI(int orderId, double amountPaid) {
    setState(() {
      _orderService.recordPayment(orderId, amountPaid);
    });
  }
}
