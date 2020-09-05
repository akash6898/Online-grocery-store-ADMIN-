import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/orders.dart';
import './backend/server.dart';
import 'homepage.dart';
import 'first.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addcat.dart';
import 'product.dart';
import 'addproduct.dart';
import 'allProducts.dart';
import 'product_page.dart';
import 'orderdetails.dart';
import 'image_slider.dart';
import 'coupon.dart';
import 'deliverycharges.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Server>(
      create: (BuildContext context) => Server(),
      child: MaterialApp(
        title: 'Log In',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        routes: {
          '/': (BuildContext context) => First(),
          '/showCat': (BuildContext context) => ShowCat(),
          '/addCat': (BuildContext context) => AddCat(),
          '/allProducts': (BuildContext context) => AllProduct(),
          '/orders': (BuildContext context) => Orders(),
          '/imageSlider': (BuildContext context) => ImageSlider(),
          '/coupon': (BuildContext context) => Coupon(),
          '/deliverycharges': (BuildContext context) => DeliveryCharges()
        },
        onGenerateRoute: (settings) {
          Map<String, dynamic> arguments = settings.arguments;
          switch (settings.name) {
            case '/updateCat':
              if (arguments['document'] is DocumentSnapshot) {
                return MaterialPageRoute(
                    builder: (context) =>
                        AddCat(null, true, arguments['document']));
              } else {
                return null;
              }
              break;
            case '/showSubCat':
              if (arguments['collection'] is DocumentSnapshot) {
                return MaterialPageRoute(
                    builder: (context) => ShowCat(arguments['collection']));
              } else {
                return null;
              }
              break;
            case '/addSubCat':
              if (arguments['collection'] is String) {
                return MaterialPageRoute(
                    builder: (context) =>
                        AddCat(arguments['collection'], false));
              } else {
                return null;
              }
              break;
            case '/updateSubCat':
              if (arguments['collection'] is String &&
                  arguments['document'] is DocumentSnapshot) {
                return MaterialPageRoute(
                    builder: (context) => AddCat(
                        arguments['collection'], true, arguments['document']));
              } else {
                return null;
              }
              break;

            case '/showProducts':
              if (arguments['collection'] is String &&
                  arguments['document'] is DocumentSnapshot) {
                return MaterialPageRoute(
                    builder: (context) => Product(
                        arguments['collection'], arguments['document']));
              } else {
                return null;
              }
              break;

            case '/addProduct':
              if (arguments['collection'] is String &&
                  arguments['document'] is String) {
                return MaterialPageRoute(
                    builder: (context) => AddProduct(false, null,
                        arguments['collection'], arguments['document']));
              } else {
                return MaterialPageRoute(
                    builder: (context) => AddProduct(false, null));
              }
              break;
            case '/updateProduct':
              if (arguments['data'] is DocumentSnapshot) {
                return MaterialPageRoute(
                    builder: (context) => AddProduct(true, arguments['data']));
              } else {
                return null;
              }
              break;
            case '/productpage':
              if (arguments['data'] is String) {
                return MaterialPageRoute(
                    builder: (context) => ProductPage(arguments['data']));
              } else {
                return null;
              }
              break;
            case '/orderdetial':
              if (arguments['id'] is String) {
                return MaterialPageRoute(
                    builder: (context) => OrderDetails(arguments['id']));
              } else {
                return null;
              }
              break;
            default:
              return null;
          }
        },
        navigatorKey: Get.key,
      ),
    );
  }
}
