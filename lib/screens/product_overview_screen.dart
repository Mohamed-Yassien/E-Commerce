import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:givemeamoment/providers/cart.dart';
import 'package:givemeamoment/screens/cart_screen.dart';
import 'package:givemeamoment/widgets/app_drawer.dart';
import 'package:givemeamoment/widgets/badge.dart';
import 'package:givemeamoment/widgets/productGrid.dart';
import '../providers/products.dart';

enum FilteredOptions { favourites, all }

class ProductOverViewScreen extends StatefulWidget {
  static const routeName = 'pro-overview';

  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  var yourFav = false;
  var _isInit = true;
  var _isLoading = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context,listen: false).fetchAndPost().then(
        (_) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilteredOptions selectedVal) {
              if (selectedVal == FilteredOptions.favourites) {
                setState(() {
                  yourFav = true;
                });
              } else {
                setState(() {
                  yourFav = false;
                });
              }
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('only Favourites'),
                value: FilteredOptions.favourites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilteredOptions.all,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(yourFav),
    );
  }
}
