import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import './backend/server.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Orders extends StatelessWidget {
  Server _server;
  @override
  Widget build(BuildContext context) {
    _server = Provider.of<Server>(context, listen: false);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("orders"),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: "Ongoing orders",
              ),
              Tab(
                text: "Closed Orders",
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _ShowData(1),
            _ShowData(0),
          ],
        ),
      ),
    );
  }

  Widget _ShowData(int a) {
    return StreamBuilder<QuerySnapshot>(
      stream: _server.getData('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (a == 1) {
          List<DocumentSnapshot> _temp = List.from(snapshot.data.documents);
          List<DocumentSnapshot> _orders = [];
          for (int i = 0; i < _temp.length; i++) {
            if (_temp[i].data['status'] != 'Delivered' &&
                _temp[i].data['status'] != 'Canceled') {
              _orders.add(_temp[i]);
            }
          }
          if (_orders.length == 0) {
            return Center(child: Text("No orders"));
          }
          return ListView.builder(
            itemCount: _orders.length,
            itemBuilder: (context, index) => orderCard(_orders, index),
          );
        } else {
          List<DocumentSnapshot> _temp = List.from(snapshot.data.documents);
          List<DocumentSnapshot> _orders = [];
          for (int i = 0; i < _temp.length; i++) {
            if (_temp[i].data['status'] == 'Delivered' ||
                _temp[i].data['status'] == 'Canceled') {
              _orders.add(_temp[i]);
            }
          }
          if (_orders.length == 0) {
            return Center(child: Text("No orders"));
          }
          return ListView.builder(
            itemCount: _orders.length,
            itemBuilder: (context, index) => orderCard(_orders, index),
          );
        }
      },
    );
  }

  Widget orderCard(List<DocumentSnapshot> _orders, int index) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/orderdetial',
            arguments: {'id': _orders[index].documentID});
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              rowData("Order Id", _orders[index].documentID),
              SizedBox(
                height: 10,
              ),
              rowData("Delivery Date", _orders[index].data['delivery date']),
              SizedBox(
                height: 10,
              ),
              rowData("Delivery Time", _orders[index].data['delivery time']),
              SizedBox(
                height: 10,
              ),
              rowData(
                  "Subtotal", "₹" + _orders[index].data['subtotal'].toString()),
              SizedBox(
                height: 10,
              ),
              rowData("Status", _orders[index].data['status'])
            ],
          ),
        ),
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
}
