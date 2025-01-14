import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadImage({required String imagePath, required List<String> folders, required String fileName}) async{
  String downloadUrl;
  // tạo đối tượng
  FirebaseStorage _storage = FirebaseStorage.instance;

  //
  Reference reference = _storage.ref();
  for(String f in folders){
    reference.child(f);
  }
  reference = reference.child(fileName);

  //
  final metadata = SettableMetadata(
      contentType: "image/ipeg",
      customMetadata: {'picked-file-path':  imagePath}
  );
  //
  try{
    if(kIsWeb)
      await reference.putData(await XFile(imagePath).readAsBytes());
    else
      await reference.putFile(File(imagePath), metadata);
    downloadUrl = await reference.getDownloadURL();
    return downloadUrl;
  }
  on FirebaseException catch (e){
    print("Lỗi uptload ${e.toString()}");
    return Future.error("Lỗi upload ảnh");
  }
}