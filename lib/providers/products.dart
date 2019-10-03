import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:shop_app/models/http_exceptiona.dart';
import './product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authToken ; 
  final String userId ; 

  Products(this.authToken  , this.userId, this._items) ; 

  // var _showFavoriteOnly = false;

  List<Product> get items {
    // if (_showFavoriteOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favourtieItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // void showFavoriteOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutterapps-9ee28.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://flutterapps-9ee28.firebaseio.com/userFavorties/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
  // Future<void> fetchAndSetProduct([bool filterByUser = false ]) async {
  //   var url = 'https://flutterapps-9ee28.firebaseio.com/products.json?auth=$authToken&orderBy"creatorId"&equalTo="$userId"';

  //   try {
  //     final response = await http.get(url);
  //     final extractData = json.decode(response.body) as Map<String, dynamic>;
  //     if (extractData == null) {
  //       return;
  //     }
  //     print(extractData) ; 
  //     url = 'https://flutterapps-9ee28.firebaseio.com/userFavorties/$userId.json?auth=$authToken';
  //     final favoriteResponse = await http.get(url); 
  //     final favoriteData = json.decode(favoriteResponse.body); 

  //     final List<Product> loadedProducts = [];
  //     extractData.forEach((prodId, prodData) {
  //       loadedProducts.add(Product(
  //         id: prodId,
  //         title: prodData['title'],
  //         description: prodData['description'],
  //         price: prodData['price'],
  //         //?? to check the value is null or not  ... if not retuern the value after ?? 
  //         isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false ,
  //         imageUrl: prodData['imageUrl'],
  //       ));
  //     });

  //     _items = loadedProducts;
  //     notifyListeners();
  //     // print(json.decode(response.body));
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://flutterapps-9ee28.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId' : userId 
          // 'isFavorite': product.isFavorite,
        }),
      );

      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name']
          // id: DateTime.now().toString(),
          );
      // _items.add(newProduct);
      _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    // .then((response) {
    // print(json.decode(response.body));

    // }).catchError((error) {

    // }); // post
  } // add product

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = 'https://flutterapps-9ee28.firebaseio.com/products/$id.json?auth=$authToken';

      // use try catch
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'isFavorite': newProduct.isFavorite,
          }));

      _items[prodIndex] = newProduct;
    } else {
      print('...');
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://flutterapps-9ee28.firebaseio.com/products/$id.json?auth=$authToken';

    final exitsingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var exitingProduct = _items[exitsingProductIndex];
    _items.removeAt(exitsingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(exitsingProductIndex, exitingProduct);
      notifyListeners();
      throw HttpException('Couid not delete product');
    }
    exitingProduct = null;

    // _items.removeWhere((prod) => prod.id == id);
  }
}
