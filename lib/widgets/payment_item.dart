import 'package:flutter/material.dart';

import '../models/order.dart';

class PaymentItem extends StatelessWidget {
  final Order order;

  const PaymentItem({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(
            height: 4,
          ),
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
                    )
                ],
              )
            ],
          )
        ]),
      ),
    );
  }
}
