import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Server extends ChangeNotifier {
  final databaseReference = Firestore.instance;

  CollectionReference getData(String s) {
    final _paq = databaseReference.collection(s);
    return _paq;
  }

  void createData(String path, Map<String, dynamic> data) {
    databaseReference.collection(path).add(data);
  }

  Future updateData(String s, String id, Map<String, dynamic> data) async {
    await databaseReference.collection(s).document(id).updateData(data);
  }

  void delete(String c, String id) {
    databaseReference.collection(c).document(id).delete();
  }

  Future<String> uploadFile(File _image, String name, String foldar) async {
    String _url;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('$foldar/$name');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    await storageReference.getDownloadURL().then((fileURL) {
      _url = fileURL.toString();
    });
    return _url;
  }

  Future deleteImage(String fullUrl) async {
    StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(fullUrl);
    storageReference.delete();
  }
}
