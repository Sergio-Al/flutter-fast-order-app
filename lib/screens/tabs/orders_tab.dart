import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';
import '../../widgets/order_item.dart';

class OrdersTab extends StatefulWidget {
  final List<User> users;
  final List<MenuItem> menuItems;
  final List<Order> orders;
  final int? designatedPersonId;
  final Function(int) selectDesignatedPerson;
  final Function(int, int, int) addOrder;
  final Function(int, double) recordPayment;
  final Map<String, double> Function() calculateTotals;

  const OrdersTab({
    Key? key,
    required this.users,
    required this.menuItems,
    required this.orders,
    required this.designatedPersonId,
    required this.selectDesignatedPerson,
    required this.addOrder,
    required this.recordPayment,
    required this.calculateTotals,
  }) : super(key: key);

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  int? selectedUserId;
  int? selectedItemId;
  int quantity = 1;

  void _resetSelections() {
    setState(() {
      selectedUserId = null;
      selectedItemId = null;
      quantity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nuevo Pedido',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 16,
          ),

          // User selection
          const Text(
            'Persona designada para el pedido: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          DropdownButtonFormField<int>(
            value: widget.designatedPersonId,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            hint: const Text('Selecciona una persona'),
            items: widget.users.map((user) {
              return DropdownMenuItem(value: user.id, child: Text(user.name));
            }).toList(),
            onChanged: (value) {
              if (value != null) widget.selectDesignatedPerson(value);
            },
          ),
          const SizedBox(
            height: 16,
          ),

          // Who is ordering selection
          const Text(
            '¿Quién está ordenando?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          DropdownButtonFormField<int>(
            value: selectedUserId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            hint: const Text('Selecciona una persona'),
            items: widget.users.map((user) {
              return DropdownMenuItem(
                value: user.id,
                child: Text(user.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedUserId = value;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),

          // Item selection
          const Text(
            '¿Qué desea ordenar?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          DropdownButtonFormField<int>(
            value: selectedItemId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('Selecciona un producto'),
            items: widget.menuItems.map((item) {
              return DropdownMenuItem(
                value: item.id,
                child:
                    Text('${item.name} - \$${item.price.toStringAsFixed(2)}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedItemId = value);
            },
          ),
          const SizedBox(
            height: 16,
          ),

          // Quantity selection
          const Text(
            'Cantidad:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => quantity = int.tryParse(value) ?? 1);
            },
            controller: TextEditingController(text: quantity.toString()),
          ),
          const SizedBox(
            height: 16,
          ),

          // Add order button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45)),
            onPressed: () {
              if (selectedUserId != null && selectedItemId != null) {
                widget.addOrder(selectedUserId!, selectedItemId!, quantity);
                _resetSelections();
              }
            },
            child: const Text('Agregar Pedido'),
          ),

          const SizedBox(
            height: 24,
          ),

          // Orders list
          const Text('Pedidos del día',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          widget.orders.isEmpty
              ? const Text(
                  'No hay pedidos registrados',
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  children: [
                    ...widget.orders.map((order) => OrderItem(
                        order: order, onPaymentRecord: widget.recordPayment)),
                    const SizedBox(height: 8),
                    // Totals
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '\$${widget.calculateTotals()['total']!.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pagado',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '\$${widget.calculateTotals()['totalPaid']!.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pendientes:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '\$${widget.calculateTotals()['totalPending']!.toStringAsFixed(2)}',
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )
        ],
      ),
    );
  }
}
