import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './backend/server.dart';
import 'package:get/get.dart';

class ProductPage extends StatefulWidget {
  String _documentId;

  ProductPage(this._documentId);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Server _server;
  int _selectedQty = 0;
  @override
  Widget build(BuildContext context) {
    _server = Provider.of<Server>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: _server
            .getData("products")
            .document(widget._documentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          double discount;
          discount = ((int.parse(
                          snapshot.data.data['priceQty'][_selectedQty]['mrp']) -
                      int.parse(snapshot.data.data['priceQty'][_selectedQty]
                          ['price'])) *
                  100) /
              int.parse(snapshot.data.data['priceQty'][_selectedQty]['mrp']);
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data.data['name']),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Get.toNamed('/updateProduct',
                        arguments: {'data': snapshot.data});
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.network(
                    snapshot.data.data['url'],
                    height: 225,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: Text(
                            discount.toInt().toString() + "% off",
                            style: TextStyle(color: Colors.white),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: Color.fromRGBO(93, 170, 29, 1)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              snapshot.data.data['name'],
                              style: TextStyle(fontSize: 18),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              width: 100,
                              padding: EdgeInsets.all(8),
                              color: snapshot.data.data['priceQty']
                                          [_selectedQty]['stock'] ==
                                      "Out"
                                  ? Colors.red
                                  : Colors.green,
                              child: Center(
                                child: Text(
                                  snapshot.data.data['priceQty'][_selectedQty]
                                              ['stock'] ==
                                          "Out"
                                      ? "Out Of Stock"
                                      : "In Stock",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text("Product MRP: ",
                                style: TextStyle(
                                  fontSize: 18,
                                )),
                            Text(
                              "₹${snapshot.data.data['priceQty'][_selectedQty]['mrp']}",
                              style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Selling Price: ",
                                          style: TextStyle(
                                            fontSize: 18,
                                          )),
                                      Text(
                                        "₹${snapshot.data['priceQty'][_selectedQty]['price']}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ]),
                                SizedBox(
                                  height: 10,
                                ),
                                Text("(Inclusive of all taxes)")
                              ],
                            ),
                            Expanded(
                              child: SizedBox(
                                width: 1,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 30,
                          thickness: 1,
                        ),
                        Text("Unit"),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: unit(snapshot),
                          height: 30,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Description",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(snapshot.data.data['description'])
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget unit(snapshot) {
    List<Widget> _widget = [];
    List<dynamic> _qtyData = snapshot.data.data['priceQty'];
    for (int i = 0; i < _qtyData.length; i++) {
      _widget.add(
        OutlineButton(
          highlightedBorderColor: Theme.of(context).backgroundColor,
          child: Text(_qtyData[i]['qty']),
          borderSide: BorderSide(
            color: _selectedQty == i
                ? Theme.of(context).accentColor
                : Theme.of(context).scaffoldBackgroundColor,
          ),
          onPressed: () {
            setState(() {
              _selectedQty = i;
            });
          },
        ),
      );
      _widget.add(SizedBox(
        width: 10,
      ));
    }
    return ListView(
      scrollDirection: Axis.horizontal,
      children: _widget,
    );
  }
}
