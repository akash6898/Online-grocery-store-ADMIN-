import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'backend/server.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({Key key}) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  @override
  Widget build(BuildContext context) {
    final _server = Provider.of<Server>(context);
    Future _future = _server.getData("imageSlider").getDocuments();
    final _textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Image Slider"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                File _temp = await ImagePicker.pickImage(
                    source: ImageSource.gallery, imageQuality: 50);
                if (_temp != null) {
                  Get.dialog(
                      AlertDialog(
                        content: CircularProgressIndicator(),
                      ),
                      barrierDismissible: false);
                  List<String> _list = _temp.toString().split("/");
                  String name = _list[_list.length - 1];
                  String _imageUrl =
                      await _server.uploadFile(_temp, name, 'image slider');
                  _server.createData("imageSlider", {'url': _imageUrl});
                  Get.back();
                  setState(() {
                    _future = _future;
                  });
                }
              })
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else if (snapshot.data.documents.length == 0)
              return Center(
                child: Text("No Data"),
              );

            return ListView.builder(
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(snapshot.data.documents[index].documentID),
                  onDismissed: (dic) {
                    _server.deleteImage(
                        snapshot.data.documents[index].data['url']);
                    _server.delete('imageSlider',
                        snapshot.data.documents[index].documentID);
                  },
                  child: Container(           
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Image.network(
                        snapshot.data.documents[index].data['url'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.fill),
                  ),
                );
              },
              itemCount: snapshot.data.documents.length,
            );
          }),
    );
  }
}
