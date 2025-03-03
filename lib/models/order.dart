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
