import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:givemeamoment/providers/products.dart';
import 'package:givemeamoment/widgets/product_item.dart';

class ProductGrid extends StatelessWidget {

  final bool yourFav;

  ProductGrid(this.yourFav);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = yourFav?productsData.favouriteItems :  productsData.items;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        //create: (context)=> products[index],
        child: ProductItem(
//          id: products[index].id,
//          imageUrl: products[index].imageUrl,
//          title: products[index].title,
        )
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (MediaQuery.of(context).size.width > 350)? 2 : 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
    );
  }
}
