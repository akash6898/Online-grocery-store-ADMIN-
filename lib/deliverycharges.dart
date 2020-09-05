import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'backend/server.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class DeliveryCharges extends StatefulWidget {
  @override
  _DeliveryChargesState createState() => _DeliveryChargesState();
}

class _DeliveryChargesState extends State<DeliveryCharges> {
  Future _future;
  @override
  Widget build(BuildContext context) {
    final _server = Provider.of<Server>(context, listen: false);
    _future = _server.getData("delivery").document("charges").get();
    final _minAmountForDeliveryController = TextEditingController();
    final _minAmountForFreeDeliveryController = TextEditingController();
    final _deliveryChargesController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivery Charges"),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Get.dialog(AlertDialog(
                  content: Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _minAmountForDeliveryController,
                          decoration: InputDecoration(
                              labelText: "Min Amount For Delivery"),
                        ),
                        TextField(
                          controller: _minAmountForFreeDeliveryController,
                          decoration: InputDecoration(
                              labelText: "Min Amount For Free Delivery"),
                        ),
                        TextField(
                          controller: _deliveryChargesController,
                          decoration:
                              InputDecoration(labelText: "Delivery Charges"),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    FlatButton(
                      child: Text("Ok"),
                      onPressed: () async {
                        Get.back();
                        Get.dialog(
                            AlertDialog(content: CircularProgressIndicator()));
                        await _server.databaseReference
                            .collection("delivery")
                            .document("charges")
                            .setData({
                          'Min Amount For Delivery':
                              _minAmountForDeliveryController.text,
                          'Min Amount For Free Delivery':
                              _minAmountForFreeDeliveryController.text,
                          'Delivery Charges': _deliveryChargesController.text,
                        });
                        _deliveryChargesController.clear();
                        _minAmountForDeliveryController.clear();
                        _minAmountForFreeDeliveryController.clear();
                        Get.back();
                        setState(() {
                          _future = _future;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        _deliveryChargesController.clear();
                        _minAmountForDeliveryController.clear();
                        _minAmountForFreeDeliveryController.clear();
                        Get.back();
                      },
                    )
                  ],
                ));
              })
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            String _minAmountForDelivery = "0",
                _minAmountForFreeDelivery = "0",
                _deliveryCharges = "0";
            if (!snapshot.data.exists) {
              _minAmountForDelivery = "0";
              _minAmountForDelivery = "0";
              _deliveryCharges = "0";
            } else {
              _minAmountForDelivery =
                  snapshot.data.data['Min Amount For Delivery'];
              _minAmountForFreeDelivery =
                  snapshot.data.data['Min Amount For Free Delivery'];
              _deliveryCharges = snapshot.data.data['Delivery Charges'];
            }
            return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text("Min Amount For Delivery"),
                      Text(_minAmountForDelivery),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text("Min Amount For Free Delivery"),
                      Text(_minAmountForFreeDelivery),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text("Delivery Fee"),
                      Text(_deliveryCharges),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
