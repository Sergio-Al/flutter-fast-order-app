import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../widgets/payment_item.dart';

class PaymentTab extends StatelessWidget {
  final List<Order> orders;

  const PaymentTab({Key? key, required this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registro de pagos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            orders.where((order) => order.paid).isEmpty
                ? const Text(
                    'No hay pagos registrados',
                    style: TextStyle(color: Colors.grey),
                  )
                : Column(
                    children: orders
                        .where((order) => order.paid)
                        .map((order) => PaymentItem(order: order))
                        .toList(),
                  )
          ],
        ));
  }
}
