import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'backend/server.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class Coupon extends StatefulWidget {
  Coupon({Key key}) : super(key: key);

  @override
  _CouponState createState() => _CouponState();
}

class _CouponState extends State<Coupon> {
  Server _server;

  @override
  Widget build(BuildContext context) {
    _server = Provider.of<Server>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Coupon"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await CouponData(context, null);
              })
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _server.getData("coupons").getDocuments().asStream(),
        initialData: null,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data.documents.length == 0) {
            return Center(
              child: Text("No Data"),
            );
          } else
            return ListView.builder(
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(snapshot.data.documents[index].documentID),
                  onDismissed: (dic) {
                    _server.delete(
                        'coupons', snapshot.data.documents[index].documentID);
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          rowData("Coupon Name",
                              snapshot.data.documents[index].data['name']),
                          SizedBox(
                            height: 10,
                          ),
                          rowData(
                              "Discount",
                              snapshot.data.documents[index]
                                      .data['discount in %'] +
                                  "%"),
                          SizedBox(
                            height: 10,
                          ),
                          rowData(
                              "Max Discount",
                              snapshot
                                  .data.documents[index].data['maxdiscount']),
                          SizedBox(
                            height: 10,
                          ),
                          rowData("Min Amount",
                              snapshot.data.documents[index].data['minamount']),
                          SizedBox(
                            height: 10,
                          ),
                          rowData("Max Orders",
                              snapshot.data.documents[index].data['maxorders']),
                          SizedBox(
                            height: 10,
                          ),
                          rowData(
                              "Start Date",
                              snapshot
                                  .data.documents[index].data['starting Date']),
                          SizedBox(
                            height: 10,
                          ),
                          rowData(
                              "End Date",
                              snapshot
                                  .data.documents[index].data['ending Date']),
                          SizedBox(
                            height: 10,
                          ),
                          rowData("For",
                              snapshot.data.documents[index].data['For']),
                        ],
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            CouponData(context, snapshot.data.documents[index]);
                          }),
                    ),
                  ),
                );
              },
              itemCount: snapshot.data.documents.length,
            );
        },
      ),
    );
  }

  Row rowData(String id, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(id),
        Text(data),
      ],
    );
  }

  Future CouponData(context, DocumentSnapshot _document) async {
    await showDialog(
        useRootNavigator: false,
        barrierDismissible: false,
        context: context,
        builder: (context) {
          TextEditingController _nameController = new TextEditingController();
          TextEditingController _discountInPerController =
              new TextEditingController();
          TextEditingController _maxDiscountController =
              new TextEditingController();
          TextEditingController _maxOrderController =
              new TextEditingController();
          TextEditingController _minAmountController =
              new TextEditingController();
          String _for = "new";
          DateTime _temp1, _temp2;
          var _startingDate, _endDate;
          if (_document != null) {
            _nameController.text = _document.data['name'];
            _discountInPerController.text = _document.data['discount in %'];
            _maxDiscountController.text = _document.data['maxdiscount'];
            _maxOrderController.text = _document.data['maxorders'];
            _minAmountController.text = _document.data['minamount'];
            _startingDate = _document.data['starting Date'];
            _endDate = _document.data['ending Date'];
            _for = _document.data['For'];
          }
          return StatefulBuilder(builder: (context, setState) {
            // print(_priceQty);
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Coupon name"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _discountInPerController,
                      decoration: InputDecoration(labelText: "discount in %"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _maxDiscountController,
                      decoration: InputDecoration(labelText: "Max Discount"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _minAmountController,
                      decoration: InputDecoration(labelText: "Min Amount"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _maxOrderController,
                      decoration: InputDecoration(labelText: "Max Orders"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _startingDate == null
                            ? SizedBox(
                                width: 0,
                              )
                            : Text(
                                _startingDate.toString(),
                                style: TextStyle(fontSize: 12),
                              ),
                        RaisedButton(
                          onPressed: () async {
                            _temp1 = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2025));

                            setState(() {
                              _startingDate =
                                  DateFormat('yMMMd').format(_temp1);
                            });
                          },
                          child: Text("Select Start Date"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _endDate == null
                            ? SizedBox(
                                width: 0,
                              )
                            : Text(
                                _endDate.toString(),
                                style: TextStyle(fontSize: 12),
                              ),
                        RaisedButton(
                          onPressed: () async {
                            _temp2 = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2025));

                            setState(() {
                              if (_temp2.compareTo(_temp1) > 0)
                                _endDate = DateFormat('yMMMd').format(_temp2);
                            });
                          },
                          child: Text("Select End Date"),
                        ),
                      ],
                    ),
                    RadioListTile(
                        title: Text("For New"),
                        value: "new",
                        groupValue: _for,
                        onChanged: (val) {
                          setState(() {
                            _for = val;
                          });
                        }),
                    RadioListTile(
                        title: Text("For Anyone"),
                        value: "any",
                        groupValue: _for,
                        onChanged: (val) {
                          setState(() {
                            _for = val;
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
                      if (_document == null) {
                        if (_nameController.text.length > 0 &&
                            _discountInPerController.text.length > 0 &&
                            _maxDiscountController.text.length > 0) {
                          _server.createData("coupons", {
                            'name': _nameController.text,
                            'discount in %': _discountInPerController.text,
                            'maxdiscount': _maxDiscountController.text,
                            'minamount': _minAmountController.text,
                            'maxorders': _maxOrderController.text,
                            'starting Date': _startingDate,
                            'ending Date': _endDate,
                            'For': _for
                          });
                        }
                      } else {
                        _server.updateData("coupons", _document.documentID, {
                          'name': _nameController.text,
                          'discount in %': _discountInPerController.text,
                          'maxdiscount': _maxDiscountController.text,
                          'minamount': _minAmountController.text,
                          'maxorders': _maxOrderController.text,
                          'starting Date': _startingDate,
                          'ending Date': _endDate,
                          'For': _for
                        });
                      }
                    });
                    _nameController.clear();
                    _discountInPerController.clear();
                    _maxDiscountController.clear();
                    _maxOrderController.clear();
                    _minAmountController.clear();
                    _startingDate = null;
                    _endDate = null;
                    Get.back();
                  },
                ),
                FlatButton(
                  child: Text("cancel"),
                  onPressed: () {
                    _nameController.clear();
                    _discountInPerController.clear();
                    _maxDiscountController.clear();
                    _maxOrderController.clear();
                    _minAmountController.clear();
                    _startingDate = null;
                    _endDate = null;
                    Get.back();
                  },
                )
              ],
            );
          });
        });
  }
}
