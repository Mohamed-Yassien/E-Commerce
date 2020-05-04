import 'package:flutter/cupertino.dart';
import '../providers/cart.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double total;
  final DateTime dateTime;
  final List<CartItem> products;

  OrderItem(
      {@required this.id,
      @required this.total,
      @required this.dateTime,
      @required this.products});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken,this.userId,this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  // ignore: missing_return
  Future<void> fetchAndSetOrders() async {
    final url = 'https://give-moment.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData.isEmpty){
      return ;
    }
    List<OrderItem> loadedData = [];
    extractedData.forEach((orderId, orderData) {
      loadedData.add(
        OrderItem(
          id: orderId,
          total: orderData['total'],
          dateTime: DateTime.parse(orderData['dateTiem']),
          products: (orderData['products'] as List<dynamic>).map((item){
            return CartItem(
              id: item['id'],
              price: item['price'],
              quantity: item['quantity'],
              title: item['title'],
            );
          }).toList() ,
        ),
      );
      _orders = loadedData;
      notifyListeners();
    });
  }

  // ignore: missing_return
  Future<void> addOrder(List<CartItem> products, double amount) async {
    final url = 'https://give-moment.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.post(url,
        body: json.encode({
          'total': amount,
          'dateTiem': DateTime.now().toIso8601String(),
          'products': products
              .map((cp) => {
                    'id': cp.id,
                    'price': cp.price,
                    'quantity': cp.quantity,
                    'title': cp.title,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
          id: jsonDecode(response.body)['name'],
          total: amount,
          dateTime: DateTime.now(),
          products: products),
    );
    notifyListeners();
  }
}
