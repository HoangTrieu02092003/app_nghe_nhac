import 'package:get/get.dart';

import '../model/album.dart';

class AlbumController extends GetxController{
  var dsAlbum = <AlbumSnapshot>[].obs;
  static AlbumController get instance => Get.find();

  @override
  void onReady() {
    dsAlbum.bindStream(AlbumSnapshot.getAll());
    super.onReady();
  }
}

class ControllerAlbumBidings extends Bindings{

  @override
  void dependencies() {
    Get.put(AlbumController());
  }
}