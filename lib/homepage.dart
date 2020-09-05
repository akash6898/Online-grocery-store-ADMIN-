import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import './backend/server.dart';

class ShowCat extends StatefulWidget {
  DocumentSnapshot subCat;

  ShowCat([this.subCat]);

  @override
  _ShowCat createState() {
    // TODO: implement createState
    return _ShowCat();
  }
}

class _ShowCat extends State<ShowCat> {
  Server _server;
  Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _server = Provider.of<Server>(context, listen: false);
    if (widget.subCat == null)
      _stream = _server.getData('catagory').snapshots();
    else
      _stream = _server.getData(widget.subCat.documentID).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.subCat == null
            ? Text("Catagory")
            : Text(widget.subCat.data['name']),
      ),
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
                  child: widget.subCat == null
                      ? Text("Add Catagory")
                      : Text("Add SUbcatagory"),
                  onPressed: () {
                    widget.subCat == null
                        ? Get.toNamed('/addCat')
                        : Get.toNamed('/addSubCat', arguments: {
                            'collection': widget.subCat.documentID
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
                          onDismissed: (dic) async {
                            Get.dialog(AlertDialog(
                              title: CircularProgressIndicator(),
                            ));
                            List<String> _documentIds = [];
                            if (widget.subCat == null) {
                              QuerySnapshot _documents = await _server
                                  .getData('products')
                                  .where('catagory',
                                      isEqualTo:
                                          snapshot.data.documents[i].documentID)
                                  .getDocuments();
                              _documents.documents.forEach((document) {
                                _documentIds.add(document.documentID);
                              });
                              _server
                                  .getData(
                                      snapshot.data.documents[i].documentID)
                                  .getDocuments()
                                  .then((querySnapshot) {
                                querySnapshot.documents.forEach((document) {
                                  _server.deleteImage(document.data['url']);
                                  _server.delete(
                                      snapshot.data.documents[i].documentID,
                                      document.documentID);
                                });
                              });
                            } else {
                              QuerySnapshot _documents = await _server
                                  .getData('products')
                                  .where('subCatagory',
                                      isEqualTo:
                                          snapshot.data.documents[i].documentID)
                                  .getDocuments();
                              _documents.documents.forEach((document) {
                                _documentIds.add(document.documentID);
                              });
                            }
                            _documentIds.forEach((id) {
                              _server.updateData('products', id, {
                                'catagory': null,
                                'subCatagory': null,
                              });
                            });
                            _server.deleteImage(
                                snapshot.data.documents[i].data['url']);
                            widget.subCat == null
                                ? _server.delete('catagory',
                                    snapshot.data.documents[i].documentID)
                                : _server.delete(widget.subCat.documentID,
                                    snapshot.data.documents[i].documentID);
                            Get.back();
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                            leading: Image(
                              image: NetworkImage(
                                  snapshot.data.documents[i].data['url']),
                              width: 100,
                              fit: BoxFit.fill,
                            ),
                            title: Text(
                              snapshot.data.documents[i].data['name'],
                              softWrap: true,
                              // overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              widget.subCat == null
                                  ? Get.toNamed('/showSubCat', arguments: {
                                      'collection': snapshot.data.documents[i]
                                    })
                                  : Get.toNamed('/showProducts', arguments: {
                                      'collection': widget.subCat.documentID,
                                      'document': snapshot.data.documents[i]
                                    });
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                widget.subCat == null
                                    ? Get.toNamed('/updateCat', arguments: {
                                        'document': snapshot.data.documents[i]
                                      })
                                    : Get.toNamed('/updateSubCat', arguments: {
                                        'collection': widget.subCat.documentID,
                                        'document': snapshot.data.documents[i]
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
                      child: widget.subCat == null
                          ? Text("Add Catagory")
                          : Text("Add SUbcatagory"),
                      onPressed: () {
                        widget.subCat == null
                            ? Get.toNamed('/addCat')
                            : Get.toNamed('/addSubCat', arguments: {
                                'collection': widget.subCat.documentID
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
