import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:office_order_app/models/user.dart';
import 'package:office_order_app/models/menu_item.dart';
import 'package:office_order_app/models/order.dart';
import 'package:office_order_app/models/payment.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('office_order.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        active $boolType DEFAULT 1
      )
    ''');

     // Create menu_items table
    await db.execute('''
    CREATE TABLE menu_items (
      id $idType,
      name $textType,
      price $doubleType
    )
    ''');

    await db.execute('''
    CREATE TABLE orders (
      id $idType,
      userId $intType,
      userName $textType,
      itemId $intType,
      itemName $textType,
      price $doubleType,
      quantity $intType,
      total $doubleType,
      paid $boolType,
      amountPaid $doubleType,
      change $doubleType
    )
    ''');

    await db.execute('''
    CREATE TABLE payments (
      id $idType,
      orderId $intType,
      userName $textType,
      amount $doubleType,
      date $textType
    )
    ''');

    // Insert default users
    await _insertDefaultUsers(db);

    // Insert default menu items
    await _insertDefaultMenuItems(db);
  }

  Future<void> _insertDefaultUsers(Database db) async {
    final defaultUsers = [
      {'id': 1, 'name': 'Ludbin', 'active': 1},
      {'id': 2, 'name': 'Sergio Ampuero', 'active': 1},
      {'id': 3, 'name': 'Jhonny', 'active': 1},
      {'id': 4, 'name': 'Grissel', 'active': 1},
      {'id': 5, 'name': 'Jorge', 'active': 1},
      {'id': 6, 'name': 'Albert', 'active': 1},
      {'id': 7, 'name': 'Angela', 'active': 1},
      {'id': 8, 'name': 'Carlitos', 'active': 1},
      {'id': 9, 'name': 'Sergio Machaca', 'active': 1},
      {'id': 10, 'name': 'Kevin', 'active': 1},
      {'id': 11, 'name': 'Juan Carlos', 'active': 1},
      {'id': 12, 'name': 'Ronald', 'active': 1},
      {'id': 13, 'name': 'Alexander', 'active': 1},
      {'id': 14, 'name': 'Amigo de Ronald', 'active': 1},
    ];

    for (final user in defaultUsers) {
      await db.insert('users', user);
    }
  }

  Future<void> _insertDefaultMenuItems(Database db) async {
    final defaultMenuItems = [
      {'id': 1, 'name': 'Salteñas', 'price': 6.00},
      {'id': 2, 'name': 'Rellenos', 'price': 5.00},
      {'id': 3, 'name': 'Tucumanas', 'price': 6.00},
      {'id': 4, 'name': 'Pie', 'price': 5.00},
    ];

    for (final item in defaultMenuItems) {
      await db.insert('menu_items', item);
    }
  }

  // CRUD methods for Users
  Future<List<User>> getUsers() async {
    final db = await instance.database;
    final result = await db.query('users');

    return result
        .map((json) => User(
              id: json['id'] as int,
              name: json['name'] as String,
              active: json['active'] == 1,
            ))
        .toList();
  }

  // CRUD methods for Menu Items
  Future<List<MenuItem>> getMenuItems() async {
    final db = await instance.database;
    final result = await db.query('menu_items');

    return result
        .map((json) => MenuItem(
              id: json['id'] as int,
              name: json['name'] as String,
              price: json['price'] as double,
            ))
        .toList();
  }

  // CRUD methods for Orders
  Future<List<Order>> getOrders() async {
    final db = await instance.database;
    final result = await db.query('orders');

    return result
        .map((json) => Order(
              id: json['id'] as int,
              userId: json['userId'] as int,
              userName: json['userName'] as String,
              itemId: json['itemId'] as int,
              itemName: json['itemName'] as String,
              price: json['price'] as double,
              quantity: json['quantity'] as int,
              total: json['total'] as double,
              paid: json['paid'] == 1,
              amountPaid: json['amountPaid'] as double?,
              change: json['change'] as double,
            ))
        .toList();
  }

  Future<int> insertOrder(Order order) async {
    final db = await instance.database;
    return await db.insert('orders', {
      'id': order.id,
      'userId': order.userId,
      'userName': order.userName,
      'itemId': order.itemId,
      'itemName': order.itemName,
      'price': order.price,
      'quantity': order.quantity,
      'total': order.total,
      'paid': order.paid ? 1 : 0,
      'amountPaid': order.amountPaid,
      'change': order.change,
    });
  }

  Future<int> updateOrder(Order order) async {
    final db = await instance.database;
    return db.update(
        'orders',
        {
          'userId': order.userId,
          'userName': order.userName,
          'itemId': order.itemId,
          'itemName': order.itemName,
          'price': order.price,
          'quantity': order.quantity,
          'total': order.total,
          'paid': order.paid ? 1 : 0,
          'amountPaid': order.amountPaid,
          'change': order.change,
        },
        where: 'id = ?',
        whereArgs: [order.id]);
  }

  // CRUD methods for Payments
  Future<int> insertPayment(Payment payment) async {
    final db = await instance.database;
    return await db.insert('payments', {
      'id': payment.id,
      'orderId': payment.orderId,
      'userName': payment.userName,
      'amount': payment.amount,
      'date': payment.date,
    });
  }

  Future<List<Payment>> getPayments() async {
    final db = await instance.database;
    final result = await db.query('payments');
    return result
        .map((json) => Payment(
              id: json['id'] as int,
              orderId: json['orderId'] as int,
              userName: json['userName'] as String,
              amount: json['amount'] as double,
              date: json['date'] as String,
            ))
        .toList();
  }
}
