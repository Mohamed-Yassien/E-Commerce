import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:givemeamoment/providers/cart.dart' show Cart;
import 'package:givemeamoment/providers/orders.dart';
import 'package:givemeamoment/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {

  static const routeName = '/cartScreen';
  @override
  Widget build(BuildContext context) {

    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Total',style: TextStyle(fontSize: 20),),
                  Spacer(),
                  Chip(
                    label: Text('\$${cart.totalAmount.toStringAsFixed(2)}',style: TextStyle(color: Colors.white),),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  RoundButton(cart),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context,index) => CartItem(
                id: cart.items.values.toList()[index].id,
                productId: cart.items.keys.toList()[index],
                title: cart.items.values.toList()[index].title,
                price: cart.items.values.toList()[index].price,
                quantity: cart.items.values.toList()[index].quantity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundButton extends StatefulWidget {

  final Cart cart;
  RoundButton(this.cart);
  @override
  _RoundButtonState createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return  FlatButton(
      child: _isLoading ? Center(child: CircularProgressIndicator()) : Text('ORDER NOW',style: TextStyle(color: Colors.purple),),
      onPressed: ( widget.cart.totalAmount <= 0 || _isLoading )  ? null : () async{
        setState(() {
          _isLoading = true;
        });
       await Provider.of<Orders>(context,listen: false).addOrder(widget.cart.items.values.toList(), widget.cart.totalAmount);
        setState(() {
          _isLoading = false;
        });
       widget.cart.clear();

      },
    );
  }
}

