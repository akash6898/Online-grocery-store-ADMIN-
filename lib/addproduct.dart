import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import './backend/server.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProduct extends StatefulWidget {
  String _collection, _document;
  bool _isUpdate = false;
  DocumentSnapshot _data;

  AddProduct(this._isUpdate, this._data, [this._collection, this._document]);

  @override
  _AddProduct createState() {
    // TODO: implement createState
    return _AddProduct();
  }
}

class _AddProduct extends State<AddProduct> {
  File _image;
  bool _isFeatured = false;
  String _imageUrl;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  Server _server;
  String _menu = 'None';
  List<dynamic> _priceQty = [];

  @override
  void initState() {
    if (widget._data != null) {
      widget._collection = widget._data.data['catagory'];
      widget._document = widget._data.data['subCatagory'];
      _priceQty = new List<dynamic>.from(widget._data.data['priceQty']);
      if (widget._data.data['isFeatured'] != null) {
        _isFeatured = widget._data.data['isFeatured'];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _server = Provider.of<Server>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
      ),
      body: _show(),
    );
  }

  Widget _show() {
    if (widget._data != null) {
      _nameController.text = widget._data.data['name'];
      _descriptionController.text = widget._data.data['description'];
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: "Name"),
              controller: _nameController,
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Description"),
              controller: _descriptionController,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
            _showPriceAndQty(),
            RaisedButton(
              child: Text("Add price qty"),
              onPressed: () async {
                await addPriceQty();
                setState(() {
                  _priceQty = _priceQty;
                });
              },
            ),
            FutureBuilder<QuerySnapshot>(
                future: _server.getData('catagory').getDocuments(),
                builder: (context, snapshot) {
                  if (snapshot.data == null ||
                      snapshot.data.documents.isEmpty) {
                    return DropdownButton<String>(
                      hint: Text("Select Catagory"),
                      value: _menu,
                      icon: Icon(Icons.arrow_downward),
                      onChanged: (String s) {
                        setState(() {
                          _menu = s;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: _menu,
                          child: Text("None"),
                        )
                      ],
                    );
                  } else {
                    List<DropdownMenuItem<String>> _items = [];
                    _items.add(DropdownMenuItem<String>(
                      value: null,
                      child: Text("None"),
                    ));
                    snapshot.data.documents.forEach((document) {
                      _items.add(DropdownMenuItem<String>(
                        value: document.documentID,
                        child: Text(document.data['name']),
                      ));
                    });
                    return DropdownButton<String>(
                      hint: Text("Select Catagoy"),
                      value: widget._collection,
                      onChanged: (String value) {
                        setState(() {
                          widget._collection = value;
                          widget._document = null;
                        });
                      },
                      icon: Icon(Icons.arrow_downward),
                      items: _items,
                    );
                  }
                }),
            FutureBuilder<QuerySnapshot>(
                future: widget._collection != null
                    ? _server.getData(widget._collection).getDocuments()
                    : _server.getData('/').getDocuments(),
                builder: (context, snapshot) {
                  if (snapshot.data == null ||
                      snapshot.data.documents.isEmpty) {
                    return DropdownButton<String>(
                      hint: Text("Select Catagory"),
                      value: _menu,
                      icon: Icon(Icons.arrow_downward),
                      onChanged: (String s) {
                        setState(() {
                          _menu = s;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: _menu,
                          child: Text("None"),
                        )
                      ],
                    );
                  } else {
                    List<DropdownMenuItem<String>> _items = [];
                    _items.add(DropdownMenuItem<String>(
                      value: null,
                      child: Text("None"),
                    ));
                    snapshot.data.documents.forEach((document) {
                      _items.add(DropdownMenuItem<String>(
                        value: document.documentID,
                        child: Text(document.data['name']),
                      ));
                    });
                    return DropdownButton<String>(
                      hint: Text("Select Catagoy"),
                      value: widget._document,
                      onChanged: (String value) {
                        setState(() {
                          widget._document = value;
                        });
                      },
                      icon: Icon(Icons.arrow_downward),
                      items: _items,
                    );
                  }
                }),
            IconButton(
                icon: _isFeatured
                    ? Icon(Icons.star, color: Colors.yellow)
                    : Icon(Icons.star_border),
                onPressed: () {
                  setState(() {
                    _isFeatured = !_isFeatured;
                  });
                }),
            RaisedButton(
              child: Text("Pick Image"),
              onPressed: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                File _temp = await ImagePicker.pickImage(
                    source: ImageSource.gallery, imageQuality: 50);
                if (_temp != null) {
                  imageCache.clear();
                  setState(() {
                    _image = _temp;
                  });
                }
              },
            ),
            _image != null
                ? Image.file(
                    _image,
                    height: 100,
                    width: 100,
                    fit: BoxFit.fill,
                  )
                : SizedBox(),
            RaisedButton(
              child: Text("ok"),
              onPressed: () async {
                if (_nameController.text.length > 0 &&
                    widget._collection != null &&
                    widget._document != null &&
                    _priceQty.length > 0 &&
                    _descriptionController.text.length > 0) {
                  if (!widget._isUpdate) {
                    Get.dialog(
                        AlertDialog(
                          content: CircularProgressIndicator(),
                        ),
                        barrierDismissible: false);
                    _imageUrl = await _server.uploadFile(
                        _image, _nameController.text, 'products');
                    Get.back();
                    Map<String, dynamic> _data = {
                      'name': _nameController.text,
                      'url': _imageUrl,
                      'catagory': widget._collection,
                      'subCatagory': widget._document,
                      'priceQty': _priceQty,
                      'description': _descriptionController.text,
                      'isFeatured': _isFeatured
                      // 'searchIndex': _getSearchIndexes(_nameController.text),
                    };
                    _server.createData('products', _data);
                    Get.back();
                  } else {
                    if (_image != null) {
                      Get.dialog(
                          AlertDialog(
                            content: CircularProgressIndicator(),
                          ),
                          barrierDismissible: false);
                      _server.deleteImage(widget._data.data['url']);
                      _imageUrl = await _server.uploadFile(
                          _image, _nameController.text, 'products');
                      Get.back();
                      Map<String, dynamic> _updatedData = {
                        'url': _imageUrl,
                      };
                      _server.updateData(
                          'products', widget._data.documentID, _updatedData);
                    }
                    Map<String, dynamic> _updatedData = {
                      'name': _nameController.text,
                      'catagory': widget._collection,
                      'subCatagory': widget._document,
                      'priceQty': _priceQty,
                      'description': _descriptionController.text,
                      'isFeatured': _isFeatured
                      // 'searchIndex': _getSearchIndexes(_nameController.text),
                    };

                    _server.updateData(
                        'products', widget._data.documentID, _updatedData);
                    Get.back();
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _showPriceAndQty() {
    List<Widget> _listWidget = [];
    _listWidget.add(Row(children: <Widget>[
      Container(
        child: Text('qty'),
        width: 40,
      ),
      SizedBox(
        width: 20,
      ),
      Container(
        child: Text('price'),
        width: 40,
      ),
      SizedBox(
        width: 20,
      ),
      Container(
        child: Text('mrp'),
        width: 40,
      ),
      SizedBox(
        width: 20,
      ),
      Container(
        child: Text("Stock"),
        width: 40,
      )
    ]));
    for (int i = 0; i < _priceQty.length; i++) {
      _listWidget.add(Row(
        children: <Widget>[
          Container(
            child: Text(_priceQty[i]['qty']),
            width: 40,
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            child: Text(_priceQty[i]['price']),
            width: 40,
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            child: Text(_priceQty[i]['mrp']),
            width: 40,
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            width: 20,
            height: 20,
            color: _priceQty[i]['stock'] == "Out" ? Colors.red : Colors.green,
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await addPriceQty(i);
              setState(() {
                _priceQty = _priceQty;
              });
            },
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _priceQty.removeAt(i);
              });
            },
          )
        ],
      ));
    }

    return Column(
      children: _listWidget,
    );
  }

  Future addPriceQty([int index = -1]) async {
    await showDialog(
        useRootNavigator: false,
        barrierDismissible: false,
        context: context,
        builder: (context) {
          TextEditingController _priceController = new TextEditingController();
          TextEditingController _qtyController = new TextEditingController();
          TextEditingController _mrpController = new TextEditingController();
          String stock = "In";
          if (index != -1) {
            _priceController.text = _priceQty[index]['price'];
            _qtyController.text = _priceQty[index]['qty'];
            _mrpController.text = _priceQty[index]['mrp'];
            stock = _priceQty[index]['stock'];
            //print(stock);
          }
          return StatefulBuilder(builder: (context, setState) {
            // print(_priceQty);
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: "Price"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _qtyController,
                      decoration: InputDecoration(labelText: "Qty"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _mrpController,
                      decoration: InputDecoration(labelText: "Mrp"),
                    ),
                    RadioListTile(
                        title: Text("In Stock"),
                        value: "In",
                        groupValue: stock,
                        onChanged: (val) {
                          setState(() {
                            stock = val;
                          });
                        }),
                    RadioListTile(
                        title: Text("Out Of Stock"),
                        value: "Out",
                        groupValue: stock,
                        onChanged: (val) {
                          setState(() {
                            stock = val;
                            // print(stock);
                          });
                        })
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("ok"),
                  onPressed: () {
                    setState(() {
                      if (index == -1) {
                        if (_priceController.text.length > 0 &&
                            _qtyController.text.length > 0 &&
                            _mrpController.text.length > 0)
                          _priceQty.add({
                            'price': _priceController.text,
                            'qty': _qtyController.text,
                            'mrp': _mrpController.text,
                            'stock': stock,
                          });
                      } else {
                        _priceQty[index]['price'] = _priceController.text;
                        _priceQty[index]['qty'] = _qtyController.text;
                        _priceQty[index]['mrp'] = _mrpController.text;
                        _priceQty[index]['stock'] = stock;
                      }
                    });
                    _priceController.clear();
                    _qtyController.clear();
                    _mrpController.clear();
                    Get.back();
                  },
                ),
                FlatButton(
                  child: Text("cancel"),
                  onPressed: () {
                    _priceController.clear();
                    _qtyController.clear();
                    _mrpController.clear();
                    Get.back();
                  },
                )
              ],
            );
          });
        });
  }

  /* List<String> _getSearchIndexes(String s) {
    List<String> _ans = [];
    for (int i = 1; i < s.length; i++) {
      _ans.add(s.substring(0, i).toLowerCase());
    }
    return _ans;
  }*/
}
