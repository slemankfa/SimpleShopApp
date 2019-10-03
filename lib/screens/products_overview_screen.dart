import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';

import '../widgets/products_grid.dart';
import '../providers/products.dart';

enum FilterOption {
  Favorites,
  All,
}

class ProductOverViewScreen extends StatefulWidget {
  // final List<Product> loadedProducts =
  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  bool _showOnlyFavoData = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    // Provider.of<Products>(context).fetchAndSetProduct();
    /*
    the Idea here is too simple it will start fetch the data in the background then after finished the excuation the 
    rist of code it will back to >> then Method, That's it !! :) 
    */
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProduct();
    // });
    super.initState();
  }

/*
 we used a helper attr called _isInit because didChangeDependencies are runing many times 
 and we need to fetch data just in the first time 

 Note : didChangeDependencies start after the widget inilaize..
*/
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productContainer = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOption selectedValue) {
              print(selectedValue);

              setState(() {
                if (selectedValue == FilterOption.Favorites) {
                  // productContainer.showFavoriteOnly();
                  _showOnlyFavoData = true;
                } else {
                  // productContainer.showAll();
                  _showOnlyFavoData = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Onaly Favorite'),
                value: FilterOption.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              child: child,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? Center(child:CircularProgressIndicator() ,) : ProductGrid(_showOnlyFavoData),
    );
  }
}
