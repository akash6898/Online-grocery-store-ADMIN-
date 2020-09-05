import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import './backend/server.dart';

class Product extends StatefulWidget {
  String _collection;
  DocumentSnapshot _document;
  Product(this._collection, this._document);

  @override
  _Product createState() {
    // TODO: implement createState
    return _Product();
  }
}

class _Product extends State<Product> {
  Server _server;
  Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _server = Provider.of<Server>(context, listen: false);
    _stream = _server
        .getData('products')
        .where(
          'catagory',
          isEqualTo: widget._collection,
        )
        .where('subCatagory', isEqualTo: widget._document.documentID)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._document.data['name'])),
      body: _ShowData(),
    );
  }

  Widget _ShowData() {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.data.documents.length == 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: Text("No data")),
                RaisedButton(
                  child: Text("Add Product"),
                  onPressed: () {
                    Get.toNamed('/addProduct', arguments: {
                      'collection': widget._collection,
                      'document': widget._document.documentID,
                    });
                  },
                )
              ],
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data.documents.length + 1,
                itemBuilder: (context, i) {
                  if (i != snapshot.data.documents.length) {
                    final item = snapshot.data.documents[i].documentID;
                    return Column(
                      children: <Widget>[
                        Dismissible(
                          confirmDismiss: (DismissDirection direction) async {
                            final bool res = await Get.dialog(AlertDialog(
                              title: const Text("Confirm"),
                              content: const Text(
                                  "Are you sure you wish to delete this item?"),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () {
                                      Get.back(result: true);
                                    },
                                    child: const Text("DELETE")),
                                FlatButton(
                                  onPressed: () {
                                    Get.back(result: false);
                                  },
                                  child: const Text("CANCEL"),
                                ),
                              ],
                            ));
                            return res;
                          },
                          background: Container(color: Colors.red),
                          key: Key(item),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (dic) {
                            _server.deleteImage(
                                snapshot.data.documents[i].data['url']);
                            _server.delete('products',
                                snapshot.data.documents[i].documentID);
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                            leading: Image(
                              image: NetworkImage(
                                  snapshot.data.documents[i].data['url']),
                              width: 100,
                              height: 200,
                              fit: BoxFit.fill,
                            ),
                            title:
                                Text(snapshot.data.documents[i].data['name']),
                            onTap: () {
                              Get.toNamed('/productpage', arguments: {
                                'data': snapshot.data.documents[i].documentID
                              });
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Get.toNamed('/updateProduct', arguments: {
                                  'data': snapshot.data.documents[i]
                                });
                              },
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          height: 0,
                        )
                      ],
                    );
                  } else {
                    return RaisedButton(
                      child: Text("Add Product"),
                      onPressed: () {
                        Get.toNamed('/addProduct', arguments: {
                          'collection': widget._collection,
                          'document': widget._document.documentID,
                        });
                      },
                    );
                  }
                });
          }
        }
      },
    );
  }
}
