import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:givemeamoment/widgets/app_drawer.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {

  static const routeName = '/order_screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  var _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) async{
      await Provider.of<Orders>(context,listen: false).fetchAndSetOrders();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final orderDate =   Provider.of<Orders>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: Text('Your Orders'),),
      body:  _isLoading ? Center(child: CircularProgressIndicator(),) : ListView.builder(
        itemCount: orderDate.orders.length,
      itemBuilder: (context,index){
          return OrderItem(orderDate.orders[index]);
      },
    ),
    );
  }
}
