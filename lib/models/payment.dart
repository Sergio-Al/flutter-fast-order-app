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
