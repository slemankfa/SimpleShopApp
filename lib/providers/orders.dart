import 'package:flutter/cupertino.dart';
import 'cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken  ;
  final String userId ; 

  Orders(this.authToken , this.userId , this._orders); 

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url = 'https://flutterapps-9ee28.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProduct
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quntaty,
                    'price': cp.price,
                  })
              .toList(),
        }));

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timeStamp,
          products: cartProduct,
        ));

    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://flutterapps-9ee28.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);

    final List<OrderItem> loadedOrders = [];
    final extreactedData = json.decode(response.body) as Map<String, dynamic>;
    if(extreactedData == null) {
      return; 
    }
    extreactedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quntaty: item['quantity'],
                    title: item['title'],
                  ))
              .toList()));
    });

    _orders = loadedOrders.reversed.toList() ; 
    notifyListeners(); 

  }
}
