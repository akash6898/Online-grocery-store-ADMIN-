import 'package:flutter/material.dart';
import 'package:get/get.dart';

class First extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Server"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _options("Orders", '/orders'),
          _options('View Catogaries', '/showCat'),
          _options('All Products', '/allProducts'),
          _options('Add Product', '/addProduct', {
            'collection': null,
            'document': null,
          }),
          _options('Image Slider', "/imageSlider"),
          _options("Coupon", '/coupon'),
          _options("Delivery Charges", "/deliverycharges"),
        ],
      ),
    );
  }

  Widget _options(String name, String path, [Map<String, dynamic> _arguments]) {
    return RaisedButton(
      child: Text(name),
      onPressed: () {
        Get.toNamed(path, arguments: _arguments);
      },
    );
  }
}
