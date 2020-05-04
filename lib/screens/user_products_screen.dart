import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';


class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshPage(BuildContext context) async{
    await Provider.of<Products>(context,listen: false).fetchAndPost();
  }

  @override
  Widget build(BuildContext context) {
    //final productData =  Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Products'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add),onPressed: (){
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          },),
        ],
      ),
      body: FutureBuilder(
        future: _refreshPage(context),
        builder: (context,snapshot)=> snapshot.connectionState == ConnectionState.waiting ? Center(child: CircularProgressIndicator(),) : RefreshIndicator(
          onRefresh: () => _refreshPage(context),
          child: Consumer<Products>(
            builder: (context,productData,_) => ListView.builder(
              itemCount : productData.items.length ,
              itemBuilder: (context,index) =>UserProductItem(
                id: productData.items[index].id,
                title: productData.items[index].title,
                imageUrl: productData.items[index].imageUrl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
