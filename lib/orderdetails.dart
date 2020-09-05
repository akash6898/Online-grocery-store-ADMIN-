import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './backend/server.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './trackbar.dart';

class OrderDetails extends StatelessWidget {
  String _documentId;

  OrderDetails(this._documentId);

  Server _server;

  @override
  Widget build(BuildContext context) {
    List<String> _trackbarItem = [
      'Placed',
      'Packed',
      'On The Way',
      'Delivered',
      'Canceled',
    ];

    Timestamp t;

    _server = Provider.of<Server>(context, listen: false);

    return StreamBuilder<DocumentSnapshot>(
        stream: _server.getData("orders").document(_documentId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          int _trackbarIndex =
              _trackbarItem.indexOf(snapshot.data.data['status']);
          t = snapshot.data.data['ordered on'];
          var date =
              new DateTime.fromMicrosecondsSinceEpoch(t.microsecondsSinceEpoch);
          return Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: AppBar(
              title: Text("Order Details"),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      color: Colors.grey.shade100,
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          "Placed On ${DateFormat('yMMMd').format(date)} ${DateFormat('jm').format(date)}",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.2),
                        color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Delivery Time",
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 15),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '${snapshot.data.data['delivery date']},${snapshot.data.data['delivery time']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Delivery Address",
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 15),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '${snapshot.data.data['address']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(
                          thickness: 0.2,
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _trackbarIndex != 4
                            ? TrackBar(snapshot.data['status'])
                            : Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Canceled",
                                    style: TextStyle(color: Colors.red),
                                  )
                                ],
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        _trackbarIndex <= 2
                            ? Row(
                                children: <Widget>[
                                  Expanded(
                                    child: RaisedButton(
                                      onPressed: () {
                                        _server.updateData("orders",
                                            snapshot.data.documentID, {
                                          'status':
                                              _trackbarItem[_trackbarIndex + 1]
                                        });
                                      },
                                      child: Text(
                                          "Show ${_trackbarItem[_trackbarIndex + 1]}"),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: RaisedButton(
                                      onPressed: () {
                                        _server.updateData(
                                            "orders",
                                            snapshot.data.documentID,
                                            {'status': "Canceled"});
                                      },
                                      child: Text("Cancel"),
                                    ),
                                  )
                                ],
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.2),
                        color: Colors.grey.shade100),
                    padding: EdgeInsets.all(8),
                    child: Center(
                        child: Text(
                      "${snapshot.data.data['itemCount'].toString()} Items   Amount:₹${snapshot.data.data['price']}",
                      style: TextStyle(color: Colors.grey.shade700),
                    )),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.2)),
                        color: Colors.white),
                    child: _printitemList(snapshot),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.2),
                        color: Colors.grey.shade100),
                    padding: EdgeInsets.all(8),
                    child: Center(
                        child: Text(
                      "Payment Summary",
                      style: TextStyle(color: Colors.grey.shade700),
                    )),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.2)),
                        color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("M.R.P.",
                                style: TextStyle(color: Colors.grey.shade700)),
                            Text("₹" + snapshot.data.data['mrp'].toString()),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Product Discount",
                                style: TextStyle(color: Colors.grey.shade700)),
                            Text(
                              "- ₹" +
                                  (snapshot.data.data['mrp'] -
                                          snapshot.data.data['price'])
                                      .toString(),
                              style: TextStyle(
                                  color: Color.fromRGBO(93, 170, 29, 1)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: snapshot.data.data['coupon'] == null ? 0 : 10,
                        ),
                        snapshot.data.data['coupon'] == null
                            ? SizedBox()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Coupon",
                                      style: TextStyle(
                                          color: Colors.grey.shade700)),
                                  Text(
                                    snapshot.data.data['coupon'],
                                    style: TextStyle(
                                        color: Color.fromRGBO(93, 170, 29, 1)),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: snapshot.data.data['discount'] == 0 ? 0 : 10,
                        ),
                        snapshot.data.data['discount'] == 0
                            ? SizedBox()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Discount",
                                      style: TextStyle(
                                          color: Colors.grey.shade700)),
                                  Text(
                                    "- ₹" +
                                        snapshot.data.data['discount']
                                            .toString(),
                                    style: TextStyle(
                                        color: Color.fromRGBO(93, 170, 29, 1)),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Delivey charges",
                                style: TextStyle(color: Colors.grey.shade700)),
                            snapshot.data.data['delivery charges'] == 0
                                ? Text(
                                    "FREE",
                                    style: TextStyle(
                                        color: Color.fromRGBO(93, 170, 29, 1)),
                                  )
                                : Text(
                                    "₹" +
                                        snapshot.data.data['delivery charges'],
                                  ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            final boxWidth = constraints.constrainWidth();
                            final dashWidth = 3.0;
                            final dashHeight = 0.5;
                            final dashCount =
                                (boxWidth / (2 * dashWidth)).floor();
                            return Flex(
                              children: List.generate(dashCount, (_) {
                                return SizedBox(
                                  width: dashWidth,
                                  height: dashHeight,
                                  child: DecoratedBox(
                                    decoration:
                                        BoxDecoration(color: Colors.black),
                                  ),
                                );
                              }),
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              direction: Axis.horizontal,
                            );
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Subtotal"),
                            Text("₹" +
                                snapshot.data.data['subtotal'].toString()),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(
                          thickness: 1,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _printitemList(snapshot) {
    List<Widget> _list = [];
    for (int i = 0; i < snapshot.data.data['items'].length; i++) {
      _list.add(Container(
        padding: EdgeInsets.all(8),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
              future: _server
                  .getData('products')
                  .document(snapshot.data.data['items'][i]['product'])
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.network(
                    snapshot.data['url'],
                    height: 50,
                    width: 50,
                    fit: BoxFit.fill,
                  );
                } else {
                  return SizedBox(
                    height: 50,
                    width: 50,
                  );
                }
              },
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  snapshot.data.data['items'][i]['productName'],
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  snapshot.data['items'][i]['unit'],
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text("₹" +
                    snapshot.data.data['items'][i]['price'] +
                    " X " +
                    snapshot.data.data['items'][i]['quantity'].toString())
              ],
            )),
            SizedBox(
              width: 10,
            ),
            Text(
              "₹" +
                  (int.parse(snapshot.data.data['items'][i]['price']) *
                          snapshot.data.data['items'][i]['quantity'])
                      .toString(),
              style: TextStyle(fontWeight: FontWeight.w500),
            )
          ],
        ),
      ));
      if (i != snapshot.data.data['items'].length - 1)
        _list.add(Divider(
          thickness: 1,
        ));
    }
    return Column(children: _list);
  }
}
