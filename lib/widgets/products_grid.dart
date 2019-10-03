import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/producrs_item.dart';
import '../providers/products.dart';

class ProductGrid extends StatelessWidget {

  final bool showFavs ; 

  ProductGrid(this.showFavs); 
  @override
  Widget build(BuildContext context) {

    final productData = Provider.of<Products>(context);

    final products = showFavs ? productData.favourtieItems : productData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        // builder: (ctx) => products[i],
        child: ProductItem(
          // products[i].id,
          // products[i].title,
          // products[i].imageUrl,
        ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
