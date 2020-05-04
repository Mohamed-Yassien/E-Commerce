import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();


  var editedProduct = Product(
    id: null,
    price: 0,
    title: '',
    description: '',
    imageUrl: '',
  );

  var _isInit = true;

  var _initValues = {
    'id':null,
    'title':'',
    'description':'',
    'price':'',
    'imageUrl':'',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit){
      final productId = ModalRoute.of(context).settings.arguments as String ;
      if (productId != null){
        editedProduct = Provider.of<Products>(context,listen: false).findById(productId);
        _initValues = {
          'title' : editedProduct.title,
          'id': editedProduct.id,
          'description': editedProduct.description,
          'price' : editedProduct.price.toString(),
          'imageUrl':'',
        };
          _imageUrlController.text = editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  var _isLoading  = false;

  void updateImageUrl(){
    if (!_imageUrlFocusNode.hasFocus){
      setState(() {
      });
    }
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }



  Future<void> _saveForm() async {
    final isValid =  _form.currentState.validate();
    if (!isValid){
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_initValues['id'] == null){
      try{
        await Provider.of<Products>(context,listen: false).addProduct(editedProduct);
      }catch(error){
        await showDialog(context: context,builder: (ctx) => AlertDialog(
          title: Text('Error Ocuured!'),
          content: Text('Something error comming im your app!'),
          actions: <Widget>[
            FlatButton(child: Text('OK'),onPressed: (){
              Navigator.of(ctx).pop();
        },),
          ],
        ));

      }
//      finally{
//        setState(() {
//          _isLoading = false;
//        });
//        Navigator.of(context).pop();
//      }
    }
    else {
      await Provider.of<Products>(context, listen: false).updateProduct(
          _initValues['id'], editedProduct);
    }
    setState(() {
      _isLoading = false;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(),): Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value){
                  editedProduct = Product(
                    id: editedProduct.id,
                    isFavourite: editedProduct.isFavourite,
                    title: value,
                    price: editedProduct.price,
                    description: editedProduct.description,
                    imageUrl: editedProduct.imageUrl,
                  );
                },
                validator: (value){
                  if (value.isEmpty){
                    return 'please provide a value.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value){
                  if (value.isEmpty){
                    return 'please enter a price.';
                  }
                  if (double.tryParse(value) == null){
                    return 'please enter a valid number';
                  }
                  if (double.parse(value) <= 0 ){
                    return 'value should be greater than zero.';
                  }
                  return null;
                },
                onSaved: (value){
                  editedProduct = Product(
                    id: editedProduct.id,
                    isFavourite: editedProduct.isFavourite,
                    title: editedProduct.title,
                    price: double.parse(value),
                    description: editedProduct.description,
                    imageUrl: editedProduct.imageUrl,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(labelText: 'Descriptino'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                focusNode: _descriptionFocusNode,
                onSaved: (value){
                  editedProduct = Product(
                    id: editedProduct.description,
                    isFavourite: editedProduct.isFavourite,
                    title: editedProduct.title,
                    price: editedProduct.price,
                    description: value,
                    imageUrl: editedProduct.imageUrl,
                  );
                },
                validator: (value){
                  if (value.isEmpty){
                    return 'please enter a description';
                  }
                  if (value.length < 10){
                    return 'description shouled be greater than 10 charecters';
                  }
                  return null;
                },
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 10, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1,color: Colors.purple),
                    ),
                    child: Container(
                      child: _imageUrlController.text.isEmpty
                          ? Text('Enter URL',textAlign: TextAlign.center,)
                          : Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      focusNode: _imageUrlFocusNode,
                      controller: _imageUrlController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_){
                        _saveForm();
                      },
                      onSaved: (value){
                        editedProduct = Product(
                          id: editedProduct.id,
                          isFavourite: editedProduct.isFavourite,
                          title: editedProduct.title,
                          price: editedProduct.price,
                          description: editedProduct.description,
                          imageUrl: value,
                        );
                      },
                      validator: (value){
                        if (value.isEmpty){
                          return'please enter an image url';
                        }
                        if (!value.startsWith('http') && !value.startsWith('https')){
                          return 'please enter a valid url';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
