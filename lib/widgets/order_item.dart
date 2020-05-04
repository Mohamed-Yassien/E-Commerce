import 'dart:math';
import 'package:flutter/material.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem orderItem;

  OrderItem(this.orderItem);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.orderItem.total}'),
            subtitle: Text(widget.orderItem.dateTime.toString()),
            trailing: IconButton(
              icon: Icon(
                expanded ? Icons.expand_less:
                Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            ),
          ),
          if (expanded) Container(
            height: min(widget.orderItem.products.length * 20.0 + 80 ,150),
            padding: EdgeInsets.all(20),
            child: ListView(
              children: widget.orderItem.products.map((prod) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(prod.title,style: TextStyle(color: Colors.purple,fontSize: 18,fontWeight: FontWeight.bold),),
                  Text('\$${prod.quantity}x \$${prod.price}',style: TextStyle(color: Colors.black87),),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
