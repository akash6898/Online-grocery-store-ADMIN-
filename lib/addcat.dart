import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import './backend/server.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCat extends StatefulWidget {
  String _subCatId;
  bool _isUpdate;
  DocumentSnapshot _data;
  AddCat([ this._subCatId,this._isUpdate=false, this._data]);
  @override
  _AddCat createState() {
    // TODO: implement createState
    return _AddCat();
  }
}

class _AddCat extends State<AddCat> {
  String collection;
  String document;
  File _image;
  String _imageUrl;
  TextEditingController _nameController = new TextEditingController();
  Server _server;

  @override
  Widget build(BuildContext context) {
    _server = Provider.of<Server>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: widget._subCatId==null ?Text("Add Catagory"): Text("Add SubCat"),
      ),
      body: _show(),
    );
  }

  Widget _show() {

    if (widget._data != null) {
      _nameController.text = widget._data.data['name'];
    }
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(labelText: "Name"),
          controller: _nameController,
        ),
        SizedBox(
          height: 40,
        ),
        RaisedButton(
          child: Text("Pick Image"),
          onPressed: () async {
            FocusScope.of(context).requestFocus(new FocusNode());
            File _temp = await ImagePicker.pickImage(
                source: ImageSource.gallery, imageQuality: 50);
            if (_temp != null) {
              imageCache.clear();
              setState(() {
                _image = _temp;
              });
            }
          },
        ),
        _image != null
            ? Image.file(
                _image,
                height: 100,
                width: 100,
                fit: BoxFit.fill,
              )
            : SizedBox(),
        RaisedButton(
          child: Text("ok"),
          onPressed: () async {
            if (_nameController.text.length > 0) {
               if (!widget._isUpdate) {
              Get.dialog(
                  AlertDialog(
                    content: CircularProgressIndicator(),
                  ),
                  barrierDismissible: false);
              widget._subCatId == null ? collection='catagory' : collection= widget._subCatId;
              _imageUrl =
                  await _server.uploadFile(_image, _nameController.text,collection);
              Get.back();
              Map<String,dynamic> _data = {
                'name': _nameController.text,
                'url' : _imageUrl,
              };
              widget._subCatId == null ? collection='catagory' : collection= widget._subCatId;
              _server.createData(collection,_data);
              Get.back();
              } else {
                    if (_image != null) {
                      Get.dialog(
                          AlertDialog(
                            content: CircularProgressIndicator(),
                          ),
                          barrierDismissible: false);
                      _server.deleteImage(widget._data.data['url']);
                      widget._subCatId == null ? collection='catagory' : collection= widget._subCatId;
                      _imageUrl =
                      await _server.uploadFile(_image, _nameController.text,collection);
                      Get.back();
                      Map<String,dynamic> _updatedData = {
                        'url' : _imageUrl,
                      };
                      widget._subCatId == null ? collection='catagory' : collection= widget._subCatId;
                      _server.updateData(collection,widget._data.documentID,_updatedData);
                    }
                    Map<String,dynamic> _updatedData = {
                      'name' : _nameController.text,
                    };

                    widget._subCatId == null ? collection='catagory' : collection= widget._subCatId;
                    _server.updateData(collection,widget._data.documentID,_updatedData);
                    Get.back();
                  }
            }
          },
        )
      ],
    );
  }
}
