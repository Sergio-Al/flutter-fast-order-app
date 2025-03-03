import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderItem extends StatelessWidget {
  final Order order;
  final Function(int, double) onPaymentRecord;

  const OrderItem(
      {Key? key, required this.order, required this.onPaymentRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${order.itemName}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Cantidad: ${order.quantity} x \$${order.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                order.paid
                    ? const Text(
                        'Pagado',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          textStyle: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                double amount = order.total;
                                return AlertDialog(
                                  title: Text('Registrar Pago'),
                                  content: TextField(
                                    decoration: InputDecoration(
                                      labelText:
                                          'Cuánto paga ${order.userName}?',
                                      suffixText: '\$',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    controller: TextEditingController(
                                        text: order.total.toStringAsFixed(2)),
                                    onChanged: (value) {
                                      amount =
                                          double.tryParse(value) ?? order.total;
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('Cancelar')),
                                    ElevatedButton(
                                        onPressed: () {
                                          onPaymentRecord(order.id, amount);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Registrar Pago'))
                                  ],
                                );
                              });
                        },
                        child: Text('Registrar Pago'),
                      )
              ],
            )
          ],
        ),
      ),
    );
  }
}
